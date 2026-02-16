# Helper: check if choose_crant() / crant_scene() can succeed.
# crant_scene() fetches a neuroglancer state from global.daf-apis.com,
# which may require a different token than the CAVE proofreading.zetta.ai token.
crant_scene_available <- function() {
  !inherits(try(crant_scene(), silent = TRUE), "try-error")
}
