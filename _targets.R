suppressPackageStartupMessages(source('packages.R'))
walk(dir_ls(here("R")),  ~try(source(.)))

data_sources <- tar_plan(
  out1 = runif(1000)
)


list(
  data_sources
)
