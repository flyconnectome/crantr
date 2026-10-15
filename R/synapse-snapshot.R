#' Use a local snapshot of the CRANT synapse table
#'
#' Selects a downloaded snapshot of the CRANT synapse table so that
#' [crant_partner_summary()], [crant_partners()] and [crant_synapse_data()] can
#' answer queries locally, without contacting CAVE for synapses. Each snapshot
#' records the root id of both partners of every synapse at one moment in time.
#'
#' @details A snapshot folder contains `static.parquet` (one row per synapse,
#'   with its supervoxels, positions in nm and size) and one sub-folder per
#'   snapshot tag. A full snapshot has the root ids of every synapse; a
#'   checkpoint has only the synapses whose root ids changed since an earlier
#'   snapshot. Queries use DuckDB (from the suggested packages \pkg{duckdb},
#'   \pkg{DBI} and \pkg{dbplyr}) and only read the parts of the parquet files
#'   that they need. DuckDB uses every core; set the `aedes.duckdb_threads`
#'   option before the first query to use fewer, e.g. on a shared machine.
#'
#'   The snapshot code currently lives in the \pkg{aedes} package, which must
#'   be installed (see the vignette).
#'
#'   When no `snapshot` is given, the newest one at or before `timestamp` (or
#'   the time of `version`) is used, or the newest one of all when neither is
#'   given. Queries for times after the snapshot fetch the edits made since
#'   then from CAVE (see [crant_synapse_data()]).
#'
#'   If there is no snapshot in `root`, you are asked whether to download one
#'   with [crant_download_snapshot()] (in an interactive session) or get an
#'   error saying how to.
#'
#'   Every few hours (the `crantr.snapshot_check_hours` option, default 6;
#'   `Inf` turns this off) it also downloads any new checkpoints that have
#'   been published. A new full snapshot is only announced, since it is
#'   larger: fetch it with [crant_download_snapshot()].
#'
#' @param snapshot The snapshot tag, or `"latest"` for the most recent
#'   snapshot in `root`. The default (`NULL`) chooses one to match `version` or
#'   `timestamp`.
#' @param version,timestamp A CAVE materialisation version or a timestamp
#'   (including `"now"`) to choose the snapshot for.
#' @param root The snapshot folder. Defaults to [crant_snapshot_root()].
#' @param set Whether to make this the default snapshot for the session.
#'
#' @return When `set = TRUE`, the previous option values (invisibly, suitable
#'   for passing to [options()]). Otherwise a list with the snapshot `tag`,
#'   `timestamp` and `root`.
#' @seealso [crant_partner_summary()], [crant_synapse_data()]
#' @export
#' @examples
#' \dontrun{
#' crant_use_snapshot()
#' # now answered locally
#' crant_partner_summary("576460752684030043")
#' }
crant_use_snapshot <- function(snapshot = NULL, version = NULL, timestamp = NULL,
                               root = crant_snapshot_root(), set = TRUE) {
  crant_synsnap_check()
  explicit <- !is.null(version) || !is.null(timestamp)
  if (!is.null(snapshot) && explicit)
    stop("Give either a snapshot or a version/timestamp, not both", call. = FALSE)
  if (set) {
    crant_snapshot_check(root)
    crant_snapshot_refresh(root)
  }
  if (is.null(snapshot) && explicit) {
    when <- crant_synsnap_time(version, timestamp)
    if (identical(when, "now")) when <- Sys.time()
    snapshot <- aedes:::synsnap_at(root, when, locals = FALSE)
    if (is.null(snapshot)) {
      snapshot <- aedes:::synsnap_tags(root)$tag[1]
      message("No synapse snapshot is as old as ", crant_format_utc(when),
              ": queries for that time will use CAVE")
    }
  } else if (is.null(snapshot) || identical(snapshot, "latest"))
    snapshot <- aedes:::synsnap_latest(root)
  m <- aedes:::synsnap_meta(snapshot, root)
  root <- normalizePath(root, mustWork = TRUE)
  if (!set)
    return(list(tag = snapshot, timestamp = m$timestamp, root = root))
  message("Using synapse snapshot '", snapshot, "' (",
          crant_format_utc(m$timestamp), ")")
  invisible(options(crantr.synapse_snapshot_root = root,
                    crantr.synapse_snapshot = snapshot))
}

