# Offline tests on a small synthetic snapshot "s1" built with the aedes
# synsnap code: roots 10, 20, 30 (0 = no root); supervoxels pre_sv = id + 100,
# post_sv = id + 200; positions in nm.
skip_if_no_synsnap <- function() {
  for (p in c("aedes", "duckdb", "DBI", "dbplyr")) skip_if_not_installed(p)
}

make_crant_snapshot <- function(root) {
  i64 <- bit64::as.integer64
  ids <- data.frame(
    id = 1:10,
    pre_root = i64(c(10, 10, 10, 10, 20, 20, 30, 10, 0, 30)),
    post_root = i64(c(20, 20, 20, 30, 10, 10, 10, 10, 10, 0)))
  static <- data.frame(id = ids$id, pre_sv = i64(ids$id + 100),
                       post_sv = i64(ids$id + 200),
                       pre_x = ids$id * 8L, pre_y = 1000L, pre_z = 42L,
                       post_x = ids$id * 8L + 4L, post_y = 1000L, post_z = 84L,
                       size = 5L)
  aedes:::synsnap_build_static(static, root,
                               columns = stats::setNames(names(static), names(static)))
  svmap <- data.frame(sv = c(static$pre_sv, static$post_sv),
                      root_id = c(ids$pre_root, ids$post_root))
  aedes:::synsnap_build("s1", svmap, "2026-01-01 00:00:00 UTC", root)
  root
}

# CAVE that has seen no edits since the snapshot
quiet_ctx <- function() list(
  delta_roots = function(past, future)
    list(old = bit64::integer64(), new = bit64::integer64()),
  rootid = function(sv, timestamp) stop("unexpected rootid lookup"),
  leaves = function(root) stop("unexpected leaves lookup"),
  is_latest = function(roots, timestamp) rep(TRUE, length(roots)),
  latest_id = function(roots, timestamp) roots,
  now = function() as.POSIXct("2026-01-01 00:00:30", tz = "UTC"))

test_that("snapshot folder and selection", {
  withr::local_options(crantr.synapse_snapshot_root = "~/syn")
  expect_equal(crant_snapshot_root(), path.expand("~/syn"))

  skip_if_no_synsnap()
  root <- make_crant_snapshot(withr::local_tempdir())
  withr::local_options(crantr.synapse_snapshot_root = root,
                       crantr.synapse_snapshot = NULL,
                       crantr.snapshot_check_hours = Inf)
  expect_equal(crant_use_snapshot(set = FALSE)$tag, "s1")
  expect_null(crant_snapshot_active())
  expect_message(crant_use_snapshot(), "'s1'")
  expect_equal(getOption("crantr.synapse_snapshot"), "s1")
  expect_equal(crant_snapshot_active()$tag, "s1")
  expect_error(crant_use_snapshot("s1", version = 1), "not both")
  expect_error(crant_use_snapshot(root = withr::local_tempdir()),
               "No local synapse snapshot")
})

test_that("crant_synapse_data", {
  skip_if_no_synsnap()
  root <- make_crant_snapshot(withr::local_tempdir())
  withr::local_options(crantr.synapse_snapshot_root = root,
                       crantr.synapse_snapshot = NULL)
  all <- dplyr::collect(crant_synapse_data())
  expect_equal(sort(all$id), 1:10)
  expect_s3_class(all$pre_root, "integer64")
  d <- dplyr::collect(crant_synapse_data("pre", details = TRUE))
  expect_true(all(c("pre_sv", "pre_x", "post_z", "size") %in% colnames(d)))
  expect_equal(d$post_x[d$id == 3], 28L)
})

test_that("local partner queries", {
  skip_if_no_synsnap()
  root <- make_crant_snapshot(withr::local_tempdir())
  withr::local_options(crantr.synapse_snapshot_root = root,
                       crantr.synapse_snapshot = "s1",
                       crantr.snapshot_check_hours = Inf)
  local_mocked_bindings(crant_synsnap_ctx = quiet_ctx)
  t1 <- as.POSIXct("2026-01-01", tz = "UTC")

  ps <- crant_partner_summary("10", timestamp = t1, method = "local")
  expect_equal(ps$post_id, c("20", "30"))
  expect_equal(ps$weight, c(3L, 1L))
  ps <- crant_partner_summary("10", partners = "inputs", timestamp = t1)
  expect_equal(ps$pre_id, c("20", "30"))
  expect_equal(ps$weight, c(2L, 1L))

  p <- crant_partners("30", partners = "output", timestamp = t1, method = "local")
  expect_equal(p$id, c(7L, 10L))
  expect_equal(p$pre_pt_position, c("56,1000,42", "80,1000,42"))
  expect_equal(as.character(p$post_pt_root_id), c("10", "0"))
  p <- crant_partners("30", partners = "input", timestamp = "now", method = "local")
  expect_equal(p$id, 4L)

  expect_error(crant_partner_summary("10", timestamp = t1, cleft.threshold = 5,
                                     method = "local"), "cleft.threshold")
  expect_error(crant_partner_summary("10", timestamp = t1 - 3600, method = "local"),
               "before snapshot")
  withr::local_options(crantr.synapse_snapshot = NULL)
  expect_error(crant_partner_summary("10", method = "local"),
               "No local synapse snapshot")
})

test_that("snapshot address", {
  skip_if_offline()
  skip_if_not_installed("aedes")
  skip_if_not(crant_token_available(),
              message = "Unable to obtain a crant access token")
  skip_if_not(crant_scene_available(),
              message = "Unable to build CRANT neuroglancer scene")
  expect_match(crant_snapshot_url_cave(),
               "^https://flyemdev.mrc-lmb.cam.ac.uk/flyconnectome/crant/[0-9a-f]{64}/snapshot$")
})
