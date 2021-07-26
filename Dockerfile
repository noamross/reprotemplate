# syntax = docker/dockerfile:1.3
FROM rocker/geospatial:4.1.0

WORKDIR /project
COPY . /project

RUN --mount=type=cache,target=/root/.cache/R/renv \
  Rscript -e 'R.version'
RUN --mount=type=cache,target=/root/.cache/R/renv \
  Rscript -e 'renv::isolate()'
