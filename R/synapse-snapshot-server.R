# Server cron job (see inst/scripts/synsnap-cron.sh): make missing
# materialisation version checkpoints, and 10:00 UTC ones for days without a
# version (CRANT versions are made at about 04:00 UTC), in `root` and publish
# them to `dest`. See aedes:::synsnap_server_update() for the other arguments.
crant_synsnap_server <- function(root, dest = NULL, at = 10 * 3600, ...) {
  crant_synsnap_check()
  # never fetch the published snapshots back into the folder they come from
  withr::local_options(crantr.snapshot_check_hours = Inf)
  vv <- crant_synsnap_versions()
  aedes:::synsnap_server_update(root, crant_synsnap_ctx(), dest = dest,
                                versions = vv[vv$ok, c("version", "timestamp")],
                                at = at, ...)
}

# all materialisation versions: version, timestamp, expires and ok (valid and
# available)
crant_synsnap_versions <- function(client = crant_cave_client())
  dplyr::bind_rows(lapply(client$materialize$get_versions_metadata(), function(m)
    data.frame(version = m$version, timestamp = m$time_stamp, expires = m$expires_on,
               ok = isTRUE(m$valid) && identical(m$status, "AVAILABLE"))))
