# Legacy in-memory CRANTb meta cache
#
# This file preserves the original closure-based metadata cache that used to
# live in R/coconat.R. It is superseded by R/meta.R, which wires
# `fafbseg::cam_meta()` directly into the CRANTb seatable via
# `getOption("fafbseg.flytable.url")` (the pattern used by `aedes::aedes_meta`).
# The legacy reader remains available for scripts that still rely on the old
# in-memory cache. The old cache-builder entry point is kept as a deprecated
# compatibility wrapper, with cli messages linking to the relevant docs.

#' Legacy in-memory cache for CRANTb meta data (deprecated)
#'
#' @description
#' `crant_meta_create_cache()` and `crant_meta_legacy()` reproduce the previous
#' closure-based metadata cache from earlier versions of crantr. They are
#' retained only so that existing scripts can be migrated; new code should use
#' [crant_meta()] which delegates to [fafbseg::cam_meta()] and gets
#' transparent disk caching, delta sync, and query parsing for free.
#'
#' @param use_seatable Whether to build CRANTb meta data from the internal
#'   seatable (development) or the `cell_info` CAVE table (production, never
#'   implemented).
#' @param return Logical; if `TRUE`, return the cache tibble.
#' @param ids Vector of neuron/root ids to select, or `NULL` for all.
#'
#' @return Invisibly returns the cache (data.frame) if `return=TRUE`;
#'   otherwise invisibly `NULL`. `crant_meta_legacy()` returns a tibble.
#' @keywords internal
#' @name crant_meta_legacy
#' @seealso [crant_meta()]
NULL

#' Deprecated compatibility wrapper for the legacy metadata cache
#'
#' @rdname crant_meta_legacy
#' @export
crant_meta_create_cache <- NULL # Placeholder, assigned below

#' @rdname crant_meta_legacy
#' @export
crant_meta_legacy <- NULL # Placeholder, assigned below

local({
  .crant_meta_cache <- NULL

  .crant_doc_link <- function(topic, label = sprintf("%s()", topic)) {
    cli::style_hyperlink(
      label,
      sprintf("https://flyconnectome.github.io/crantr/reference/%s.html", topic)
    )
  }

  .refresh_cache <- function(use_seatable = TRUE) {
    if (use_seatable) {
      crant.meta <- crant_table_query(
        "SELECT root_id, super_class, cell_class, cell_type, cell_subtype, cell_instance, hemilineage, side, nerve, tract from CRANTb_meta"
      )
      crant.meta %>%
        dplyr::rename(
          id = root_id,
          class = super_class,
          subclass = cell_class,
          type = cell_type,
          subtype = cell_subtype,
          instance = cell_instance,
          lineage = hemilineage
        ) %>%
        dplyr::mutate(
          id = as.character(id),
          side = dplyr::recode(side, left = "L", right = "R")
        )
    } else {
      stop("Meta data CAVE table not yet implemented")
    }
  }

  .populate_legacy_cache <- function(
    use_seatable = nzchar(Sys.getenv("CRANTTABLE_TOKEN")),
    return = FALSE
  ) {
    if (!use_seatable)
      warning("No CRANTTABLE_TOKEN found; seatable access unavailable. ",
              "Set token with crant_table_set_token().")
    meta <- .refresh_cache(use_seatable = use_seatable)
    .crant_meta_cache <<- meta
    if (return) meta else invisible()
  }

  crant_meta_create_cache <<- function(
    use_seatable = nzchar(Sys.getenv("CRANTTABLE_TOKEN")),
    return = FALSE
  ) {
    cli::cli_warn(c(
      "{.fn crant_meta_create_cache} is deprecated.",
      "i" = paste0(
        "Use ", .crant_doc_link("crant_meta"),
        " instead, which now handles caching transparently."
      ),
      "i" = paste0(
        "For access to the legacy metadata cache please use ",
        .crant_doc_link("crant_meta_legacy"),
        " after populating it with ",
        .crant_doc_link("crant_meta_legacy", "crant_meta_create_cache()"),
        "."
      )
    ))
    .populate_legacy_cache(
      use_seatable = use_seatable,
      return = return
    )
  }

  crant_meta_legacy <<- function(ids = NULL) {
    cli::cli_inform(c(
      "{.fn crant_meta_legacy} uses the legacy in-memory metadata cache.",
      "i" = paste0(
        "Use ", .crant_doc_link("crant_meta"),
        " instead for new code; use ", .crant_doc_link("crant_meta_legacy"),
        " only when you specifically need the old cache behavior."
      ),
      "i" = paste0(
        "For access to the legacy metadata cache please use ",
        .crant_doc_link("crant_meta_legacy"),
        " instead of ",
        .crant_doc_link("crant_meta", "crant_meta()"),
        "."
      )
    ))
    if (is.null(.crant_meta_cache)) {
      warning("No CRANTb meta cache loaded. ",
              "Run crant_meta_create_cache() to populate it.")
      crant_meta_create_cache()
    }
    meta <- .crant_meta_cache
    if (!is.null(ids)) {
      ids <- extract_ids(unname(unlist(ids)))
      ids <- tryCatch(crant_ids(ids), error = function(e) NULL)
      meta %>% dplyr::filter(.data$id %in% ids)
    } else {
      meta
    }
  }
})

# hidden — shared by legacy code and coconat adapters
extract_ids <- function(x) {
  if (is.character(x) && length(x) == 1 && !fafbseg:::valid_id(x, na.ok = TRUE) &&
      !grepl("http", x) &&
      grepl("^\\s*(([a-z:]{1,3}){0,1}[0-9,\\s]+)+$", x, perl = TRUE)) {
    sx <- gsub("[a-z:,\\s]+", " ", x, perl = TRUE)
    x <- scan(text = trimws(sx), sep = " ", what = "", quiet = TRUE)
    x <- fafbseg:::id64(x)
  }
  if (is.numeric(x) || is.integer(x))
    x <- fafbseg:::id64(x)
  x
}
