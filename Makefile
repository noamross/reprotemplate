RSCRIPT = Rscript

all:
	${RSCRIPT} -e 'targets::tar_make()'

packages:
	${RSCRIPT} -e 'renv::restore()'

image:
	docker build .

clean:
	${RSCRIPT} -e 'targets::tar_destroy(destroy = "all", ask = FALSE)'

.PHONY: clean all packages image
