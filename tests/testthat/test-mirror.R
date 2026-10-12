test_that("crant_mirror flips points across the midline and back", {
  skip_if_not_installed("Morpho")
  pts <- rbind(c(120, 200, 130), c(280, 180, 100), c(190, 250, 150))
  m <- crant_mirror(pts, units = "microns")
  # midline is at x ~ 200 um but is not quite a plane; y and z change little
  expect_lt(max(abs(m[, 1] - (400 - pts[, 1]))), 20)
  expect_lt(max(abs(m[, 2:3] - pts[, 2:3])), 10)
  expect_lt(max(abs(crant_mirror(m, units = "microns") - pts)), 1)
  # nm and microns agree
  expect_equal(crant_mirror(pts * 1e3), m * 1e3)
})

test_that("crant_mirror keeps the class of nat objects", {
  skip_if_not_installed("Morpho")
  pts <- cbind(seq(100, 160, length.out = 20), 200, 130)
  dp <- nat::dotprops(pts * 1e3, k = 5)
  dpm <- crant_mirror(dp)
  expect_s3_class(dpm, "dotprops")
  expect_true(all(nat::xyzmatrix(dpm)[, 1] > 202e3))
})
