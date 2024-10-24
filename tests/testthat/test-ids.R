test_that("crant_xyz2id works", {
  expect_equal(crant_xyz2id(cbind(37306, 31317, 1405), rawcoords=TRUE),
               "576460752642283382")

  expect_equal(
    crant_xyz2id(cbind(37306, 31317, 1405), rawcoords=TRUE, root=F),
    "74452055821276049")
})

test_that("crant_islatest works", {
  expect_false(crant_islatest("576460752703346048"))
  expect_false(isTRUE(all.equal(
    crant_latestid("576460752703346048"), "576460752703346048")))
})

test_that("crant_ids works", {
  expect_equal(crant_ids("576460752703346048"), "576460752703346048")
  expect_equal(crant_ids("576460752703346048", integer64 = T), bit64::as.integer64("576460752703346048"))

  df1=data.frame(pt_root_id=bit64::as.integer64("576460752703346048"))
  df2=data.frame(id=bit64::as.integer64("576460752703346048"))

  expect_equal(crant_ids(df1, integer64 = F), "576460752703346048")
  expect_equal(crant_ids(df1), df1$pt_root_id)
  expect_equal(crant_ids(df2, integer64 = F), "576460752703346048")
})

test_that("crant_cellid_from_segid", {
  skip("Skipping crant_cellid_from_segid as crant doesn't yet have a proper cell_id table")
  rid=crant_latestid("576460752703346048")
  expect_equal(crant_cellid_from_segid(rid),12967L)
})
