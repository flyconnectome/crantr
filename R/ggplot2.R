#' Plot a neuron in the CRANT connectomic dataset using ggplot2
#'
#' This function visualizes a neuron or neuron-related object from the CRANT connectomic dataset using ggplot2.
#' The only thing specific to the CRANT data set is are the prreset 'view' angles.
#'
#' @param x A 'neuron', 'neuronlist', 'mesh3d', or 'hxsurf' object to be visualized.
#' @param volume A brain/neuropil volume to be plotted in grey, for context.
#'   Defaults to NULL, no volume plotted.
#' @param info Optional. A string to be used as the plot title.
#' @param view A character string specifying the view orientation.
#'   Options are "front", "side", "back".
#' @param cols1 A vector of two colors for the lowest Z values. Default is c("turquoise", "navy").
#' @param cols2 A vector of two colors for the highest Z values. Default is c("grey75", "grey50").
#' @param alpha Transparency of the neuron visualization. Default is 0.5.
#' @param title.col Color of the plot title. Default is "darkgrey".
#' @param ... Additional arguments passed to geom_neuron().
#'
#' @return A ggplot object representing the visualized neuron.
#'
#' @details This function is a wrapper around the ggneuron function, specifically tailored for the CRANT dataset.
#'   It applies a rotation matrix based on the specified view and uses predefined color schemes.
#'
#' @export
crant_ggneuron <-function(x,
                         volume = NULL,
                         info = NULL,
                         view = c("front", "side", "back"),
                         cols1 = c("turquoise","navy"),
                         cols2 =  c("grey75", "grey50"),
                         alpha = 0.5,
                         title.col = "darkgrey",
                         ...){
  #crantr::crantb.surf
  view <- match.arg(view)
  rotation_matrix <- crant_rotation_matrices[[view]]
  bancr::ggneuron(x,
           volume = volume,
           info = info,
           rotation_matrix = rotation_matrix,
           cols1 = cols1,
           cols2 =  cols2,
           alpha = alpha,
           title.col = title.col,
           ...)
}

# hidden
crant_rotation_matrices <- list(
  front = structure(c(0.999845921993256, 0.0147675722837448,
                     0.00950427353382111, 0, 0.00935166329145432, -0.9057936668396,
                     0.4236159324646, 0, 0.0148646384477615, -0.423461735248566, -0.905792057514191,
                     0, 0, 0, 0, 1), dim = c(4L, 4L)),
  side = structure(c(-0.0486822575330734, -0.0398533083498478,
                     0.998019099235535, 0, -0.22111040353775, -0.973982691764832,
                     -0.0496789813041687, 0, 0.974032998085022, -0.223090872168541,
                     0.0386035442352295, 0, 0, 0, 0, 1), dim = c(4L, 4L)),
  back = structure(c(-0.996761322021484, -0.0218941774219275,
                      0.0773822516202927, 0, 0.00287696067243814, -0.971319139003754,
                      -0.237763032317162, 0, 0.0803685933351517, -0.236770361661911,
                      0.968235969543457, 0, 0, 0, 0, 1), dim = c(4L, 4L))
)

#' Set Default View for CRANT EM Dataset
#'
#' @description
#' This function sets a default view for visualizing the 'CRANT' Electron Microscopy (EM) dataset
#' using the rgl package. It adjusts the viewpoint to a specific orientation and zoom level
#' that is optimal for viewing this particular dataset.
#'
#' @details
#' The function uses `rgl::rgl.viewpoint()` to set a predefined user matrix and zoom level.
#' This matrix defines the rotation and translation of the view, while the zoom parameter
#' adjusts the scale of the visualization.
#'
#' @return
#' This function is called for its side effect of changing the rgl viewpoint.
#' It does not return a value.
#'
#' @examples
#' \dontrun{
#' # Assuming you have already plotted your CRANT EM data
#' crant_view()
#' }
#'
#' @note
#' This function assumes that an rgl device is already open and that the CRANT EM dataset
#' has been plotted. It will not create a new plot or open a new rgl device.
#'
#' @seealso
#' \code{\link[rgl]{rgl.viewpoint}} for more details on setting viewpoints in rgl.
#'
#' @export
crant_view <- function(){
  rgl::rgl.viewpoint(userMatrix  = crant_rotation_matrices[["front"]], zoom = 0.82)
}

# for nm
#' @export
#' @rdname crant_view
crant_side_view <- function(){
  rgl::rgl.viewpoint(userMatrix = crant_rotation_matrices[["side"]], zoom = 0.29)
}

# for nm
#' @export
#' @rdname crant_view
crant_back_view <- function(){
  rgl::rgl.viewpoint(userMatrix = crant_rotation_matrices[["back"]], zoom = 0.62)
}
