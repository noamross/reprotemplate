#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param data
#' @return
#' @author 'Noam Ross'
#' @export
long_running_test_function <- function(data) {
  Sys.sleep(5)
  nrow(data)
}

