# syntax = docker/dockerfile:1.3

# Use a base image with all the system libraries you need
FROM rocker/r-ver:4.1.0 AS sysbase
# Install system libraries
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
     apt-get update \
  && apt-get install -y --no-install-recommends \
    libxml2-dev \
    libcairo2-dev \
    libgit2-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libxtst6 \
    libcurl4-openssl-dev \
    unixodbc-dev \
    libgeos-dev \
    libgeos++-dev \
    gdal-bin \
    libgmp10 \
    libglpk-dev \
   && rm -rf /var/lib/apt/lists/*


FROM sysbase AS projectimage

ENV NB_USER=root
# The project
WORKDIR /home/${NB_USER}/project
COPY --chown=${NB_USER} renv.lock .Rprofile .env /home/${NB_USER}/project
COPY --chown=${NB_USER} renv/activate.R /home/${NB_USER}/project/renv/activate.R
# Install packages using on renv, caching
RUN --mount=type=cache,target=/root/.cache/R/renv \
  Rscript -e 'renv::restore()'

COPY --chown=${NB_USER} . /home/${NB_USER}/project



