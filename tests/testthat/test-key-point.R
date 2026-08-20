test_that("crant_key_point returns a raw-space point for a known id", {
  test_id <- "576460752653449509"
  pt <- try(crant_key_point(test_id), silent = TRUE)
  skip_if(inherits(pt, "try-error") || any(is.na(pt)),
          "Skipping: CRANT L2 skeleton unavailable")

  m <- if (is.matrix(pt)) pt else matrix(pt, nrow = 1)
  expect_equal(dim(m), c(1L, 3L))
  expect_true(all(is.finite(m)))
  # raw crant voxel coords are positive
  expect_true(all(m > 0))

  # raw=FALSE returns nm; should differ from raw
  pt_nm <- try(crant_key_point(test_id, raw = FALSE), silent = TRUE)
  skip_if(inherits(pt_nm, "try-error") || any(is.na(pt_nm)),
          "Skipping: CRANT L2 skeleton unavailable for raw=FALSE branch")
  m_nm <- if (is.matrix(pt_nm)) pt_nm else matrix(pt_nm, nrow = 1)
  expect_false(isTRUE(all.equal(as.numeric(m), as.numeric(m_nm))))
})
