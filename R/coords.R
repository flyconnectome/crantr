#' Handle raw and nm calibrated CRANT coordinates
#'
#' @description \code{crant_voxdims} returns the image voxel dimensions which
#'   are normally used to scale between \bold{raw} and \bold{nm} coordinates.
#'
#' @param url Optional neuroglancer URL containing voxel size. Defaults to
#'   \code{getOption("fafbseg.sampleurl")} as set by
#'   \code{\link{choose_crant}}.
#'
#' @return For \code{crant_voxdims} A 3-vector
#' @export
#'
#' @examples
#' crant_voxdims()
crant_voxdims <- memoise::memoise(function(url=choose_crant(set=FALSE)[['fafbseg.sampleurl']]) {
  fafbseg::flywire_voxdims(url)
})
# 8 8 42

#' @param x 3D coordinates in any form compatible with \code{\link{xyzmatrix}}
#'
#' @return for \code{crant_raw2nm} and \code{crant_nm2raw} an Nx3 matrix of
#'   coordinates
#' @param vd The voxel dimensions in nm. Expert use only. Normally found
#'   automatically.
#' @export
#' @rdname crant_voxdims
#' @details relies on nat >= 1.10.4
#' @examples
#' crant_raw2nm(c(37306, 31317, 1405))
#' crant_raw2nm('37306 31317 1405')
#' \dontrun{
#' crant_nm2raw(clipr::read_clip())
#' }
crant_nm2raw <- function(x, vd=crant_voxdims()) fancr::fanc_nm2raw(x, vd=vd)

#' @export
#' @rdname crant_voxdims
crant_raw2nm <- function(x, vd=crant_voxdims()) fancr::fanc_raw2nm(x, vd=vd)
