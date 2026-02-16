#' Calculate neuron volume from CAVE L2 cache
#'
#' Computes the total volume (in nm³) for one or more CRANTb neurons by
#' summing pre-computed \code{size_nm3} values from the CAVE L2 cache. This
#' is much faster than downloading full meshes.
#'
#' @param ids A vector of one or more neuron root IDs.
#' @param OmitFailures Logical; if \code{TRUE}, neurons that fail are returned
#'   as \code{NA} rather than raising an error (default \code{TRUE}).
#' @param datastack_name An optional CAVE dataset name (expert use only).
#' @param ... Additional arguments (currently unused).
#'
#' @details
#' For each neuron, \code{crant_neuron_volume} retrieves all Level 2 chunk IDs
#' via the chunkedgraph, then queries the L2 cache for the \code{size_nm3}
#' attribute of each chunk. The total neuron volume is the sum across all
#' chunks.
#'
#' The L2 cache stores pre-computed statistics that are updated after every
#' CAVE edit, so results reflect the current segmentation state.
#'
#' @return A \code{data.frame} with columns:
#'   \describe{
#'     \item{root_id}{Character root ID}
#'     \item{volume_nm3}{Total volume in cubic nanometers}
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Single neuron
#' crant_neuron_volume("576460752653449509")
#'
#' # Multiple neurons
#' ids <- c("576460752653449509", "576460752686359273")
#' crant_neuron_volume(ids)
#' }
#'
#' @seealso \code{\link{crant_read_l2skel}} for L2 skeleton data
crant_neuron_volume <- function(ids, OmitFailures = TRUE,
                                datastack_name = crant_datastack_name(), ...) {
  ids <- crant_ids(ids)
  client <- cave_client(datastack_name)

  volumes <- pbapply::pbsapply(ids, function(root_id) {
    tryCatch({
      pyid <- fafbseg:::rids2pyint(root_id)
      l2_ids <- client$chunkedgraph$get_leaves(pyid, stop_layer = 2L)
      l2data <- client$l2cache$get_l2data(l2_ids, attributes = list("size_nm3"))
      # l2data is a Python dict of dicts; convert to R list
      l2list <- reticulate::py_to_r(l2data)
      total <- sum(sapply(l2list, function(x) {
        v <- x[["size_nm3"]]
        if (is.null(v) || is.na(v)) 0 else v
      }))
      total
    }, error = function(e) {
      if (OmitFailures) {
        warning(sprintf("Failed for %s: %s", root_id, e$message))
        NA_real_
      } else {
        stop(e)
      }
    })
  })

  data.frame(
    root_id = as.character(ids),
    volume_nm3 = as.numeric(volumes),
    stringsAsFactors = FALSE
  )
}
