# Build the static synapse data and the first full CRANT synapse snapshot from
# a CAVE table download made with synapse-cave-download.py.
#
#   Rscript synsnap-build.R DOWNLOAD_DIR SNAPSHOT_ROOT [--sample]
#
# Supervoxel -> root ids come from the materialised roots in the download.
# Roots are immutable, so a materialised root that is still the latest at the
# version timestamp is right for every supervoxel it was given; only
# supervoxels with a stale (already superseded) root are looked up again in the
# chunkedgraph. The snapshot is then checked against the chunkedgraph for a
# random sample of synapses. --sample allows an incomplete download (for
# testing on a fraction of the table).
#
# Uses the unexported synsnap code in aedes until it moves to its own package.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("usage: synsnap-build.R DOWNLOAD_DIR SNAPSHOT_ROOT [--sample]")
src <- path.expand(args[1])
root <- path.expand(args[2])
sample_run <- "--sample" %in% args

library(crantr)

man <- jsonlite::read_json(file.path(src, "manifest.json"))
chunks <- sort(Sys.glob(file.path(src, "chunk-*.parquet")))
n_chunks <- length(seq(0, man$max_id, by = man$width))
if (length(chunks) != n_chunks && !sample_run)
  stop("Download has ", length(chunks), " of ", n_chunks, " chunks")
tag <- paste0("v", man$version)
when <- aedes:::synsnap_parse_time(man$timestamp)

# CAVE access for the synsnap code (cf aedes:::aedes_synsnap_ctx)
ctx <- list(
  rootid = function(sv, timestamp) with_crant(aedes:::cave_rootid_parallel(sv, timestamp)),
  # character ids: fafbseg sends integer64 ones as a binary body, which the
  # CRANT chunkedgraph cannot decode
  is_latest = function(roots, timestamp) with_crant(fafbseg::flywire_islatest(
    as.character(roots), timestamp = timestamp, cache = FALSE)))

step <- aedes:::synsnap_step
dir.create(root, recursive = TRUE, showWarnings = FALSE)
con <- aedes:::synsnap_con()
files <- sprintf("read_parquet([%s])",
                 paste(aedes:::synsnap_sql_str(chunks), collapse = ", "))

# 1. static.parquet ----
if (!file.exists(file.path(root, "static.json"))) step("Writing static.parquet",
  aedes:::synsnap_build_static(chunks, root, format = "parquet", overwrite = TRUE,
    columns = c(id = "id", pre_sv = "pre_pt_supervoxel_id",
                post_sv = "post_pt_supervoxel_id",
                pre_x = "pre_pt_position_x", pre_y = "pre_pt_position_y",
                pre_z = "pre_pt_position_z", post_x = "post_pt_position_x",
                post_y = "post_pt_position_y", post_z = "post_pt_position_z",
                size = "size"),
    meta = list(source_table = man$table, source_version = man$version,
                source_timestamp = man$timestamp, position_units = "nm")))

# 2. supervoxel -> root map, with stale roots replaced ----
stage <- file.path(root, ".staging", paste0(tag, ".svmap"))
dir.create(stage, recursive = TRUE, showWarnings = FALSE)
pairs <- file.path(stage, "pairs.parquet")
if (!file.exists(pairs)) step("Collecting supervoxel -> root pairs",
  aedes:::synsnap_write(con, sprintf(
    "SELECT DISTINCT sv, root_id FROM (
       SELECT pre_pt_supervoxel_id AS sv, pre_pt_root_id AS root_id FROM %1$s
       UNION ALL SELECT post_pt_supervoxel_id, post_pt_root_id FROM %1$s)
     ORDER BY sv", files), pairs))
pq <- aedes:::synsnap_sql_str(pairs)
n <- DBI::dbGetQuery(con, sprintf(
  "SELECT count(*) AS pairs, count(DISTINCT sv) AS svs, count(DISTINCT root_id) AS roots
   FROM %s", pq))
message(format(n$pairs, big.mark = ","), " pairs, ", format(n$svs, big.mark = ","),
        " supervoxels, ", format(n$roots, big.mark = ","), " roots")

# is_latest for every root, in resumable batches
latest <- file.path(stage, "latest")
dir.create(latest, showWarnings = FALSE)
roots <- DBI::dbGetQuery(con, sprintf(
  "SELECT DISTINCT root_id FROM %s ORDER BY root_id", pq))$root_id
batch <- split(seq_along(roots), ceiling(seq_along(roots) / 1e5))
step(sprintf("Checking %s roots are the latest", format(length(roots), big.mark = ",")), {
  for (i in seq_along(batch)) {
    f <- file.path(latest, sprintf("batch-%05d.parquet", i))
    if (file.exists(f)) next
    r <- roots[batch[[i]]]
    ok <- aedes:::synsnap_retry(function() ctx$is_latest(r, when))
    if (length(ok) != length(r) || anyNA(ok))
      stop("is_latest returned ", length(ok), " values (", sum(is.na(ok)),
           " NA) for ", length(r), " roots")
    arrow::write_parquet(data.frame(root_id = r, latest = ok), paste0(f, ".tmp"))
    file.rename(paste0(f, ".tmp"), f)
    if (i %% 10 == 0) message(format(Sys.time(), "%H:%M:%S "), i, "/", length(batch))
  }
})
lq <- sprintf("read_parquet(%s)", aedes:::synsnap_sql_str(file.path(latest, "*.parquet")))

stale <- DBI::dbGetQuery(con, sprintf(
  "SELECT DISTINCT p.sv FROM %s p JOIN %s l USING (root_id) WHERE NOT l.latest
   ORDER BY sv", pq, lq))$sv
fixed <- file.path(stage, "fixed.parquet")
if (!file.exists(fixed)) step(sprintf(
  "Looking up %s supervoxels with stale roots", format(length(stale), big.mark = ",")),
  arrow::write_parquet(data.frame(
    sv = stale, root_id = bit64::as.integer64(
      if (length(stale)) aedes:::synsnap_retry(function() ctx$rootid(stale, when))
      else integer())), fixed))
message("Stale roots: ", DBI::dbGetQuery(con, sprintf(
  "SELECT count(*) AS n FROM %s WHERE NOT latest", lq))$n, " (",
  format(length(stale), big.mark = ","), " supervoxels)")

svmap <- file.path(stage, "svmap.parquet")
aedes:::synsnap_write(con, sprintf(
  "SELECT DISTINCT p.sv, coalesce(f.root_id, p.root_id) AS root_id
   FROM %s p LEFT JOIN read_parquet(%s) f USING (sv)", pq,
  aedes:::synsnap_sql_str(fixed)), svmap)

# 3. the snapshot, checked against the chunkedgraph ----
verify <- function(stg, n = 10000) {
  st <- DBI::dbGetQuery(con, sprintf(
    "SELECT s.id, s.pre_sv, s.post_sv, r.pre_root, r.post_root
     FROM %s s JOIN %s r USING (id) USING SAMPLE %d ROWS",
    aedes:::synsnap_sql_str(file.path(root, "static.parquet")),
    aedes:::synsnap_sql_str(file.path(root, stg, "by_pre.parquet")), n))
  bad <- sum(ctx$rootid(st$pre_sv, when) != st$pre_root |
               ctx$rootid(st$post_sv, when) != st$post_root)
  if (bad) stop(bad, " of ", nrow(st), " sampled synapses differ from the chunkedgraph")
  message("Checked ", nrow(st), " random synapses against the chunkedgraph")
}
step(paste("Building snapshot", tag),
     aedes:::synsnap_build(tag, svmap, when, root, verify = verify))
unlink(stage, recursive = TRUE)
