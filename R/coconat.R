# Coconat / coconatfly adapters for CRANTb. The heavy lifting lives in
# R/meta.R (crant_meta) and R/partners.R (crant_partner_summary); the
# functions here are thin shims that satisfy the coconat API.

# coconat metafun: receives resolved root ids (or NULL) and returns metadata.
# @noRd
coconat_crant_meta <- function(ids = NULL, ...) {
  crant_meta(ids = ids, normalise_colnames = TRUE, ...)
}

# coconat idfun: accepts root ids, query strings (`/class:descending`),
# the special tokens `'all'` and `'neurons'`, and returns a character
# vector of root ids.
# @noRd
coconat_crant_ids <- function(ids = NULL, ...) {
  if (is.null(ids)) return(NULL)
  if (is.character(ids) && length(ids) == 1) {
    if (identical(ids, "all"))
      return(crant_ids(crant_meta(normalise_colnames = TRUE)$id,
                       integer64 = FALSE, na.rm = TRUE))
    if (identical(ids, "neurons")) {
      md <- crant_meta(normalise_colnames = TRUE)
      keep <- is.na(md$class) | md$class != "glia"
      return(crant_ids(md$id[keep], integer64 = FALSE, na.rm = TRUE))
    }
    if (!fafbseg:::valid_id(ids) && !grepl("^/", ids))
      warning("All CRANTb queries are regex queries. ",
              "Use an initial / to suppress this warning!")
  }
  md <- crant_meta(ids = ids, normalise_colnames = TRUE, ...)
  crant_ids(md$id, integer64 = FALSE, na.rm = TRUE)
}

# coconat partnerfun. Behaviour preserved from the previous implementation:
# threshold-1 to align coconat's >= semantics with crant_partner_summary's >.
# @noRd
coconat_crant_partners <- function(ids,
                                   partners,
                                   threshold,
                                   version = crant_version(),
                                   ...) {
  crant_partner_summary(crant_ids(ids),
                        partners = partners,
                        threshold = threshold - 1L,
                        version = version,
                        ...)
}

#' Use CRANTb data with coconat for connectivity similarity
#'
#' @description
#' Register the CRANTb dataset with \href{https://github.com/natverse/coconat}{coconat},
#' a natverse R package for between- and within-dataset connectivity comparisons
#' using cosine similarity. Once registered, CRANTb participates in
#' \code{coconatfly::cf_*()} calls under the dataset name `"crant"`.
#'
#' @details
#' Metadata access goes through [crant_meta()], which is itself a wrapper
#' around [fafbseg::cam_meta()] with the seatable URL/token set locally for
#' the duration of each call. There is no separate cache to populate before
#' registering.
#'
#' @param showerror Logical; if `FALSE`, return invisibly when dependencies are
#'   missing instead of erroring.
#' @export
#' @seealso [crant_meta()], [crant_table_set_token()]
#'
#' @examples
#' \dontrun{
#' library(coconatfly)
#' register_crant_coconat()
#' cf_meta(cf_ids(crant = "/class:descending"))
#' cf_cosine_plot(cf_ids("/type:NSC", datasets = c("crant", "flywire")))
#' }
register_crant_coconat <- function(showerror = TRUE) {
  if (!requireNamespace("coconat", quietly = !showerror)) {
    if (!showerror) return(invisible(NULL))
    stop("Package 'coconat' is required for this function. ",
         "Install with: devtools::install_github('natverse/coconat')")
  }
  coconat::register_dataset(
    name = "crant",
    shortname = "cr",
    namespace = "coconatfly",
    sex = "F",
    metafun = coconat_crant_meta,
    idfun = coconat_crant_ids,
    partnerfun = coconat_crant_partners
  )
  invisible(NULL)
}
