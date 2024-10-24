test_that("banc_scene works", {
  expect_type(sc <- crant_scene("576460752688452655"), 'character')
})
