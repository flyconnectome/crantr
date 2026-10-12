#' Mirror CRANT neurons or points to the opposite side of the brain
#'
#' @description `crant_mirror()` mirrors objects supported by [nat::xform()],
#'   including neurons, neuronlists, dotprops, meshes and coordinate matrices,
#'   across the CRANT brain midline.
#'
#' @param x An object to mirror.
#' @param units Coordinate units for `x` and the returned object. The mirror
#'   registration is defined in microns; nm inputs are scaled before and after
#'   transformation.
#' @param subset Optional subset passed to [nat::xform()], for example when
#'   transforming selected elements of a neuronlist.
#' @param reg The mirror registration (in microns). Advanced use.
#' @param ... Additional arguments passed to [nat::xform()].
#'
#' @details Mirroring uses the thin plate spline [crant_mirror_tps] and needs
#'   the suggested \pkg{Morpho} package at runtime.
#'
#' @return A transformed object of the same kind as `x`.
#' @seealso [crant_mirror_tps]
#' @export
#'
#' @examples
#' \dontrun{
#' # a point either side of the midline (x ~ 202 um)
#' crant_mirror(rbind(c(120, 200, 130), c(280, 200, 130)), units = "microns")
#'
#' library(nat)
#' crantb.surf.m <- crant_mirror(crantb.surf)
#' wire3d(crantb.surf, col = "grey")
#' wire3d(crantb.surf.m, col = "red")
#' }
crant_mirror <- function(x, units = c("nm", "microns"), subset = NULL,
                         reg = crantr::crant_mirror_tps, ...) {
  units <- match.arg(units)
  if (!requireNamespace("Morpho", quietly = TRUE))
    stop("Please install the suggested Morpho package to mirror CRANT data.",
         call. = FALSE)
  if (identical(units, "nm")) x <- x / 1e3
  x <- nat::xform(x, reg = reg, subset = subset, ...)
  if (identical(units, "nm")) x * 1e3 else x
}
