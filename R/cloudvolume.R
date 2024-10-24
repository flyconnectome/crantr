# hidden
crant_cloudvolume <- function(...) {
  cv<-fafbseg::flywire_cloudvolume(cloudvolume.url = crant_cloudvolume_url(), ...)
  cv
}

# hidden
crant_cloudvolume_url <- function() {
  rr=with_crant(getOption("fafbseg.cloudvolume.url"))
  sub("graphene://middleauth+", "graphene://", rr, fixed = TRUE)
}

# hidden
crant_api_url <- function(endpoint="") {
  fafbseg:::flywire_api_url(endpoint=endpoint,
                            cloudvolume.url = crant_cloudvolume_url())
}

#' Print information about your crant setup including tokens and python modules
#'
#' @export
#' @seealso \code{\link{dr_fafbseg}}
#' @examples
#' \dontrun{
#' dr_crant()
#' }
#dr_crant <- bancr::dr_banc(with_dataset = crantr::with_crant)

# hidden
# crant_api_report <- bancr:::banc_api_report(with_dataset = crantr::with_crant)

