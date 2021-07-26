# syntax = docker/dockerfile:1.3

# Use a base image with all the system libraries you need
FROM rocker/geospatial:4.1.0

# Install system libraries
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ccache \
  git-crypt

# Set up R to use ccache to cache compiled code
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

WORKDIR /project
COPY . /project

# Install renv, then install packages using both renv cache and ccache for speed
RUN --mount=type=cache,target=/root/.cache/R/renv \
  Rscript -e 'R.version'
RUN --mount=type=cache,target=/root/.cache/R/renv --mount=type=cache,target=/root/.ccache \
  Rscript -e 'renv::restore();renv::isolate()'
