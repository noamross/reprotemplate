# Utility functions for managing workflows and reproducibility

# As functions in this file may be called from the command line or Makefiles,
# they should namespace package function explicitly with `::`, and use native
# pipes (|>) rather than magrittr pipes (%>%)

#' Sets up a cache that stores object locally and remotely via S3, pulling from
#' remote if needed
#'
#' @param bucket_name The S3 pucket to store objects in remotely.  The bucket
#'   is created if it does not already exist
#' @param directory Where to put the objects locally. Note this should be
#'   .gitignored and otherwise excluded from saving, but cached on build
#'   systems
#'
#' @return a cachem-style cache of class "cache_layered" and "cachem"
s3_layered_cache <- function(bucket_name = Sys.getenv("AWS_S3_CACHE"),
                             directory = "_cache") {
  put_bucket(bucket_name)
  cache_layered(
    cache_disk(directory),
    structure(
      memoise:::wrap_old_cache(memoise::cache_s3(bucket_name)),
      class = "s3_cache"
    ))
}

deploy_s3_git_file <- function(path, bucket_name = Sys.getenv("AWS_S3_DEPLOY"), url = "") {
  stamp <- ifelse(nrow(git_status()), strftime(Sys.time(), "_%F_%H%M%S"), "")
  key = paste0(git_branch(), "/", git_commit_id(), stamp, "/", basename(path))
  put_object(path, object = key, bucket = bucket_name)
  if (url != "") {
    url = paste0(url, key)
    cat(url)
  }
  return(url)
}

deploy_s3_git_dir <- function(path, bucket_name = Sys.getenv("AWS_S3_DEPLOY"), url = "") {
  stopifnot(is_dir(path))
  stamp <- ifelse(nrow(git_status()), strftime(Sys.time(), "_%F_%H%M%S"), "")
  walk(as.character(dir_ls(path)), ~function(f) {
    key = paste0(git_branch(), "/", git_commit_id(), stamp, "/", f)
    put_object(file = f, object = key, bucket = bucket_name)
  })
  if (url != "") {
    url = paste0(url, key)
    cat(url)
  }
  return(url)
}

print_repro_info <- function(repo = ".", sesinfo = TRUE) {
  cat(date(), "\n")
  cat("Git Commit:", gert::git_commit_id(repo = repo), "\n")
  if(nrow(gert::git_status(repo = repo))) {
    cat("Git status not clean, local changes differ from tree in:\n")
    knitr::knit_print(gert::git_status(repo = repo))
  }

  if(sesinfo) {
    cat("\n")
    renv::diagnostics()
  }
}

summarize_targets <- function() {
  meta <- targets::tar_meta(targets_only = TRUE, fields = c("name", "time", "format"))
  net <- targets::tar_network(targets_only = TRUE, outdated = TRUE)
  dplyr::left_join(net$vertices,
                   dplyr::summarize(dplyr::group_by(net$edges, to), dependencies = paste(from, collapse = ",")),
                   by = c("name"="to")) |>
    dplyr::left_join(meta, by = c("name")) |>
    dplyr::mutate(size = prettyunits::pretty_bytes(as.numeric(bytes), style = "6"), build_time = prettyunits::pretty_sec(seconds)) |>
    dplyr::select(name, format, size, build_time, status, last_built = time, dependencies) |>
    knitr::kable()
}


rename_everywhere <- function(to = "", from = "repro-template", path = ".") {
  if (to == "") stop("A `to` value must be specified!")
  files <- fs::dir_ls(path, all = TRUE, regexp = "^(renv/|.git/|_cache/|_targets/|outputs/|\\.Rproj|\\.Rhistory)", invert = TRUE, recurse = TRUE)
fi}

set_keybindings <- function() {
  NULL
}
