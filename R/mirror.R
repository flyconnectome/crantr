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
  x <- if (is_dotprops_list(x) && is.null(subset)) mirror_dotprops(x, reg)
       else nat::xform(x, reg = reg, subset = subset, ...)
  if (identical(units, "nm")) x * 1e3 else x
}

is_dotprops_list <- function(x)
  nat::is.dotprops(x) || (nat::is.neuronlist(x) && length(x) > 0 &&
                            all(sapply(x, nat::is.dotprops)))

# Transform dotprops points and the tips of their (unit) tangent vectors in
# one call, then renormalise. This keeps the original vectors (e.g. L2 cache
# pca) rather than recomputing them from neighbours as nat::xform does, which
# also fails for dotprops with very few points.
mirror_dotprops <- function(x, reg, delta = 1) {
  single <- nat::is.dotprops(x)
  nl <- if (single) nat::as.neuronlist(list(x)) else x
  n <- sapply(nl, function(d) nrow(d$points))
  p <- do.call(rbind, lapply(nl, function(d) d$points))
  v <- do.call(rbind, lapply(nl, function(d) d$vect))
  tx <- nat::xform(rbind(p, p + delta * v), reg = reg)
  pt <- tx[seq_len(nrow(p)), , drop = FALSE]
  vt <- tx[-seq_len(nrow(p)), , drop = FALSE] - pt
  vt <- vt / sqrt(rowSums(vt^2))
  grp <- rep(seq_along(nl), n)
  for (i in seq_along(nl)) {
    sel <- grp == i
    nl[[i]]$points[] <- pt[sel, ]
    nl[[i]]$vect[] <- vt[sel, ]
  }
  if (single) nl[[1]] else nl
}
