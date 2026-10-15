#' Summarise the connectivity of CRANTb neurons
#'
#' Returns synaptically connected partners for specified neurons. Understanding
#' synaptic partnerships is crucial for analyzing neural circuits in the CRANTb
#' connectome.
#'
#' @details note that the rootids you pass in must be up to date. See example.
#'
#'   Local queries (`method = "local"`) give the same results from a downloaded
#'   synapse snapshot without contacting CAVE for synapses, when the query
#'   time is no earlier than the snapshot. Edits made since the snapshot are
#'   fetched from CAVE (see [crant_synapse_data()]). They support the
#'   `synapses_v2` table with `cleft.threshold = 0` and the default
#'   `datastack_name` only.
#'
#' @param rootids Character vector specifying one or more crant rootids. As a
#'   convenience this argument is passed to \code{\link{crant_ids}} allowing you
#'   to pass in data.frames, crant URLs or simple ids.
#' @param partners Character vector, either "input" or "output" to specify the direction of synaptic connections to retrieve.
#' @param threshold Integer threshold for minimum number of synapses (default 0).
#' @param remove_autapses Logical, whether to remove self-connections (default TRUE).
#' @param cleft.threshold Numeric threshold for cleft filtering (default 0).
#' @param datastack_name An optional CAVE \code{datastack_name}. If unset a
#'   sensible default is chosen.
#' @param synapse_table Character, the name of the synapse CAVE table you wish to use. Defaults to the latest.
#' @param version,timestamp A CAVE materialisation version or a timestamp
#'   (including `"now"`) for the query. The default (both `NULL`) is the
#'   current time.
#' @param method Whether to query CAVE or a local synapse snapshot (see
#'   [crant_use_snapshot()]). `"auto"` (the default) uses the selected local
#'   snapshot when there is one and the query can be answered from it,
#'   otherwise CAVE.
#' @param ... Additional arguments passed to \code{\link[fafbseg]{flywire_partner_summary}}
#'   (CAVE queries only)
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
                                 version = NULL,
                                 timestamp = NULL,
                                 method = c("auto", "cave", "local"),
                                 ...) {
  synapse_table <- match.arg(synapse_table)
  partners <- match.arg(partners)
  method <- match.arg(method)
  snap <- crant_synsnap_choose(method, version, timestamp,
                               cleft.threshold = cleft.threshold,
                               datastack_name = datastack_name, ...)
  if (!is.null(snap)) {
    # plain ids are checked against the snapshot's root log, which is cheaper
    # than updating them through CAVE
    return(aedes:::synsnap_partner_summary(
      crant_ids(rootids), partners = partners, tag = snap$tag, root = snap$root,
      threshold = threshold, remove_autapses = remove_autapses,
      timestamp = snap$when, ctx = crant_synsnap_ctx(),
      max_age = getOption("crantr.synapse_max_age", 60),
      f = getOption("crantr.synapse_head_ratio", 0.3),
      min_sv = getOption("crantr.synapse_head_min_sv", 5e4)))
  }
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
      version = version,
      timestamp = timestamp,
      method = "cave",
      ...
    )
  )
}

# crant_partners from a local snapshot, with CAVE-style column names and
# positions (nm) as "x,y,z" strings
crant_partners_local <- function(rootids, partners, snap) {
  side <- if (partners == "input") "post" else "pre"
  col <- paste0(side, "_root")
  ids <- as.character(unique(rootids))
  tb <- if (identical(snap$when, "now") ||
            as.numeric(snap$when) - as.numeric(snap$timestamp) > 1)
    crant_synapse_data(side, details = TRUE, root = snap$root, timestamp = snap$when)
  else crant_synapse_data(side, details = TRUE, snapshot = snap$tag, root = snap$root)
  res <- dplyr::collect(dplyr::filter(tb, .data[[col]] %in% ids))
  res <- dplyr::arrange(res, .data$id)
  dplyr::tibble(
    id = res$id,
    pre_pt_root_id = res$pre_root, post_pt_root_id = res$post_root,
    pre_pt_supervoxel_id = res$pre_sv, post_pt_supervoxel_id = res$post_sv,
    pre_pt_position = nat::xyzmatrix2str(cbind(res$pre_x, res$pre_y, res$pre_z)),
    post_pt_position = nat::xyzmatrix2str(cbind(res$post_x, res$post_y, res$post_z)),
    size = res$size)
}

