test_that("changelog works", {
  skip_if_offline()
  skip_if_not(with_crant(bancr:::banc_token_available()),
              message="Unable to obtain a crant access token")
  expect_s3_class(res <- crant_change_log("576460752688452655"), "data.frame")
  expect_named(res, c("operation_id", "timestamp", "user_id", "before_root_ids",
                      "after_root_ids", "is_merge", "user_name", "user_affiliation"))
})
