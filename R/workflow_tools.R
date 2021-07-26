get_target_buildtimes <- function() {
  tar_meta(targets_only = TRUE) %>%
    select(name, format, size = bytes, time = seconds, warnings, error) %>%
    arrange(desc(time)) %>%
    mutate(
      size = prettyunits::pretty_bytes(as.numeric(size), style = "6"),
      time = prettyunits::pretty_sec(time)) %>%
    knitr::kable()
}
