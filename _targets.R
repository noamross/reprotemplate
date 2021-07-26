suppressPackageStartupMessages(source('packages.R'))
walk(dir_ls(here("R")),  ~try(source(.)))

data_sources <- tar_plan(

)

data_processed <- tar_plan(

)

list(
  data_sources,
  data_processed,
  models,
  outputs,
  reports
)
