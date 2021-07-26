source("renv/activate.R")
if(interactive() && file.exists(Sys.getenv("R_PROFILE_USER", normalizePath("~/.Rprofile", mustWork = FALSE)))) {
    source(Sys.getenv("R_PROFILE_USER", normalizePath("~/.Rprofile", mustWork = FALSE)))
}

readRenviron(".env")

options(
  renv.config.auto.snapshot = TRUE,
  renv.config.rspm.enabled = TRUE,
  renv.config.install.shortcuts = TRUE
)

if(requireNamespace("conflicted", quietly = TRUE)) {
  conflicted::conflict_prefer("filter", "dplyr", quiet = TRUE)
  conflicted::conflict_prefer("count", "dplyr", quiet = TRUE)
  conflicted::conflict_prefer("geom_rug", "ggplot2", quiet = TRUE)
  conflicted::conflict_prefer("set_names", "magrittr", quiet = TRUE)
  conflicted::conflict_prefer("View", "utils", quiet = TRUE)
}
