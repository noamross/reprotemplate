suppressPackageStartupMessages(source('packages.R'))
walk(dir_ls(here("R")),  ~try(source(.)))

data_sources <- tar_plan(
  out1 = runif(1000)
)

diagnostics <- tar_plan(
  tar_target(target_buildtimes, get_target_buildtimes(),
             cue = tar_cue("always"))
)

list(
  data_sources,
  diagnostics
)
