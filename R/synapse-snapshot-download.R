#' Download or publish CRANT synapse snapshots
#'
#' @description `crant_download_snapshot()` downloads the newest published
#'   synapse snapshots into your snapshot folder; select one with
#'   [crant_use_snapshot()] to use it. The first download fetches the static
#'   data and a full snapshot (several GB); later ones usually just fetch a few
#'   small checkpoints.
#'
#'   `crant_publish_snapshot()` is for whoever maintains the snapshots: it
#'   makes the newest snapshot in `root`, and the earlier checkpoints it is
#'   built on, available for download from a folder served over https.
#'
#' @details Snapshots are published with a `manifest.json` that lists every
#'   file with its size and md5. A download only fetches snapshots that are
#'   not already in `root` (snapshots never change once made) and checks each
#'   file's md5, so an interrupted download is never mistaken for a snapshot;
#'   just run it again. Downloads use the `curl` command line tool and resume
#'   partial files.
#'
#'   Publishing hard links the files into `dest` when it is on the same
#'   filesystem as `root` (otherwise they are copied), so it takes no extra
#'   space. `manifest.json` is written last.
#'
#' @param url The address of the published snapshots (the folder or its
#'   `manifest.json`). The default (`NULL`) uses the `crantr.snapshot_url`
#'   option if set, and otherwise the standard address, which needs access to
#'   the CRANT CAVE datastack to work out.
#' @param root The local snapshot folder. Defaults to [crant_snapshot_root()].
#' @return `crant_download_snapshot()`: the tags downloaded, invisibly.
#'   `crant_publish_snapshot()`: the manifest, invisibly.
#' @seealso [crant_use_snapshot()], [crant_update_snapshot()]
#' @export
#' @examples
#' \dontrun{
#' crant_download_snapshot()
#' }
crant_download_snapshot <- function(url = NULL,
                                    root = crant_snapshot_root(create = TRUE)) {
  crant_synsnap_check()
  if (is.null(url)) url <- crant_snapshot_url()
  tags <- aedes:::synsnap_download(url, root)
  message(if (length(tags)) paste("Downloaded synapse snapshot(s)",
                                  paste(tags, collapse = ", "))
          else "Synapse snapshots are already up to date")
  message("Use crant_use_snapshot() to query them")
  invisible(tags)
}

#' @rdname crant_download_snapshot
#' @param dest The folder to publish into.
#' @param snapshot The snapshot to publish; `"latest"` (the default) for the
#'   newest one in `root`.
#' @export
crant_publish_snapshot <- function(dest, root = crant_snapshot_root(),
                                   snapshot = "latest") {
  crant_synsnap_check()
  if (identical(snapshot, "latest")) snapshot <- aedes:::synsnap_latest(root)
  aedes:::synsnap_publish(root, dest, snapshot)
}

# Fetch newly published checkpoints into `root` if the last check was more
# than `hours` ago. A new full snapshot is only announced, since it is large.
# The time of the last check is kept in `root`, so new sessions don't check
# again straight away. Quiet unless something is downloaded or checks have
# been failing for over a day. Returns the tags downloaded.
crant_snapshot_refresh <- function(root,
                                   hours = getOption("crantr.snapshot_check_hours", 6)) {
  if (!is.finite(hours) || !dir.exists(root) || !nrow(aedes:::synsnap_tags(root)))
    return(invisible(character()))
  f <- file.path(root, ".last_check.json")
  st <- if (file.exists(f)) tryCatch(jsonlite::read_json(f), error = function(e) NULL)
  now <- Sys.time()
  if (!is.null(st$time) &&
      as.numeric(now) - as.numeric(aedes:::synsnap_parse_time(st$time)) < hours * 3600)
    return(invisible(character()))
  res <- tryCatch(aedes:::synsnap_download(crant_snapshot_url(), root, full = FALSE),
                  error = function(e) e)
  failed <- inherits(res, "error")
  since <- if (failed) {
    if (is.null(st$failing_since)) aedes:::synsnap_format_time(now)
    else st$failing_since
  }
  jsonlite::write_json(c(list(time = aedes:::synsnap_format_time(now)),
                         if (!is.null(since)) list(failing_since = since)),
                       f, auto_unbox = TRUE)
  if (failed) {
    if (as.numeric(now) - as.numeric(aedes:::synsnap_parse_time(since)) > 86400)
      message("Could not check for new synapse snapshots since ", since, ": ",
              conditionMessage(res))
    return(invisible(character()))
  }
  if (length(attr(res, "skipped")))
    message("A new full synapse snapshot is available; ",
            "fetch it with crant_download_snapshot()")
  invisible(as.character(res))
}

# Address of the published snapshots: the crantr.snapshot_url option, or the
# standard one. Its folder name is a hash of the L2 ids of a fixed (outdated,
# so unchanging) root id, so working it out needs access to the CRANT
# chunkedgraph (done once a session).
crant_snapshot_url <- function() {
  url <- getOption("crantr.snapshot_url")
  if (!is.null(url) && nzchar(url)) return(url)
  crant_snapshot_url_cave()
}

crant_snapshot_url_cave <- memoise::memoise(function() {
  l2 <- tryCatch(
    with_crant(fafbseg::flywire_l2ids("576460752684030043", integer64 = TRUE)),
    error = function(e) stop("Could not work out the snapshot address, which ",
                             "needs access to the CRANT CAVE datastack: ",
                             conditionMessage(e), call. = FALSE))
  paste0("https://flyemdev.mrc-lmb.cam.ac.uk/flyconnectome/crant/",
         aedes:::synsnap_l2_hash(l2), "/snapshot")
})
