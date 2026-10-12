#' Read L2 skeleton for crant neurons using pcg_skel
#'
#' This function reads level 2 (L2) node data for neuron segmentations in the crant ant brain connectome dataset.
#' It uses the pcg_skel Python library to create a skeleton object, which is then converted into a nat neuron object in R.
#'
#' @param ids A vector of one or more neuron segment IDs to read.
#' @param OmitFailures Logical; if TRUE, any segments that fail to be read are omitted from the results
#'   without an error (default=TRUE).
#' @param datastack_name An optional CAVE dataset name (expert use only, by default
#'   will choose the standard crant dataset). See details.
#' @param ... Additional arguments passed to internal functions.
#'
#' @details
#' `crant_read_l2skel` works by:
#' 1. Validating the input IDs using `crant_ids`.
#' 2. Using pcg_skel to generate a skeleton for each neuron segment.
#' 3. Converting the pcg_skel skeleton to an SWC format DataFrame.
#' 4. Converting the SWC DataFrame into a nat neuron object.
#'
#' This function relies on the pcg_skel Python library (https://github.com/AllenInstitute/pcg_skel)
#' for skeleton generation. Ensure that pcg_skel is installed in your Python environment.
#'
#' @return A `neuronlist` containing one or more `neuron` objects. Note that neurons
#'   will be calibrated in nanometers (nm).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # One-time installation of necessary Python packages
#' fafbseg::simple_python('none', pkgs='numpy~=1.23.5')
#' fafbseg::simple_python(pkgs="pcg_skel")
#'
#' # Read a single neuron
#' ant.neuron <- crant_read_l2skel("576460752653449509")
#'
#' # Plot the neuron
#' plot3d(ant.neuron)
#'
#' # Plot with crant surface (assuming crant.surf is available)
#' plot3d(crant.surf, alpha = 0.1, col = "lightgrey")
#' }
#'
#' @seealso
#' \code{\link{crant_ids}} for ID validation
#' \code{\link[nat]{neuron}} for details on the neuron object structure
#' \code{\link[nat]{neuronlist}} for details on the neuronlist object structure
#'
#' @references
#' pcg_skel Python library: https://github.com/AllenInstitute/pcg_skel
#'
#' @importFrom reticulate py_run_string
#' @importFrom nat nlapply as.neuron stitch_neurons_mst
crant_read_l2skel <- function(ids, OmitFailures=TRUE, datastack_name = crant_datastack_name(), ...) {

  # Make sure we have a good root ID
  ids<-crant_ids(ids)

  # Convert meshpart skeleton to SWC data frame
  # Define the updated Python function in R
  reticulate::py_run_string("
import pandas as pd
import numpy as np

def meshparty_skeleton_to_swc_dataframe(skel):
    # Extract vertices and edges
    vertices = skel.vertices
    edges = skel.edges

    # Create a dictionary to store node information
    node_info = {}

    # Initialize all nodes as endpoints (type 6)
    for i, coord in enumerate(vertices):
        node_info[i] = {
            'PointNo': i + 1,  # SWC index (1-based)
            'type': 6,   # Default to endpoint
            'X': coord[0],
            'Y': coord[1],
            'Z': coord[2],
            'W': 1.0,  # Default W (radius), adjust if you have actual data
            'Parent': -1  # Default parent to -1 (root)
        }

    # Update node types and parent information based on edges
    for edge in edges:
        parent, child = edge
        node_info[parent]['type'] = 3  # Set as basal dendrite, adjust as needed
        node_info[child]['type'] = 3   # Set as basal dendrite, adjust as needed
        node_info[child]['Parent'] = parent + 1  # Set parent (convert to 1-based index)

    # Find the root node (the one without a parent or with parent -1)
    root = [n for n, info in node_info.items() if info['Parent'] == -1][0]
    node_info[root]['type'] = 1  # Set root type

    # Create DataFrame
    df = pd.DataFrame.from_dict(node_info, orient='index')

    # Reorder columns to match desired SWC format
    df = df[['PointNo', 'type', 'X', 'Y', 'Z', 'W', 'Parent']]

    # Sort by node index
    df = df.sort_values('PointNo')

    return df
")

 # Run pcg_skel
 pcg <- check_pcg_skel()

 # Initialise CAVE client (once, reused for all IDs)
 # Use cave_client() directly to connect to proofreading.zetta.ai
 client <- cave_client(datastack_name)

 # Convert into natverse neuron
 py <- reticulate::py
 neurons <- nat::nlapply(ids, meshparty_to_nat, pcg=pcg, py=py, client=client, datastack_name=datastack_name, OmitFailures=OmitFailures, ...)
 names(neurons) <- sapply(neurons, function(x) x$id)
 neurons
}

# hidden
meshparty_to_nat <- function(id, pcg, py, client, datastack_name){
  skel <- pcg$pcg_skeleton(id, client=client, datastack_name=datastack_name)
  swc_df <- py$meshparty_skeleton_to_swc_dataframe(skel)
  a <- nat::as.neuron(swc_df)
  neuron <- nat::stitch_neurons_mst(a)
  neuron$id <- id
  neuron
}

# hidden
check_pcg_skel <- function (min_version = NULL, convert = FALSE){
  fafbseg:::check_reticulate()
  tryCatch(cv <- reticulate::import("pcg_skel", convert = convert),
           error = function(e) {
             stop(call. = F, "Please install the python fafbseg package:\n",
                  "This should normally work:\n", "fafbseg::simple_python(pkgs='pcg_skel')\n",
                  "For more details see ?simple_python", "\nDetailed error message: ",
                  e)
           })
  if (!is.null(min_version)) {
    warning("min_version not yet implemented for fafbseg")
  }
  cv
}

# # In python:
# import caveclient
# import pcg_skel
# client = caveclient.CAVEclient(
#   datastack_name="kronauer_ant",
#   server_address="https://proofreading.zetta.ai"
# )
# root_id = 576460752653449509
# skel = pcg_skel.pcg_skeleton(root_id=root_id, client=client)

#' Read L2 dotprops for CRANT neurons
#'
#' @description Fetches dotprops (points with tangent vectors) for CRANT
#'   neurons from the L2 cache. These are fast to fetch and suitable for NBLAST.
#'
#' @details Each L2 chunk contributes one point (its representative
#'   coordinate) and one vector (the first principal component of its voxels).
#'   Chunks missing from the L2 cache or without a `pca` attribute (very small
#'   chunks) are ignored.
#'
#'   This uses `get_l2_dotprops()` from the python fafbseg package (as does
#'   [fafbseg::read_l2dp()]), which fetches L2 ids and cache data in parallel.
#'   fafbseg does not know about the CRANT CAVE server, so a CRANT client is
#'   placed in its client cache before the call.
#'
#' @param units Units for the returned dotprops.
#' @param ... Additional arguments passed to python
#'   `fafbseg.flywire.get_l2_dotprops()`, e.g. `max_threads` or `min_size`.
#' @inheritParams crant_read_l2skel
#'
#' @return A `neuronlist` of `dotprops` objects named by root id.
#' @seealso [crant_read_l2skel()], [crant_mirror()]
#' @export
#'
#' @examples
#' \dontrun{
#' dps <- crant_read_l2dp(crant_ids("cell_type:ExR1"), units = "microns")
#' }
crant_read_l2dp <- function(ids, units = c("nm", "microns"),
                            OmitFailures = TRUE,
                            datastack_name = crant_datastack_name(), ...) {
  units <- match.arg(units)
  ids <- crant_ids(ids, unique = TRUE)
  fw <- fafbsegpy4crant(datastack_name)
  dps <- fw$get_l2_dotprops(ids, omit_failures = OmitFailures,
                            dataset = datastack_name, ...)
  dps <- fafbseg:::navis2nat_neuronlist(dps)
  # python fafbseg returns microns
  if (identical(units, "nm")) dps * 1e3 else dps
}

# fafbseg.flywire with a CRANT CAVE client in its client cache, so that its
# functions accept dataset=datastack_name
fafbsegpy4crant <- function(datastack_name = crant_datastack_name()) {
  fafbseg:::check_fafbsegpy()
  fw <- reticulate::import("fafbseg.flywire", convert = FALSE)
  client <- cave_client(datastack_name)
  # fafbseg replaces cached clients older than 30 min on Mondays
  dt <- reticulate::import("datetime", convert = FALSE)
  reticulate::py_set_attr(client, "_created_at", dt$datetime$now())
  reticulate::py_set_item(fw$utils$cave_clients, datastack_name, client)
  fw
}
