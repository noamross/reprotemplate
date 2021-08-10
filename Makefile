SHELL := /bin/bash
RSCRIPT=Rscript
IMAGE_NAME=repro-image
port=8787
dock=
tar=
WORKDIR:=$(shell pwd)
ifdef dock
  DOCKER_CMD=docker run -v ${WORKDIR}:/home/rstudio/project ${IMAGE_NAME}
  IMG=image
else
	DOCKER_CMD=
	IMG=
endif

#Add a comment starting with `##` after any target to print it with `make help`

.PHONY: help target list deploy test check packages clean image image-nc launch

target: ${IMG} packages ## Build targets.  Defaults to all. Specify targets `make tar=target_name`. Use docker with `make target dock=1`
	${DOCKER_CMD} ${RSCRIPT} -e 'targets::tar_make_future(${tar})'

list: ## List the targets the workflow with status, size, build time, and dependencies. Consider `targets::tar_visnetwork()` in the R console for another view
	@${DOCKER_CMD} ${RSCRIPT} -e 'source("R/utils.R");summarize_targets()'

deploy: ${IMG} ## Build target `all_deployments`. Accepts `dock=1`.
	${DOCKER_CMD} ${RSCRIPT} -e 'targets::tar_make(all_deployments)'

test: ${IMG} ## Build target `all_tests`. Accepts `dock=1`.
	${DOCKER_CMD} ${RSCRIPT} -e 'targets::tar_make(all_tests)'

check: ${IMG} ## Check `renv` status and validate the `_targets.R` file. Takes `dock=1`.
	${DOCKER_CMD} ${RSCRIPT} -e "renv::status()"
	${DOCKER_CMD} ${RSCRIPT} -e "targets::tar_validate()"

packages: ${IMG} ## Install packages needed for build
	${DOCKER_CMD} ${RSCRIPT} -e 'renv::restore()'

clean: packages ## Delete cached targets
	${RSCRIPT} -e 'targets::tar_destroy(destroy = "all", ask = FALSE)'

image: ## Build docker image
	docker build . -t ${IMAGE_NAME}

image-nc: ## Build docker image, clearing the cache
	docker build . -t ${IMAGE_NAME} --no-cache

launch: image ## Launch a docker environment with interactive RStudio in the browser. Set `port=PORT_NUMBER` to specify the port (default:8787).
	docker run --name ${IMAGE_NAME} --rm -d -v ${WORKDIR}:/home/rstudio/project -p ${port}:8787 -e USER=rstudio ${IMAGE_NAME} /init
	${RSCRIPT} -e "browseURL(\"http://localhost:${port}\")"
	@echo "Rstudio container \"${IMAGE_NAME}\" running at http://localhost:${port}.  Stop it by running \`make stop\`."

stop: ## Stop the interactive docker image
	docker stop ${IMAGE_NAME}

key: ## Print a base64-encoded git-crypt symmetric key for use in CI systems
	git-crypt export-key /tmp/key; base64 -i /tmp/key;rm /tmp/key

nuke: ## Remove git-crypt and encrypted data from repository history
	@read -p "This will remove git history of all files listed in .gitattributes. All current changes must be committed. Continue? (y/n)" -n 1 -r \
	&& set -e && export FILTER_BRANCH_SQUELCH_WARNING=1 && echo \
	&& if [[ $$REPLY =~ ^[Yy]$$ ]]; \
		then git-crypt status -e | while read s f; \
    do \
    	git filter-branch --force --index-filter "git rm --cached --ignore-unmatch $$f" --prune-empty --tag-name-filter cat -- --all; \
    done; \
    git rm -rf --ignore-unmatch .git-crypt/; \
    rm -rf .git/git-crypt;\
  fi

help: ## Print this list of commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
