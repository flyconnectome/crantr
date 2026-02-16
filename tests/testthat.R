library(testthat)
library(crantr)
if (identical(Sys.getenv("CRANT_ON_CI"), "true")) {
  # Only run this on CI
  simple_python("basic")
  # Token file is written by the GitHub Actions workflow;
  # only call crant_set_token() if it is missing
  secret_path <- file.path(Sys.getenv("HOME"), ".cloudvolume", "secrets", "proofreading.zetta.ai-cave-secret.json")
  if (!file.exists(secret_path) || file.size(secret_path) == 0) {
    message("No chunkedgraph secret found at: ", secret_path)
  }
  tryCatch(fafbseg::dr_fafbseg(), error = function(e) {
    message("dr_fafbseg() failed: ", e$message)
  })
}
test_check("crantr")
