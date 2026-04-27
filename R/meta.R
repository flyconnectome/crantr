# Map between normalised crantr column names and the underlying CRANTb_meta
# seatable columns. Used both to translate query strings (so users can write
# `/class:descending` instead of `/super_class:descending`) and to rename
# columns on the way out.
.crant_meta_field_map <- c(
  class    = "super_class",
  subclass = "cell_class",
  type     = "cell_type",
  subtype  = "cell_subtype",
  instance = "cell_instance",
  lineage  = "hemilineage"
)

#' Return metadata about CRANTb neurons from the project seatable
#'
#' @description
#' `crant_meta()` is a thin wrapper around [fafbseg::cam_meta()] that points it
#' at the CRANTb seatable instance (`cloud.seatable.io`, table `CRANTb_meta`)
#' and normalises the returned column names. It supports the same query
#' grammar as `cam_meta()`, e.g. `crant_meta("/class:descending")` or
#' `crant_meta("/type:NSC")`. Plain root id vectors are also accepted.
#'
#' @details
#' Disk caching with delta sync is handled by
#' [fafbseg::flytable_cached_table()] under the hood, so repeated calls are
#' fast. Pass `expiry`, `refresh` etc. via `...` to control cache behaviour.
#'
#' Internally `crant_meta()` uses [withr::local_options()] to point
#' `fafbseg`'s flytable client at the CRANTb seatable and
#' [withr::local_envvar()] to temporarily pass `CRANTTABLE_TOKEN` through as
#' `FLYTABLE_TOKEN` before calling [fafbseg::cam_meta()]. Requires
#' `CRANTTABLE_TOKEN` to be set; see [crant_table_set_token()].
#'
#' @param ids Root ids (character/int64 vector) or a single query string such
#'   as `"/class:descending"` (see [fafbseg::cam_meta()]). `NULL` returns the
#'   full table.
#' @param ignore.case For query strings, whether to ignore case.
#' @param fixed For query strings, whether to treat queries as fixed strings
#'   rather than regular expressions.
#' @param version,timestamp Optional CAVE materialisation version / timestamp
#'   to which root ids in the returned table should be mapped.
#' @param unique Whether to drop duplicate `id` rows.
#' @param ... Passed to [fafbseg::cam_meta()] (and via that to
#'   [fafbseg::flytable_cached_table()]).
#'
#' @return A data.frame with at least an `id` column. Other columns include
#'   `class`, `subclass`, `type`, `subtype`, `instance`, `lineage`, `side`,
#'   `nerve`, `tract` (renamed from the underlying seatable columns; see
#'   `.crant_meta_field_map`). `side` is normalised to `"L"`/`"R"`.
#' @export
#' @seealso [fafbseg::cam_meta()], [crant_ids()], [crant_table_set_token()]
#'
#' @examples
#' \dontrun{
#' crant_meta("/class:descending")
#' crant_meta("/type:NSC")
#' crant_meta(c("576460752684030043", "576460752653449509"))
#' }
crant_meta <- function(ids = NULL, ignore.case = FALSE, fixed = FALSE,
                       version = NULL, timestamp = NULL, unique = FALSE, ...) {
  flytable_token <- Sys.getenv("CRANTTABLE_TOKEN", unset = NA_character_)
  if (is.na(flytable_token) || !nzchar(flytable_token))
    stop("CRANTTABLE_TOKEN not set. Use crant_table_set_token().")
  withr::local_options(list(fafbseg.flytable.url = "https://cloud.seatable.io/"))
  withr::local_envvar(c(FLYTABLE_TOKEN = flytable_token))
  ids <- crant_meta_translate_query(ids)
  df <- fafbseg::cam_meta(
    ids = ids,
    ignore.case = ignore.case,
    fixed = fixed,
    table = "CRANTb_meta",
    version = version,
    timestamp = timestamp,
    unique = unique,
    ...
  )
  crant_meta_normalise(df)
}

# Translate `/<normalised_field>:<value>` queries to the seatable column name
# expected by cam_meta. Bare tokens (e.g. `"ExR1"`) are mapped to
# `cell_type:<token>` to mirror cam_meta's bare-token convention while
# respecting the CRANTb_meta column naming. Pass-through for vectors of root
# ids and any query whose field is already a seatable column.
# @noRd
crant_meta_translate_query <- function(ids) {
  if (!(is.character(ids) && length(ids) == 1)) return(ids)
  has_slash <- substr(ids, 1, 1) == "/"
  q <- if (has_slash) substr(ids, 2, nchar(ids)) else ids
  if (!grepl(":", q, fixed = TRUE)) {
    if (!fafbseg:::valid_id(q) && grepl("^[A-Za-z]", q))
      return(paste0(if (has_slash) "/" else "", "cell_type:", q))
    return(ids)
  }
  parts <- strsplit(q, ":", fixed = TRUE)[[1]]
  if (length(parts) != 2) return(ids)
  if (parts[1] %in% names(.crant_meta_field_map))
    parts[1] <- unname(.crant_meta_field_map[parts[1]])
  paste0(if (has_slash) "/" else "", parts[1], ":", parts[2])
}

# Rename underlying seatable columns to crantr-canonical names and normalise
# `side` to L/R. Only renames columns that are present, so works for the
# subset of columns cam_meta may return.
# @noRd
crant_meta_normalise <- function(df) {
  if (!is.data.frame(df) || nrow(df) == 0)
    return(df)
  rename_map <- c(id = "root_id", .crant_meta_field_map)
  rename_map <- rename_map[rename_map %in% names(df)]
  if (length(rename_map))
    df <- dplyr::rename(df, !!!rename_map)
  if ("side" %in% names(df))
    df$side <- dplyr::recode(df$side, left = "L", right = "R")
  if ("id" %in% names(df))
    df$id <- as.character(df$id)
  df
}
