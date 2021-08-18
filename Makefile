SHELL := /bin/bash
RSCRIPT=Rscript
IMAGE_NAME=repro-image
port=8787
dock=
quiet=
tar=
env_key=GIT_CRYPT_KEY64
cmd=echo 'Run `make dock cmd="YOUR_COMMAND"` to run in the docker image'
WORKDIR:=$(shell pwd)
DOCKER_CMD_=docker run -v ${WORKDIR}:/home/rstudio/project ${IMAGE_NAME}
ifdef dock
  DOCKER_CMD=${DOCKER_CMD_}
  IMG=image
else
	DOCKER_CMD=
	IMG=
endif

ifdef quiet
  QUIET=> /dev/null
else
	QUIET=
endif


#Add a comment starting with `##` after any target to print it with `make help`

.PHONY: help target list deploy test check packages clean image image-nc launch dock

targets: packages ## Build targets.  Defaults to all. Specify targets with `make tar=target_name`. Use docker with `make target dock=1`
	${DOCKER_CMD} ${RSCRIPT} -e 'targets::tar_make_future(${tar})'

list: ## List the targets the workflow with status, size, build time, and dependencies. Consider `targets::tar_visnetwork()` in the R console for another view
	@${DOCKER_CMD} ${RSCRIPT} -e 'source("R/utils.R");summarize_targets()'

deploy: ## Build target `all_deployments`. Accepts `dock=1`.
	${DOCKER_CMD} ${RSCRIPT} -e 'targets::tar_make(all_deployments)'

test:  ## Build target `all_tests`. Accepts `dock=1`.
	${DOCKER_CMD} ${RSCRIPT} -e 'targets::tar_make(all_tests)'

check: ## Check `renv` status and validate the `_targets.R` file. Takes `dock=1`.
	${DOCKER_CMD} ${RSCRIPT} -e "renv::status()"
	${DOCKER_CMD} ${RSCRIPT} -e "targets::tar_validate()"

packages: ## Install packages needed for build
	${DOCKER_CMD} ${RSCRIPT} -e 'renv::restore()'

clean: packages ## Delete cached targets
	${RSCRIPT} -e 'targets::tar_destroy(destroy = "all", ask = FALSE)'

image: ## Build docker image
	docker buildx build . --load -t ${IMAGE_NAME} ${QUIET}

image-nc: ## Build docker image, clearing the cache
	docker buildx build . --load -t ${IMAGE_NAME} --no-cache

launch: ## Launch a docker environment with interactive RStudio in the browser. Set `port=PORT_NUMBER` to specify the port (default:8787).
	docker run --name ${IMAGE_NAME} --rm -d -v ${WORKDIR}:/home/rstudio/project -p ${port}:8787 -e USER=rstudio ${IMAGE_NAME} /init
	${RSCRIPT} -e "browseURL(\"http://localhost:${port}\")"
	@echo "Rstudio container \"${IMAGE_NAME}\" running at http://localhost:${port}.  Stop it by running \`make stop\`."

stop: ## Stop the interactive docker image
	docker stop ${IMAGE_NAME}

dock: image ## Run a command in the docker image with `make dock cmd="YOUR_COMMAND"`
	${DOCKER_CMD_} ${cmd}

keys: ## Install default RStudio keybindings
	@echo "Installing these defaults into ~/.config/rstudio/keybindings/"
	${RSCRIPT} -e 'source("R/utils.R");set_default_keybindings()'

cryptkey: ## Print a base64-encoded git-crypt symmetric key for use in CI systems
	git-crypt export-key /tmp/key; base64 -i /tmp/key;rm /tmp/key

decrypt: ## Decrypt the repository, using an base64-encoded environment variable (`env_key=`) if available (default GIT_CRYPT_KEY64)`
	${DOCKER_CMD} \
		$$(if [[ ! -z $$${env_key} ]]; then \
			echo $$${env_key} > /tmp/git_crypt_key.key64 \
			&& base64 -d /tmp/git_crypt_key.key64 > /tmp/git_crypt_key.key \
			&& git-crypt unlock /tmp/git_crypt_key.key; \
		else \
			git-crypt unlock; \
		fi; \
    rm -f /tmp/git_crypt_key.key /tmp/git_crypt_key.key64 && echo "echo")

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
