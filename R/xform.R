#' #' Mirror BANC Connectome Points
#' #'
#' #' @description
#' #' This function mirrors 3D points in the BANC (Buhmann et al. Adult Neural Connectome)
#' #' coordinate system by transforming to JRC2018F, mirroring, and transforming back.
#' #'
#' #' @param x An object containing 3D points (must be compatible with nat::xyzmatrix).
#' #' @param banc.units Character string specifying the banc.units of the input points.
#' #'   Must be one of "nm" (nanometers), "um", or "raw" (BANC raw banc.units). Default is "nm".
#' #' @param subset Optional. A logical vector or expression to subset the input object.
#' #' @param inverse Logical. Not used in this function, kept for compatibility with banc_to_JRC2018F.
#' #' @param transform_files Optional. A vector of two file paths for custom transform files.
#' #'   If NULL, uses default files.
#' #' @param method Character string specifying the transformation method.
#' #'   Must be either "elastix" or "tpsreg". Default is "elastix".
#' #' @param ... Additional arguments passed to \code{nat.templatebrains::\link{mirror_brain}}.
#' #'
#' #' @return The input object with mirrored 3D points.
#' #'
#' #' @details
#' #' This function performs mirroring of BANC points by first transforming them to the JRC2018F
#' #' coordinate system, applying the mirroring operation, and then transforming them back to BANC.
#' #' It can use either Elastix transforms or thin-plate spline registration for the coordinate
#' #' system transformations.
#' #'
#' #' @examples
#' #' \dontrun{
#' #' # Example using saved tpsreg
#' #' banc_neuropil.surf.m <- banc_mirror(banc_neuropil.surf, method = "tpsreg")
#' #' clear3d()
#' #' banc_view()
#' #' plot3d(banc_neuropil.surf, alpha = 0.5, col = "lightgrey")
#' #' plot3d(banc_neuropil.surf.m, alpha = 0.5, col = "green")
#' #'
#' #' # Example using custom Elastix transforms
#' #' choose_crant()
#' #' rootid <- "720575941626035769"
#' #' neuron.mesh <- banc_read_neuron_meshes(rootid)
#' #'
#' #' # Show neuron in BANC neuropil
#' #' banc_view()
#' #' plot3d(neuron.mesh, col = "red")
#' #' plot3d(banc_neuropil.surf, alpha = 0.1, col = "lightgrey")
#' #'
#' #' # Show only the portion in the brain
#' #' neuron.mesh.brain <- banc_decapitate(neuron.mesh, invert = TRUE)
#' #'
#' #' # Mirror in BANC space
#' #' neuron.mesh.mirror <- banc_mirror(neuron.mesh.brain,
#' #' transform_files = c("brain_240721/BANC_to_template.txt",
#' #'  "brain_240721/template_to_BANC.txt"))
#' #' plot3d(neuron.mesh.mirror, col = "cyan")
#' #' }
#' #'
#' #' @seealso
#' #' \code{\link{banc_to_JRC2018F}} for the underlying transformation function.
#' #' \code{nat.templatebrains::\link{mirror_brain}} for the mirroring operation in JRC2018F space.
#' #'
#' #' @export
#' banc_mirror <- function(x,
#'                         banc.units = c("nm", "um", "raw"),
#'                         subset = NULL,
#'                         inverse = FALSE,
#'                         transform_files = NULL,
#'                         method = c("tpsreg","elastix","navis_elastix_xform"),
#'                         ...){
#'
#'   # Manage arguments
#'   banc.units <- match.arg(banc.units)
#'   method <- match.arg(method)
#'
#'   #Get 3D points
#'   xyz <- nat::xyzmatrix(x)
#'
#'   # Use elastix transform
#'   if(method=="elastix"){
#'
#'     # brain points
#'     y.cut <- 325000
#'     xyz.brain <- xyz[xyz[,2]<y.cut,]
#'     xyz.vnc <- xyz[xyz[,2]>y.cut,]
#'
#'     if(nrow(xyz.brain)){
#'       # Convert to JRC2018F
#'       x.jrc2018f <- banc_to_JRC2018F(x=xyz.brain, region="brain", banc.units=banc.units, subset=NULL, inverse=FALSE, transform_file = transform_files[1], method = method)
#'
#'       # Mirror
#'       x.jrc2018f.m <-  nat.templatebrains::mirror_brain(x.jrc2018f, brain = nat.flybrains::JRC2018F, transform = "flip")
#'
#'       # Back to BANC
#'       x.banc.m <- banc_to_JRC2018F(x=x.jrc2018f.m,  region="brain", banc.units=banc.units, subset=NULL, inverse=TRUE , transform_file = transform_files[2], method = method)
#'     }
#'     if(nrow(xyz.brain)){
#'
#'       # Convert to JRC2018F
#'       x.jrcvnc2018f <- banc_to_JRC2018F(x=xyz.brain, region="VNC", banc.units=banc.units, subset=NULL, inverse=FALSE, transform_file = transform_files[1], method = method)
#'
#'       # Mirror
#'       x.jrcvnc2018f.m <-  nat.templatebrains::mirror_brain(x.jrcvnc2018f, brain = nat.flybrains::JRCVNC2018F, transform = "flip")
#'
#'       # Back to BANC
#'       x.banc.m <- banc_to_JRC2018F(x=x.jrcvnc2018f.m, region="VNC", banc.units=banc.units, subset=NULL, inverse=TRUE , transform_file = transform_files[2], method = method)
#'     }
#'   }else{
#'
#'     # convert to um if necessary
#'     if(banc.units=='um'){
#'       xyz <- xyz*1e3
#'     }else if(banc.units=='raw'){
#'       xyz <- banc_raw2nm(xyz)
#'     }
#'
#'     # use pre-calculated tps reg
#'     # utils::data("banc_mirror_tpsreg", envir = environment())
#'     x.banc.m <- Morpho::applyTransform(xyz,
#'                                        trafo = bancr::banc_mirror_tpsreg)
#'
#'     # convert from um to original banc.units if necessary
#'     if(banc.units=='um'){
#'       x.banc.m <- x.banc.m/1e3
#'     }else if(banc.units=='raw'){
#'       x.banc.m <- banc_nm2raw(x.banc.m)
#'     }
#'
#'   }
#'
#'   # return
#'   nat::xyzmatrix(x) <- x.banc.m
#'   return(x)
#'
#' }
#'
#' # hidden, for now
#' banc_lr_position <- function (x, units = c("nm", "um", "raw"), group = FALSE, ...) {
#'   xyz = nat::xyzmatrix(x)
#'   xyzt = banc_mirror(xyz, units = units, ...)
#'   lrdiff = xyzt[, 1] - xyz[, 1]
#'   if (group) {
#'     if (!nat::is.neuronlist(x))
#'       stop("I only know how to group results for neuronlists")
#'     df = data.frame(lrdiff = lrdiff, id = rep(names(x), nat::nvertices(x)))
#'     dff = dplyr::summarise(dplyr::group_by(df, .data$id), lrdiff = mean(lrdiff))
#'     lrdiff = dff$lrdiff[match(names(x), dff$id)]
#'   }
#'   lrdiff
#' }
