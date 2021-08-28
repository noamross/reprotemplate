#' Produced reduced-size GAM models
#'
#' These functions shrink GAM models to more modest size by removing training data
#' and extraneous data.  Run `ensmallen_gam()` to shrink the model, and it will
#' save results of `gam.check()` and `summary()` as well. These cached outputs
#' will be returned when they are called on the reduced model in the future.
#' Use `plot_gam_small()` to produce standard plots, and pass it the same data
#' used to fit the model. Note residuals must be provided if they are to be plotted.
#' `predict()` should work on the fit model as expected.
#'
#' @param gam_obj an GAM model fit with [mgcv::gam()] or [mgcv::bam()]
#' @param capture Whether to capture outputs of `summary()`, and [mgcv::gam.check()]
#' @param height,width size of gam.check plots to capture
#' @param ... other arguments to be passed to [mgcv::gam.check()]
#'
#' @return A GAM model of with reduced size and attributes containing captured values
#' @export
#' @rdname ensmallen_gam
#' @examples
library(mgcv)
set.seed(3)
dat <- gamSim(1,n=25000,dist="normal",scale=20)
bs <- "cr";k <- 12
gam_obj <- bam(y ~ s(x0,bs=bs)+s(x1,bs=bs)+s(x2,bs=bs,k=k)+s(x3,bs=bs),data=dat)
object.size(gam_obj)
gam_obj_small <- ensmallen_gam(gam_obj, capture = TRUE)
object.size(gam_obj)
predictions <- predict(gam_obj_small, newdata = dat)
summary(gam_obj_small)
gam.check(gam_obj_small)
plot_gam_small(gam_obj_small, data = dat, pages = 1)
class(gam_obj_small)
ensmallen_gam <- function(gam_obj, capture = TRUE, height = 1024, width = 768, ...) {
  old_size <- object.size(gam_obj)
  if (capture) {
    gam_obj <- capture_gam_summary(gam_obj)
    gam_obj <- capture_gam_check(gam_obj, ...)
  }
  gam_obj$model <- NULL
  gam_obj$y <- NULL
  gam_obj$G <- NULL
  gam_obj$offset <- NULL
  gam_obj$linear.predictors <- NULL
  gam_obj$fitted.values <- NULL
  gam_obj$residuals <- NULL
  gam_obj$prior.weights <- NULL
  gam_obj$weights <- NULL


  attr(gam_obj$terms, ".Environment") <- baseenv()
  attr(gam_obj$formula, ".Environment") <- baseenv()
  attr(gam_obj$pred.formula, ".Environment") <- baseenv()
  attr(gam_obj$pred.formula, ".Environment") <- baseenv()

  new_size <- object.size(gam_obj)

    message(paste0("Object size reduced ", round(100*(1 - (new_size/old_size))), "% to, ", format(new_size, units = 'MB', digits = 2)))

  class(gam_obj) <- c("gam_small", class(gam_obj))
  return(gam_obj)
}

#' @importFrom evaluate evaluate new_output_handler
#' @importFrom ragg agg_capture
#' @importFrom gridGraphics  echoGrob
#' @importFrom gridExtra  grid.arrange
#' @importFrom png writePNG
#' @export
#' @rdname ensmallen_gam
capture_gam_check <- function(gam_obj, width = 1024, height = 768, ...) {

  gam_check_captured <- evaluate::evaluate(
    "gam.check(gam_obj, ...)",
    output_handler = evaluate::new_output_handler(
      error = stop
    )
  )
  if (length(gam_check_captured) == 6) {
  text <- gam_check_captured[[6]]
  grobs <- lapply(gam_check_captured[2:5], gridGraphics::echoGrob)
  } else if (length(gam_check_captured) == 3) {
    text <- gam_check_captured[[3]]
    grobs <- lapply(gam_check_captured[2], gridGraphics::echoGrob)
  }
  img <- ragg::agg_capture(width = width, height = height)
  gridExtra::grid.arrange(grobs = grobs)
  img_raster <- img()
  dev.off()
  #browser()
  dims <- dim(img_raster)
  rgbs <- col2rgb(img_raster, alpha = F) / 255
  nr <- dims[1]
  nc <- dims[2]
  reds <- matrix(rgbs[1, ], nrow = nr, ncol = nc, byrow = FALSE)
  greens <- matrix(rgbs[2, ], nrow = nr, ncol = nc, byrow = FALSE)
  blues <- matrix(rgbs[3, ], nrow = nr, ncol = nc, byrow = FALSE)
  img_raw_png <- png::writePNG(array(c(reds, greens, blues), dim = c(dims, 3)))

  attr(gam_obj, "gam_check_captured") <- list(text = text, image = img_raw_png)
  class(gam_obj) <- c("gam_with_check", class(gam_obj))
  return(gam_obj)
}

#' @importFrom evaluate evaluate new_output_handler
#' @importFrom ragg agg_capture
#' @importFrom gridGraphics  echoGrob
#' @importFrom gridExtra  grid.arrange
#' @importFrom png writePNG
#' @export
#' @rdname ensmallen_gam
capture_gam_summary <- function(gam_obj) {
  gam_summary_captured <- summary(gam_obj)

  attr(gam_obj, "gam_summary_captured") <- gam_summary_captured
  class(gam_obj) <- c("gam_with_summary", class(gam_obj))
  return(gam_obj)
}

#' @export
#' @noRd
gam.check <- function(gam_obj, ...) {
  UseMethod("gam.check")
}

#' @export
#' @noRd
gam.check.gam <- function(gam_obj, ...) {
  mgcv::gam.check(gam_obj, ...)
}

#' @export
#' @noRd
gam.check.gam_with_check <- function(gam_obj, ...) {
  print.gam_check_captured(
    attr(gam_obj, "gam_check_captured")
  )
}

#' @export
#' @noRd
summary.gam_with_summary <- function(gam_obj) {
  attr(gam_obj, "gam_summary_captured")
}

#' @export
#' @noRd
#' @importFrom png readPNG
#' @importFrom gridExtra grid.arrange
print.gam_check_captured <- function(gam_check_captured) {
  cat(gam_check_captured$text)
  op <- par(mar = rep(0,4))
  plot(NA, xlim = c(0, 1), ylim = c(0, 1), type = "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "")
  rasterImage(png::readPNG(gam_check_captured$image), 0, 0, 1, 1)
  par(op)
}

#' @param gam_small A reduced GAM model produced by ensmallen_gam
#' @export
#' @importFrom mgcv plot.gam
#' @rdname ensmallen_gam
plot_gam_small <- function(gam_small, data, ...) {
  gam_small$model <- data
  mgcv::plot.gam(gam_small, ...)
}


