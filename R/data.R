#' Simplified tissue surface for crant
#'
#' @name crantb.surf
#' @docType data
#' @description `crantb.surf` is unsymmetrical and not a normalised version of the dataset mesh.
#' It is the outline of the dataset in nanometers. It can be seen in neuroglancer
#' \href{https://spelunker.cave-explorer.org/#!middleauth+https://global.daf-apis.com/nglstate/api/v1/5185996221054976}{here}.
#'
#' @examples
#' \dontrun{
#' # Depends on nat
#' library(nat)
#' rgl::wire3d(crantb.surf)
#' }
"crantb.surf"

# # How it was obtained:
# res <- httr::GET("https://www.googleapis.com/storage/v1/b/dkronauer-ant-001-alignment-final/o/tissue_mesh%2Fmesh%2Ftissue_mesh.frag?alt=media&neuroglancer=a2b0cf07baf8c501891d6c683cc7e24a")
# httr::stop_for_status(res)
# bytes <- httr::content(res, as = "raw")
# crant.mesh <- malevnc:::decode_neuroglancer_mesh(bytes)
# crantb.surf <- as.hxsurf(crant.mesh)
# usethis::use_data(crantb.surf, overwrite = TRUE)

#' Thin plate spline mirror registration for CRANT
#'
#' @name crant_mirror_tps
#' @docType data
#' @description A [nat::tpsreg()] registration that maps points in the CRANT
#'   brain (in microns) to their mirror image on the opposite side. Use it via
#'   [crant_mirror()].
#'
#' @details The registration was made by registering an X-flipped image of
#'   CRANT synapse density (1 um voxels, synapse snapshot v523) onto the
#'   original with warpfield (\url{https://github.com/danionella/warpfield}).
#'   Points on a 12 um grid in neuropil were mapped through this registration
#'   to give mirror landmarks; the TPS was fitted to those left of the midline
#'   (x ~ 202 um) in both directions, so that it is very nearly its own
#'   inverse. On held out grid points it agrees with the warpfield mirror to
#'   ~1 um (median; 90% < 3.3 um) and mirroring twice returns points to within
#'   0.1 um (median). See `data-raw/crant-synapse-density.R`,
#'   `data-raw/crant-mirror-warpfield.py` and `data-raw/crant-mirror-tps.R`.
#'
#' @seealso [crant_mirror()]
#' @examples
#' crant_mirror_tps
"crant_mirror_tps"