# The synapse snapshot code is in aedes until it moves to its own package
crant_synsnap_check <- function() {
  if (!requireNamespace("aedes", quietly = TRUE) ||
      utils::packageVersion("aedes") < "0.4.0.9000")
    stop("Local synapse snapshots need aedes >= 0.4.0.9000. Install it with ",
         "pak::pak(\"flyconnectome/aedes\")", call. = FALSE)
  aedes:::synsnap_check()
}

# Offer to download a snapshot when `root` has none, or say how to get one
crant_snapshot_check <- function(root) {
  if (dir.exists(root) && nrow(aedes:::synsnap_tags(root)))
    return(invisible(TRUE))
  msg <- paste0("No local synapse snapshot in ", root, ".")
  if (rlang::is_interactive() &&
      isTRUE(crant_ask_yes_no(paste(msg, "Download one now (several GB)?")))) {
    crant_download_snapshot(root = root)
    return(invisible(TRUE))
  }
  stop(msg, " Download one with crant_download_snapshot() (several GB, ",
       "needs access to the CRANT CAVE datastack) or see ",
       "vignette(\"synapse-snapshots\", package = \"crantr\")", call. = FALSE)
}

crant_ask_yes_no <- function(msg) utils::askYesNo(msg)

crant_format_utc <- function(x)
  if (identical(x, "now")) x else format(x, "%Y-%m-%d %H:%M:%S UTC", tz = "UTC")

# The time for a local query: "now" when neither is given (as for CAVE
# queries), otherwise a POSIXct
crant_synsnap_time <- function(version = NULL, timestamp = NULL) {
  if (!is.null(version) && !is.null(timestamp))
    stop("Give only one of version or timestamp", call. = FALSE)
  if (is.null(version) && (is.null(timestamp) || identical(timestamp, "now")))
    return("now")
  if (!is.null(timestamp))
    return(fafbseg::flywire_timestamp(timestamp = timestamp))
  crant_version_timestamp(version)
}

crant_version_timestamp <- function(version = "latest") with_crant(
  fafbseg::flywire_timestamp(version = fafbseg:::flywire_version(version)))

#' Folder for local CRANT synapse snapshots
#'
#' Returns the folder that the synapse snapshot functions use when no `root` is
#' given: the `crantr.synapse_snapshot_root` option if set, otherwise
#' `syn_snapshot` in the user data folder for the package (see
#' [tools::R_user_dir()]).
#'
#' @param create Whether to create the folder (and any missing parent folders)
#'   if it does not exist yet.
#' @return The path to the folder, with `~` expanded.
#' @seealso [crant_use_snapshot()]
#' @export
#' @examples
#' crant_snapshot_root()
crant_snapshot_root <- function(create = FALSE) {
  root <- getOption("crantr.synapse_snapshot_root",
                    file.path(tools::R_user_dir("crantr", "data"), "syn_snapshot"))
  root <- path.expand(root)
  if (create && !dir.exists(root) && !dir.create(root, recursive = TRUE))
    stop("Could not create synapse snapshot folder ", root, call. = FALSE)
  root
}

