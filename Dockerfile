# syntax = docker/dockerfile:1.3
FROM rocker/geospatial:4.1.0

WORKDIR /project
COPY . /project

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ccache

RUN echo 'VER=\n' \
    'CCACHE=ccache\n' \
    'CC=$(CCACHE) gcc$(VER)\n' \
    'CXX=$(CCACHE) g++$(VER)\n' \
    'CXX11=$(CCACHE) g++$(VER)\n' \
    'CXX14=$(CCACHE) g++$(VER)\n' \
    'FC=$(CCACHE) gfortran$(VER)\n' \
    'F77=$(CCACHE) gfortran$(VER)\n' \
    >> /usr/local/lib/R/etc/Makevars.site \
    && mkdir -p /root/.ccache \
    && echo 'max_size = 5.0G\n' \
    'sloppiness = include_file_ctime\n' \
    'hash_dir = false\n' \
    >> /root/.ccache/ccache.conf

RUN --mount=type=cache,target=/root/.cache/R/renv \
  Rscript -e 'R.version'
RUN --mount=type=cache,target=/root/.cache/R/renv --mount=type=cache,target=/root/.ccache \
  Rscript -e 'renv::restore();renv::isolate()'
