test_that("crant_meta_translate_query only maps aliases when requested", {
  expect_equal(
    crant_meta_translate_query("/class:descending"),
    "/class:descending"
  )
  expect_equal(
    crant_meta_translate_query("ExR1"),
    "ExR1"
  )
  expect_equal(
    crant_meta_translate_query("/class:descending", normalise_colnames = TRUE),
    "/super_class:descending"
  )
  expect_equal(
    crant_meta_translate_query("type:NSC", normalise_colnames = TRUE),
    "cell_type:NSC"
  )
  expect_equal(
    crant_meta_translate_query("ExR1", normalise_colnames = TRUE),
    "cell_type:ExR1"
  )
  expect_equal(
    crant_meta_translate_query("576460752684030043", normalise_colnames = TRUE),
    "576460752684030043"
  )
})

test_that("crant_meta_normalise renames metadata columns", {
  df <- data.frame(
    root_id = c("1", "2"),
    super_class = c("descending", "glia"),
    cell_type = c("NSC", "GliaType"),
    side = c("left", "right"),
    stringsAsFactors = FALSE
  )

  out <- crant_meta_normalise(df)

  expect_equal(out$id, c("1", "2"))
  expect_equal(out$class, c("descending", "glia"))
  expect_equal(out$type, c("NSC", "GliaType"))
  expect_equal(out$side, c("L", "R"))
  expect_equal(df$root_id, c("1", "2"))
  expect_equal(df$super_class, c("descending", "glia"))
})

test_that("crant_meta passes translate_ids through to cam_meta", {
  withr::local_envvar(c(CRANTTABLE_TOKEN = "dummy"))
  captured <- NULL
  testthat::local_mocked_bindings(
    cam_meta = function(..., translate_ids) {
      captured <<- translate_ids
      data.frame()
    },
    .package = "fafbseg"
  )
  crant_meta("576460752684030043", translate_ids = TRUE)
  expect_true(captured)

  crant_meta("576460752684030043")
  expect_equal(captured, NA)
})

test_that("legacy cache compatibility wrapper remains available", {
  expect_true(exists("crant_meta_create_cache", mode = "function"))
  expect_true(exists("crant_meta_legacy", mode = "function"))
})
