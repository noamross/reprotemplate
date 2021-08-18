# syntax = docker/dockerfile:1.3

# Use a base image with all the system libraries you need
FROM rocker/geospatial:4.1.0

# This is helpful to have if we move to a `binder` hosted environment
ENV NB_USER=rstudio

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
    && mkdir -p /home/${NB_USER}/.ccache \
    && echo 'max_size = 5.0G\n' \
    'sloppiness = include_file_ctime\n' \
    'hash_dir = false\n' \
    >> /home/${NB_USER}/.ccache/ccache.conf

# RStudio config - default startup directory, disable password login
RUN mkdir -p /home/${NB_USER}/.config/rstudio \
  && echo '{'\
    '"save_workspace": "never",'\
    '"always_save_history": false,'\
    '"reuse_sessions_for_project_links": true,'\
    '"initial_working_directory": "~/project",'\
    '"posix_terminal_shell": "bash"'\
    '}' >> \
     /home/${NB_USER}/.config/rstudio/rstudio-prefs.json \
  && echo "auth-none=1" >> /etc/rstudio/rserver.conf

# The project
WORKDIR /home/${NB_USER}/project
COPY --chown=${NB_USER} renv.lock .Rprofile .env /home/${NB_USER}/project
COPY --chown=${NB_USER} renv/activate.R /home/${NB_USER}/project/renv/activate.R
# Install packages using on renv, caching
RUN --mount=type=cache,target=/root/.cache/R/renv --mount=type=cache,target=/root/.ccache \
  Rscript -e 'R.version'

RUN --mount=type=cache,target=/root/.cache/R/renv --mount=type=cache,target=/root/.ccache \
  Rscript -e 'renv::restore()' \
  && cp -r /root/.cache/R/renv /root/.cache/R/renv-tmp
RUN rm -rf /root/.cache/R/renv && mv /root/.cache/R/renv-tmp /root/.cache/R/renv

COPY --chown=${NB_USER} . /home/${NB_USER}/project


