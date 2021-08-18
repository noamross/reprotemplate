# Load packages/functions --------
suppressPackageStartupMessages(source('packages.R'))
walk(dir_ls(here("R")),  ~try(source(.)))

# Configuration ------

# Set up a cache for shared, long-time-build-objects
s3 <- s3_layered_cache()
# Connect to RStudio connect if deloying here
# connectApiUser(account = Sys.getenv("RSCONNECT_USER"),
#                server = Sys.getenv("RSCONNECT_SERVER"),
#                apiKey = Sys.getenv("RSCONNECT_API_KEY"))
# Set up parallelism (no of targets that can run simultaneously)
tar_config_set(workers = get_num_cores())

# Targets ---------
data_sources <- tar_plan(
  dat = tibble(a = runif(100))
)

# Long-running targets that may want to be shared by the group should be memoized
analyses <- tar_plan(
  model1 = memoise(long_running_test_function, cache = s3)(dat)
)

# reports <- tar_plan(
#   tar_render(main_report, "reports/main.Rmd", output_dir = "outputs"),
#   tar_render(test_report, "reports/tests.Rmd", output_dir = "outputs"),
#   all_reports = c(main_report, test_report)
# )

# deployments <- tar_plan(
#   rs_deployment = deployApp(appDir = dirname(main_report[1]),
#                                appFiles = c(main_report, tests[1]),
#                                appPrimaryDoc = main_report[1]),
#   s3_deployment = deploy_s3_git_dir(dirname(main_report[1])),
#   all_deployments = c(rs_deployment, s3_deployment)
# )

# tests <- tar_plan(
#   all_tests = c(test_report)
# )
#
# diagnostics <- tar_plan(
#   target_summary = summarise_targets()
# )

list(
  data_sources
#  analyses,
#  reports,
#  deployments,
#  tests
)
