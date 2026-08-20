#' Find a good "key" point on a CRANT neuron to associate with annotations
#'
#' @description The chosen point sits at the major branch point of the L2
#'   skeleton of each neuron. By default the L2 skeleton is rerooted onto the
#'   endpoint furthest from the current root so that a simplified
#'   representation with one branch point can be calculated; without this, the
#'   longest path from the root may not contain a branch point at all. If no
#'   branch point can be identified the original root point is used as a
#'   fallback.
#'
#' @details Reads an L2 skeleton for each id via [crant_read_l2skel()] and
#'   picks the principal branch point with [fafbseg::key_point_from_neuron()].
#'
#'   Unlike the flywire and aedes datasets, the CRANT segmentation is hosted on
#'   a separate CAVE server (proofreading.zetta.ai), which the Python `fafbseg`
#'   package cannot currently target. This means [fafbseg::read_l2skel()] (and
#'   therefore [fafbseg::flywire_key_point()]) cannot reach it, so this function
#'   reads via `crant_read_l2skel()` (pcg_skel) rather than sharing the flywire
#'   read path. It is consequently slower than its flywire/aedes equivalent.
#'
#' @param ids One or more CRANT root ids (anything accepted by [crant_ids()]).
#' @param raw Whether to return points in raw (voxel) space (default) or nm.
#' @param reroot Whether to reroot the incoming neuron onto the furthest
#'   endpoint before simplifying.
#' @param ... Additional arguments passed to [crant_read_l2skel()].
#' @return An N x 3 matrix of point locations (one row per input id). Ids whose
#'   skeleton or key point could not be computed yield a row of `NA`s.
#' @seealso [fafbseg::key_point_from_neuron()], [crant_read_l2skel()]
#' @export
#' @examples
#' \dontrun{
#' crant_key_point("576460752653449509")
#' }
crant_key_point <- function(ids, raw = TRUE, reroot = TRUE, ...) {
  ids <- crant_ids(ids)
  nl <- crant_read_l2skel(ids, OmitFailures = TRUE, ...)
  res <- matrix(NA_real_, nrow = length(ids), ncol = 3L,
                dimnames = list(as.character(ids), c("X", "Y", "Z")))
  for (id in names(nl)) {
    nmpt <- tryCatch(
      fafbseg::key_point_from_neuron(nl[[id]], reroot = reroot),
      error = function(e) {
        warning("Unable to extract key point for id: ", id, ": ",
                conditionMessage(e))
        c(NA, NA, NA)
      })
    res[id, ] <- as.numeric(nmpt)
  }
  if (raw) crant_nm2raw(res) else res
}
