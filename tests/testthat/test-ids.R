test_that("crant_xyz2id works", {
  skip_if_offline()
  skip_if_not(crant_token_available(),
              message="Unable to obtain a crant access token")
  skip_if_not(crant_scene_available(),
              message="Unable to build CRANT neuroglancer scene")
  # root_id changes with proofreading edits, so just check we get a valid ID
  rid <- crant_xyz2id(cbind(37306, 31317, 1405), rawcoords=TRUE)
  expect_type(rid, "character")
  expect_true(nchar(rid) >= 15)

  # supervoxel_id is stable
  expect_equal(
    crant_xyz2id(cbind(37306, 31317, 1405), rawcoords=TRUE, root=F),
    "74452055821276049")
})

test_that("crant_islatest works", {
  skip_if_offline()
  skip_if_not(crant_token_available(),
              message="Unable to obtain a crant access token")
  skip_if_not(crant_scene_available(),
              message="Unable to build CRANT neuroglancer scene")
  expect_false(crant_islatest("576460752684030043"))
  expect_false(isTRUE(all.equal(
    crant_latestid("576460752684030043"), "576460752684030043")))
})

test_that("crant_ids works", {
  expect_equal(crant_ids("576460752684030043"), "576460752684030043")
  expect_equal(crant_ids("576460752684030043", integer64 = T), bit64::as.integer64("576460752684030043"))

  df1=data.frame(pt_root_id=bit64::as.integer64("576460752684030043"))
  df2=data.frame(id=bit64::as.integer64("576460752684030043"))

  expect_equal(crant_ids(df1, integer64 = F), "576460752684030043")
  expect_equal(crant_ids(df1), df1$pt_root_id)
  expect_equal(crant_ids(df2, integer64 = F), "576460752684030043")
})

test_that("crant_cellid_from_segid", {
  skip("Skipping crant_cellid_from_segid as crant doesn't yet have a proper cell_id table")
  rid=crant_latestid("576460752684030043")
  expect_equal(crant_cellid_from_segid(rid),12967L)
})
