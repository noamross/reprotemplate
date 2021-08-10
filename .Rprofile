if (file.exists(".env")) {
  try(readRenviron(".env"))
} else {
  message("No .env file")
}

if (file.exists("renv/activate.R")) {
  source("renv/activate.R")
} else {
  message("No renv/activate.R")
}

# Use the local user's .Rprofile when interative.
# Good for keeping local preferences, but not always reproducible.
user_rprof <- Sys.getenv("R_PROFILE_USER", normalizePath("~/.Rprofile", mustWork = FALSE))
if(interactive() && file.exists(user_rprof)) {
  source(user_rprof)
}

options(
  renv.config.auto.snapshot = TRUE, ## Attempt to keep renv.lock updated automatically
  renv.config.rspm.enabled = TRUE, ## Use RStudio Package manager for pre-built package binaries
  renv.config.install.shortcuts = TRUE, ## Use the existing local library to fetch copies of packages for renv
  renv.config.cache.enabled = TRUE,   ## Use the renv build cache to speed up install times
  renv.config.cache.symlinks = FALSE  ## Keep full copies of packages locally than symlinks to make the project portable in/out of containers
)

# If project packages have conflicts define them here
if(requireNamespace("conflicted", quietly = TRUE)) {
  conflicted::conflict_prefer("filter", "dplyr", quiet = TRUE)
  conflicted::conflict_prefer("count", "dplyr", quiet = TRUE)
  conflicted::conflict_prefer("geom_rug", "ggplot2", quiet = TRUE)
  conflicted::conflict_prefer("set_names", "magrittr", quiet = TRUE)
  conflicted::conflict_prefer("View", "utils", quiet = TRUE)
}
