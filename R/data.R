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