#' Bring a local CRANT synapse snapshot up to date
#'
#' Saves a new snapshot of the CRANT synapse table at a later time, by applying
#' the edits made since an existing snapshot. Queries at or near the new
#' snapshot time are then fast, since they need few or no CAVE lookups.
#'
#' @details Only synapses on neurons that were edited since `from` are looked
#'   up in CAVE, so updating a day-old snapshot typically takes seconds to
#'   minutes. The new snapshot is saved as a small checkpoint of the synapses
#'   whose root ids changed since `from`; use `rebase = TRUE` to also save a
#'   full snapshot that later checkpoints start from.
#'
#' @param timestamp The time for the new snapshot: `"now"` (the default),
#'   `"latest"` for the time of the newest CAVE materialisation version, a
#'   POSIXct or a string accepted by [as.POSIXct()].
#' @param from The snapshot to start from, or `"latest"` (the default) for the
#'   most recent published or full snapshot in `root` at or before
#'   `timestamp`.
#' @param tag The name of the new snapshot. Defaults to the timestamp, e.g.
#'   `"20261001T120000"`.
#' @param rebase Whether to also save the new snapshot as a full snapshot.
#' @inheritParams crant_use_snapshot
#' @return The result of [crant_use_snapshot()] for the new snapshot.
#' @seealso [crant_use_snapshot()]
#' @export
#' @examples
#' \dontrun{
#' crant_update_snapshot()
#' crant_partner_summary("576460752684030043", timestamp = "now")
#' }
crant_update_snapshot <- function(timestamp = "now", from = "latest",
                                  tag = NULL, root = crant_snapshot_root(),
                                  rebase = FALSE, set = TRUE) {
  crant_synsnap_check()
  ctx <- crant_synsnap_ctx()
  what <- if (identical(timestamp, "now")) "now"
  else if (identical(timestamp, "latest")) "latest materialisation"
  timestamp <- if (identical(timestamp, "now")) ctx$now()
  else if (identical(timestamp, "latest")) crant_version_timestamp("latest")
  else as.POSIXct(timestamp, tz = "UTC")
  if (identical(from, "latest")) {
    from <- aedes:::synsnap_at(root, timestamp, locals = FALSE)
    if (is.null(from))
      stop("No synapse snapshot in ", root, " is as old as ",
           crant_format_utc(timestamp), call. = FALSE)
  }
  ft <- aedes:::synsnap_meta(from, root)$timestamp
  if (is.null(tag) && abs(as.numeric(timestamp) - as.numeric(ft)) <= 1 && !rebase) {
    message("Synapse snapshot '", from, "' is already at ", crant_format_utc(timestamp))
    tag <- from
  } else {
    if (is.null(tag))
      tag <- format(timestamp, "%Y%m%dT%H%M%S", tz = "UTC")
    message("Updating synapse snapshot '", from, "' (", crant_format_utc(ft),
            ") to ", crant_format_utc(timestamp),
            if (!is.null(what)) paste0(" (", what, ")"))
    # a version time is kept exactly; others are rounded down to the ms
    aedes:::synsnap_update(from, tag, if (identical(what, "latest materialisation"))
      aedes:::synsnap_format_time(timestamp) else timestamp,
      root = root, ctx = ctx, kind = "local", overlap = 600)
    if (rebase)
      aedes:::synsnap_rebase(tag, root)
  }
  crant_use_snapshot(tag, root = root, set = set)
}

# the active snapshot: list(tag, timestamp, root) or NULL if none selected
crant_snapshot_active <- function(snapshot = getOption("crantr.synapse_snapshot"),
                                  root = getOption("crantr.synapse_snapshot_root")) {
  if (is.null(root) || is.null(snapshot)) return(NULL)
  crant_use_snapshot(snapshot, root = root, set = FALSE)
}

