test_that("crant_read_l2dp returns dotprops in nm or microns", {
  ok <- try(crant_datastack_name(), silent = TRUE)
  skip_if(inherits(ok, "try-error"), "CRANT CAVE service unavailable")
  id <- try(suppressWarnings(
    crant_xyz2id(cbind(187344, 145536, 100044), rawcoords = FALSE)),
            silent = TRUE)
  skip_if(inherits(id, "try-error"), "CRANT CAVE service unavailable")
  dp <- crant_read_l2dp(id, progress = FALSE)
  expect_s3_class(dp, "neuronlist")
  expect_s3_class(dp[[1]], "dotprops")
  dpm <- crant_read_l2dp(id, units = "microns", progress = FALSE)
  expect_equal(nat::xyzmatrix(dpm[[1]]) * 1e3, nat::xyzmatrix(dp[[1]]),
               ignore_attr = TRUE)
  expect_gt(min(nat::xyzmatrix(dp[[1]])[, 1]), 1e4)
})
