#' Read one or more CRANT neuron and nuclei meshes
#'
#' @param ids One or more root ids
#' @param savedir An optional location to save downloaded meshes. This acts as a
#'   simple but effective cache since flywire neurons change id whenever they
#'   are edited.
#' @param lod The level of detail (highest resolution is 0, default of 2 gives a
#' good overall morphology while 3 is also useful and smaller still).
#' @param method How to treat the mesh object returned from neuroglancer, i.e. as
#' a \code{mesh3d} object or a \code{ply} mesh.
#' @param ... Additional arguments passed to
#'   \code{fafbseg::\link{read_cloudvolume_meshes}}
#' @inheritParams fafbseg::save_cloudvolume_meshes
#'
#' @return A \code{\link[nat]{neuronlist}} containing one or more \code{mesh3d}
#'   objects. See \code{nat::\link[nat]{read.neurons}} for details.
#' @export
#' @seealso \code{fafbseg::\link{read_cloudvolume_meshes}}
#' @examples
#' \dontrun{
#' neuron.mesh <- crant_read_neuron_meshes("576460752653449509")
#' plot3d(neuron.mesh, alpha = 0.1)
#' nucleus.mesh <- crant_read_nuclei_mesh("72198744581344126")
#' plot3d(nucleus.mesh, col = "black")
#' }
crant_read_neuron_meshes <- function(ids, savedir=NULL, format=c("ply", "obj"), ...) {
  format=match.arg(format)
  with_crant(read_cloudvolume_meshes(ids, savedir = savedir, format=format, ...))
}

#' @export
#' @rdname crant_read_neuron_meshes
crant_read_nuclei_mesh <- function(ids, lod = 0L, savedir=NULL,  method=c('vf', 'ply'), ...) {
  cvu <-"precomputed://gs://dkronauer-ant-001-segmentations-prod/nucleus/240910-nucleus"
  cv <- fafbseg::flywire_cloudvolume(cloudvolume.url = cvu)
  li <- reticulate::py_eval(ids, convert = F)
  lod <- as.integer(lod)
  cm <- cv$mesh$get(li) # , lod = lod
  if (!any(ids %in% names(cm))) {
    stop("Failed to read segid: ", ids)
  }
  cmesh <- reticulate::py_get_item(cm, li)
  m <- cvmesh2mesh(cmesh, method = method)
  m
}

# hidden
cvmesh2mesh <- bancr:::cvmesh2mesh

#' Read CRANT neuroglancer meshes, e.g., ROI meshes
#'
#' @param x the numeric identifier that specifies the mesh to read, defaults to \code{1} the CRANTb outline mesh.
#' @param url the URL that directs \code{bancr} to where CRANT meshes are stored.
#' @param ... additional arguments to \code{\link{GET}}
#' @return a mesh3d object for the specified mesh.
#' @export
#' @seealso \code{\link{crant_read_neuron_meshes}}
#' @examples
#' \dontrun{
#' # default is brain mesh
#' crant.mesh  <- crant_read_neuroglancer_mesh()
#' }
crant_read_neuroglancer_mesh <- function(x = 1,
                                        url = paste0(
                                          "https://www.googleapis.com/storage/v1/b/",
                                          "dkronauer-ant-001-alignment-final/o/tissue_mesh%2F",
                                          "mesh%2Ftissue_mesh.frag?alt=media",
                                          "&neuroglancer=a2b0cf07baf8c501891d6c683cc7e24a"
                                        ),
                                        ...){
  completed_url <- glue::glue(url, x=x)
  res <- httr::GET(completed_url, ...)
  httr::stop_for_status(res)
  bytes <- httr::content(res, as = "raw")
  malevnc:::decode_neuroglancer_mesh(bytes)
}

