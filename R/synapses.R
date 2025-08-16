#' Add synapses to neuron objects
#'
#' This function family adds synaptic data to neuron objects or neuron lists.
#' It retrieves synaptic connections and attaches them to the neuron object(s).
#'
#' @param x A neuron object, neuronlist, or other object to add synapses to
#' @param id The root ID of the neuron. If `NULL`, it uses the ID from the neuron object
#' @param connectors A dataframe of synaptic connections. If `NULL`, it retrieves the data
#' @param size.threshold Minimum size threshold for synapses to include
#' @param remove.autapses Whether to remove autapses (self-connections)
#' @param update.id Logical, whether or not to use \code{crant_latestid} to update the neuron's `root_id` when fetching synapses.
#' @param ... Additional arguments passed to methods, \code{nat::nlapply}
#'
#' @return An object of the same type as `x`, with synapses added
#' @examples
#' \dontrun{
#' # Get CRANT ID for a olfactory PN
#' id <- "720575941572711675"
#' id <- crant_latestid(id)
#'
#' # Get the L2 skeletons
#' n <- crant_read_l2skel(id)
#'
#' # Re-root to soma
#' n.rerooted <- crant_reroot(n)
#'
#' # Add synapse information, stored at n.syn[[1]]$connectors
#' n.syn <- crant_add_synapses(n.rerooted)
#'
#' # Split neuron
#' n.split <- hemibrainr::flow_centrality(n.syn)
#'
#' }
#' @export
crant_add_synapses <- function(x,
                              id = NULL,
                              connectors = NULL,
                              size.threshold = 5,
                              remove.autapses = TRUE,
                              update.id = TRUE,
                              ...) {
  UseMethod("crant_add_synapses")
}

#' @rdname crant_add_synapses
#' @export
crant_add_synapses.neuron <- function(x,
                              id = NULL,
                              connectors = NULL,
                              size.threshold = 5,
                              remove.autapses = TRUE,
                              update.id = TRUE,
                              ...){
  # Get valid root id
  if(is.null(id)){
    id <- x$id
  }
  if(update.id){
    id <- crant_latestid(id)
  }

  # Get synaptic data
  if(is.null(connectors)){
    connectors.in <- crant_partners(id, partners = "input")
    if(nrow(connectors.in)){
      connectors.in.xyz <- do.call(rbind,connectors.in$post_pt_position)
      connectors.in.xyz <- as.data.frame(connectors.in.xyz)
      colnames(connectors.in.xyz) <- c("X","Y","Z")
      connectors.in <- cbind(connectors.in,connectors.in.xyz)
      connectors.in <- connectors.in %>%
        dplyr::rename(connector_id = .data$id,
                      pre_id = .data$pre_pt_root_id,
                      pre_svid = .data$pre_pt_supervoxel_id,
                      post_id = .data$post_pt_root_id,
                      post_svid = .data$post_pt_supervoxel_id) %>%
        dplyr::filter(size>size.threshold) %>%
        dplyr::mutate(prepost = 1) %>%
        dplyr::select(.data$connector_id,
                      .data$pre_id, .data$post_id, .data$prepost,
                      .data$pre_svid, .data$post_svid, .data$size,
                      .data$X, .data$Y, .data$Z)
    }
    connectors.out <- crant_partners(id, partners = "output")
    if(nrow(connectors.out)){
      connectors.out.xyz <- do.call(rbind,connectors.out$pre_pt_position)
      connectors.out.xyz <- as.data.frame(connectors.out.xyz)
      colnames(connectors.out.xyz) <- c("X","Y","Z")
      connectors.out <- cbind(connectors.out,connectors.out.xyz)
      connectors.out <- connectors.out %>%
        dplyr::rename(connector_id = .data$id,
                      pre_id = .data$pre_pt_root_id,
                      pre_svid = .data$pre_pt_supervoxel_id,
                      post_id = .data$post_pt_root_id,
                      post_svid = .data$post_pt_supervoxel_id) %>%
        dplyr::filter(.data$size>size.threshold) %>%
        dplyr::mutate(prepost = 0) %>%
        dplyr::select(.data$connector_id,
                      .data$pre_id, .data$post_id, .data$prepost,
                      .data$pre_svid, .data$post_svid, .data$size,
                      .data$X, .data$Y, .data$Z)
    }
    connectors <- rbind(connectors.in,connectors.out)
  }else{
    connectors <- connectors %>%
      dplyr::filter(.data$post_id==id|.data$pre_id==id)
  }

  # Attach synapses
  if(nrow(connectors)){
    if(remove.autapses) {
      connectors=connectors[connectors$post_id!=connectors$pre_id,,drop=FALSE]
    }
    near <- nabor::knn(query = nat::xyzmatrix(connectors),
                       data = nat::xyzmatrix(x$d),k=1)
    connectors$treenode_id <- x$d[near$nn.idx,"PointNo"]
    x$connectors = as.data.frame(connectors, stringsAsFactors = FALSE)
  }else{
    connectors <- data.frame()
  }
  x$connectors <- connectors

  # Change class to work with connectivity functions in other packages
  class(x) <- union(c("synapticneuron"), class(x))

  # Return
  x
}

#' @rdname crant_add_synapses
#' @export
crant_add_synapses.neuronlist <- function(x,
                                         id = NULL,
                                         connectors = NULL,
                                         size.threshold = 5,
                                         remove.autapses = TRUE,
                                         update.id = TRUE,
                                         ...) {
  if(is.null(id)){
    x <- add_field_seq(x, entries= names(x), field = "id")
  }
  nat::nlapply(x,
               crant_add_synapses.neuron,
               id=NULL,
               connectors=connectors,
               size.threshold=size.threshold,
               remove.autapses=remove.autapses,
               ...)
}

#' @rdname crant_add_synapses
#' @export
crant_add_synapses.default <- function(x,
                                      id = NULL,
                                      connectors = NULL,
                                      size.threshold = 5,
                                      remove.autapses = TRUE,
                                      update.id = TRUE,
                                      ...) {
  stop("No method for class ", class(x))
}