#' Lazy access to all synapses in a local snapshot
#'
#' Returns a lazy \pkg{dbplyr} table of every synapse in a local snapshot (see
#' [crant_use_snapshot()]) for use with \pkg{dplyr} verbs. Nothing is read
#' until you [dplyr::collect()] the result. This needs a local snapshot; there
#' is no CAVE equivalent.
#'
#' @details The table has columns `id`, `pre_root` and `post_root` (as
#'   `integer64`). With `details = TRUE` it also has `pre_sv`, `post_sv`,
#'   `pre_x`...`post_z` (positions of the pre and postsynaptic points in nm)
#'   and `size`.
#'
#'   Rows are sorted by `pre_root`, so filtering on a few `pre_root` values
#'   lets DuckDB skip most of the file. Use [bit64::as.integer64()] for root
#'   ids in filters.
#'
#'   With `timestamp`, the synapses are those of the newest snapshot at or
#'   before that time when it is at most `getOption("crantr.synapse_max_age",
#'   60)` seconds older. Otherwise the edits made since the newest published
#'   snapshot are looked up in CAVE (seconds to minutes) and kept in memory
#'   for the rest of the session. Nothing is written to disk; use
#'   [crant_update_snapshot()] to keep a checkpoint for later sessions.
#'
#' @param side `"post"` to read the copy sorted by `post_root` when the
#'   snapshot has one. `NULL` (the default) and `"pre"` read the copy sorted by
#'   `pre_root`.
#' @param details Whether to add supervoxel, position and size columns.
#' @param snapshot The snapshot tag, or `"latest"` for the most recent
#'   snapshot in `root`. Defaults to the one chosen by [crant_use_snapshot()].
#' @param timestamp A time (including `"now"`) to get the synapses at, in
#'   place of `snapshot`.
#' @inheritParams crant_use_snapshot
#' @return A lazy `tbl`.
#' @seealso [crant_use_snapshot()]
#' @export
#' @examples
#' \dontrun{
#' library(dplyr)
#' id <- bit64::as.integer64(crant_latestid("576460752684030043"))
#' crant_synapse_data("post") %>%
#'   filter(post_root == id) %>%
#'   count(pre_root, sort = TRUE) %>%
#'   collect()
#' }
crant_synapse_data <- function(side = NULL, details = FALSE,
                               snapshot = getOption("crantr.synapse_snapshot", "latest"),
                               root = crant_snapshot_root(), timestamp = NULL) {
  crant_synsnap_check()
  if (!is.null(side)) side <- match.arg(side, c("pre", "post"))
  if (is.null(timestamp)) {
    if (identical(snapshot, "latest")) snapshot <- aedes:::synsnap_latest(root)
    return(aedes:::synsnap_tbl(snapshot, root, side = side, static = details))
  }
  crant_snapshot_refresh(root)
  ctx <- crant_synsnap_ctx()
  when <- if (identical(timestamp, "now")) ctx$now()
  else as.POSIXct(timestamp, tz = "UTC")
  tag <- aedes:::synsnap_at(root, when, tol = 0)
  if (is.null(tag))
    stop("No synapse snapshot in ", root, " is as old as ",
         crant_format_utc(when), call. = FALSE)
  max_age <- getOption("crantr.synapse_max_age", 60)
  age <- as.numeric(when) - as.numeric(aedes:::synsnap_meta(tag, root)$timestamp)
  if (age <= max_age)
    return(aedes:::synsnap_tbl(tag, root, side = side, static = details))
  tag <- aedes:::synsnap_at(root, when, tol = 0, locals = FALSE)
  h <- aedes:::synsnap_head_at(tag, root, when, ctx, max_age = max_age)
  aedes:::synsnap_tbl(tag, root, side = side, static = details,
                      rows = aedes:::synsnap_view_sql(h, side))
}

# CAVE access for the synsnap code. Ids are passed as character: fafbseg sends
# integer64 ones as a binary body, which the CRANT chunkedgraph cannot decode.
crant_synsnap_ctx <- function() {
  list(
    delta_roots = function(past, future)
      with_crant(aedes:::cave_delta_roots(past, future)),
    rootid = function(sv, timestamp)
      with_crant(aedes:::cave_rootid_parallel(sv, timestamp)),
    # leaves of a root id never change, so caching is safe
    leaves = function(root) with_crant(fafbseg::flywire_leaves(
      as.character(root), integer64 = TRUE, cache = TRUE)),
    is_latest = function(roots, timestamp) with_crant(fafbseg::flywire_islatest(
      as.character(roots), timestamp = timestamp)),
    latest_id = function(roots, timestamp) bit64::as.integer64(with_crant(
      fafbseg::flywire_latestid(as.character(roots), timestamp = timestamp))),
    now = Sys.time)
}
