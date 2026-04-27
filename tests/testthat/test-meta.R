test_that("crant_meta_translate_query maps crantr query aliases", {
  expect_equal(
    crant_meta_translate_query("/class:descending"),
    "/super_class:descending"
  )
  expect_equal(
    crant_meta_translate_query("type:NSC"),
    "cell_type:NSC"
  )
  expect_equal(
    crant_meta_translate_query("ExR1"),
    "cell_type:ExR1"
  )
  expect_equal(
    crant_meta_translate_query("576460752684030043"),
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
})

test_that("legacy cache compatibility wrapper remains available", {
  expect_true(exists("crant_meta_create_cache", mode = "function"))
  expect_true(exists("crant_meta_legacy", mode = "function"))
})