# The snapshot to answer a partner query from: list(tag, timestamp, root,
# when) or NULL to use CAVE. Errors for method = "local" when no snapshot can.
crant_synsnap_choose <- function(method, version, timestamp, ...) {
  if (method == "cave") return(NULL)
  snap <- if (requireNamespace("aedes", quietly = TRUE)) crant_snapshot_active()
  if (is.null(snap)) {
    if (method == "local")
      stop("No local synapse snapshot selected. See ?crant_use_snapshot",
           call. = FALSE)
    return(NULL)
  }
  when <- crant_synsnap_time(version, timestamp)
  if (identical(when, "now") || as.numeric(when) > as.numeric(snap$timestamp))
    crant_snapshot_refresh(snap$root)
  # start from the newest snapshot at or before the query time
  tag <- aedes:::synsnap_at(snap$root,
                            if (identical(when, "now")) Sys.time() else when,
                            locals = FALSE)
  if (!is.null(tag) && !identical(tag, snap$tag))
    snap <- crant_use_snapshot(tag, root = snap$root, set = FALSE)
  why <- crant_synsnap_problem(snap, when, ...)
  if (!is.null(why)) {
    if (method == "local")
      stop("Cannot use the local synapse snapshot: ", why, call. = FALSE)
    return(NULL)
  }
  c(snap, list(when = when))
}

# NULL if a query can be answered from snapshot `snap` at `when`, otherwise a
# string saying why not
crant_synsnap_problem <- function(snap, when, cleft.threshold = 0,
                                  datastack_name = NULL, ...) {
  bad <- c(if (!isTRUE(cleft.threshold == 0)) "cleft.threshold",
           if (!is.null(datastack_name) &&
               !identical(datastack_name, crant_datastack_name())) "datastack_name",
           names(list(...)))
  if (length(bad))
    return(paste("argument(s)", paste(bad, collapse = ", "),
                 "are only supported for CAVE queries"))
  if (!identical(when, "now") && as.numeric(when) < as.numeric(snap$timestamp) - 1)
    return(sprintf("requested time %s is before snapshot '%s' time %s",
                   crant_format_utc(when), snap$tag,
                   crant_format_utc(snap$timestamp)))
  NULL
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
                          version = NULL,
                          timestamp = NULL,
                          method = c("auto", "cave", "local"),
                          ...) {
  synapse_table = match.arg(synapse_table)
  partners=match.arg(partners)
  method = match.arg(method)
  rootids=crant_ids(rootids)
  snap = crant_synsnap_choose(method, version, timestamp, ...)
  if (!is.null(snap))
    return(crant_partners_local(rootids, partners, snap))
  fcc=crant_cave_client()
  pyids=fafbseg:::rids2pyint(rootids)
  when = c(if (!is.null(version)) list(materialization_version = as.integer(version)),
           if (!is.null(timestamp) && !identical(timestamp, "now"))
             list(timestamp = fafbseg:::ts2pydatetime(timestamp)))
  res=if(partners=='input') {
    do.call(reticulate::py_call, c(list(fcc$materialize$synapse_query, post_ids=pyids,
                                        synapse_table=synapse_table), when, list(...)))
  } else {
    do.call(reticulate::py_call, c(list(fcc$materialize$synapse_query, pre_ids=pyids,
                                        synapse_table=synapse_table), when, list(...)))
  }
  # Flatten array-valued position columns to strings before R conversion
  # to avoid REAL()/character type mismatch in Arrow/reticulate (numpy arrays
  # in position columns can't be directly converted to R numeric vectors)
  tryCatch({
    cols <- res$columns$tolist()
    pos_cols <- grep("_position$", cols, value = TRUE)
    for (col in pos_cols) {
      res[[col]] <- res[[col]]$astype("str")
    }
  }, error = function(e) NULL)
  tryCatch(
    fafbseg:::pandas2df(res),
    error = function(e) {
      # Arrow conversion can fail for some neurons (e.g. mixed column types);
      # fall back to reticulate conversion
      reticulate::py_to_r(res)
    }
  )
}








