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

test_that("crant_mirror keeps dotprops vectors, even for tiny neurons", {
  skip_if_not_installed("Morpho")
  # a line along y on the left mirrors to a line along y on the right
  pts <- cbind(150, seq(190, 200, length.out = 5), 130)
  dp <- nat::dotprops(pts, k = 3)
  tiny <- dp
  tiny$points <- tiny$points[1:2, ]
  tiny$vect <- tiny$vect[1:2, ]
  tiny$alpha <- tiny$alpha[1:2]
  nl <- nat::as.neuronlist(list(a = dp, b = tiny))
  m <- crant_mirror(nl, units = "microns")
  expect_s3_class(m, "neuronlist")
  expect_equal(names(m), names(nl))
  expect_equal(nrow(m$b$points), 2)
  expect_equal(sqrt(rowSums(m$a$vect^2)), rep(1, 5), tolerance = 1e-6)
  expect_gt(min(abs(m$a$vect[, 2])), 0.95)
  expect_equal(nat::xyzmatrix(m$a), nat::xyzmatrix(crant_mirror(pts, units = "microns")),
               ignore_attr = TRUE)
})
