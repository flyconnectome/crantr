#' Summarise the connectivity of CRANTb neurons
#'
#' Returns synaptically connected partners for specified neurons. Understanding
#' synaptic partnerships is crucial for analyzing neural circuits in the CRANTb
#' connectome.
#'
#' @details note that the rootids you pass in must be up to date. See example.
#'
#' @param rootids Character vector specifying one or more crant rootids. As a
#'   convenience this argument is passed to \code{\link{crant_ids}} allowing you
#'   to pass in data.frames, crant URLs or simple ids.
#' @param partners Character vector, either "outputs" or "inputs" to specify the direction of synaptic connections to retrieve.
#' @param threshold Integer threshold for minimum number of synapses (default 0).
#' @param remove_autapses Logical, whether to remove self-connections (default TRUE).
#' @param cleft.threshold Numeric threshold for cleft filtering (default 0).
#' @param datastack_name An optional CAVE \code{datastack_name}. If unset a
#'   sensible default is chosen.
#' @param synapse_table Character, the name of the synapse CAVE table you wish to use. Defaults to the latest.
#' @param ... Additional arguments passed to \code{\link[fafbseg]{flywire_partner_summary}}
#'
#' @return a data.frame
#' @seealso \code{\link{flywire_partner_summary}}, \code{\link{crant_latestid}}
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic connectivity analysis
#' sample_id=crant_latestid("576460752716912866")
#' head(crant_partner_summary(sample_id))
#' head(crant_partner_summary(sample_id, partners='inputs'))
#' }
#' @rdname crant_partner_summary
crant_partner_summary <- function(rootids,
                                 partners = c("outputs", "inputs"),
                                 synapse_table = c("synapses_v2"),
                                 threshold = 0,
                                 remove_autapses = TRUE,
                                 cleft.threshold = 0,
                                 datastack_name=NULL,
                                 ...) {
  synapse_table <- match.arg(synapse_table)
  if(is.null(datastack_name))
    datastack_name = crant_datastack_name()
  with_crant(
    fafbseg::flywire_partner_summary(
      rootids,
      threshold = threshold,
      partners=partners,
      datastack_name = datastack_name,
      remove_autapses = remove_autapses,
      cleft.threshold = cleft.threshold,
      synapse_table=synapse_table,
      method = "cave",
      ...
    )
  )
}

#' @description \code{crant_partners} returns details of each unitary synaptic
#' connection (including its xyz location).
#'
#'
#' @examples
#' \dontrun{
#' # plot input and output synapses of a neuron
#' nclear3d()
#' fpi=crant_partners(crant_latestid("576460752716912866"), partners='in')
#' points3d(crant_raw2nm(fpi$post_pt_position), col='cyan')
#' fpo=crant_partners(crant_latestid("576460752716912866"), partners='out')
#' points3d(crant_raw2nm(fpo$pre_pt_position), col='red')
#' }
#' @export
#' @rdname crant_partner_summary
crant_partners <- function(rootids,
                          partners=c("input", "output"),
                          synapse_table = c("synapses_v2"),
                          ...) {
  synapse_table = match.arg(synapse_table)
  partners=match.arg(partners)
  rootids=crant_ids(rootids)
  fcc=crant_cave_client()
  pyids=fafbseg:::rids2pyint(rootids)
  res=if(partners=='input') {
    reticulate::py_call(fcc$materialize$synapse_query, post_ids=pyids, synapse_table=synapse_table, ...)
  } else {
    reticulate::py_call(fcc$materialize$synapse_query, pre_ids=pyids, synapse_table=synapse_table, ...)
  }
  fafbseg:::pandas2df(res)
}








