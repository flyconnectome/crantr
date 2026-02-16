test_that("crant_scene works", {
  skip_if_offline()
  skip_if_not(crant_token_available(),
              message="Unable to obtain a crant access token")
  skip_if_not(crant_scene_available(),
              message="Unable to build CRANT neuroglancer scene")
  expect_type(sc <- crant_scene("576460752688452655"), 'character')
})
