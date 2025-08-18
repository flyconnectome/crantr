#' Create or refresh cache of CRANTb meta information
#'
#' @description
#' `crant_meta_create_cache()` builds or refreshes an in-memory cache of CRANTb metadata
#' for efficient repeated lookups. You can choose the data source using `use_seatable`.
#' The main accessor function [crant_meta()] will always use the most recently created cache.
#'
#' @details
#' CRANTb meta queries can be slow; caching avoids repeated computation/database access.
#' Whenever labels are updated, simply rerun this function to update the cache.
#'
#' @param use_seatable Whether to build CRANTb meta data from the `cell_info` CAVE table
#' (production) or our internal seatable (development). Both require different types of authenticated
#' access, for details see `crantr` documentation.
#' @param return Logical; if `TRUE`, return the cache tibble/invisible.
#'
#' @return Invisibly returns the cache (data.frame) if `return=TRUE`; otherwise invisibly `NULL`.
#' @export
#'
#' @examples
#' \dontrun{
#' #' # Requires authenticated access to CRANTb CAVE
#' crant_meta_cache(use_seatable=FALSE)
#'
#' crant_meta_create_cache(use_seatable=TRUE) # create cache
#' ## CRANTbTABLE_TOKEN must be set, see crantr package
#' result <- crant_meta() # use cache
#'
#' # use cache to quickly make plot
#' library(coconatfly)
#' register_crant_coconat()
#' cf_cosine_plot(cf_ids('/type:NSC', datasets = c("crant", "flywire")))
#' }
crant_meta_create_cache <- NULL # Placeholder, assigned below

#' Query cached CRANTb meta data
#'
#' @description
#' Returns results from the in-memory cache, filtered by `ids` if given.
#' Cache must be created first using [crant_meta_create_cache()].
#'
#' @details
#' `crant_meta()` never queries databases directly.
#' If `ids` are given, filters the meta table by root_id.
#'
#' @param ids Vector of neuron/root IDs to select, or `NULL` for all.
#' @return tibble/data.frame, possibly filtered by ids.
#' @export
#' @seealso [crant_meta_create_cache()]
#'
#' @examples
#' \dontrun{
#' crant_meta_create_cache() # build the cache
#' all_meta <- crant_meta()  # retrieve all
#' }
crant_meta <- NULL # Placeholder, assigned below

# hidden
crant_meta <- local({
  .crant_meta_cache <- NULL

  .refresh_cache <- function(use_seatable=TRUE) {
    if (use_seatable) {
      # Read from seatable
      crant.meta <- crant_table_query(
        "SELECT root_id, side, cell_type, cell_class, cell_subtype from CRANTb_meta"
      )
      crant.meta %>%
        dplyr::rename(
          id = root_id,
          class = cell_class,
          type = cell_type,
          side = side,
          subclass = cell_subtype
        ) %>%
        dplyr::mutate(id = as.character(id))
    } else {
      stop("Meta data CAVE table not yet implemented")
    #   crant.community.meta <- crant_cell_info() %>%
    #     dplyr::filter(valid == 't') %>%
    #     dplyr::arrange(pt_root_id, tag) %>%
    #     dplyr::distinct(pt_root_id, tag2, tag, .keep_all = TRUE) %>%
    #     dplyr::group_by(pt_root_id, tag2) %>%
    #     dplyr::summarise(
    #       tag = {
    #         if (length(tag) > 1 && any(grepl("?", tag, fixed = TRUE))) {
    #           usx = unique(sub("?", "", tag, fixed = TRUE))
    #           if (length(usx) < length(tag)) tag = usx
    #         }
    #         paste0(tag, collapse = ";")
    #       },
    #       .groups = 'drop'
    #     ) %>%
    #     tidyr::pivot_wider(
    #       id_cols = pt_root_id,
    #       names_from = tag2,
    #       values_from = tag,
    #       values_fill = ""
    #     ) %>%
    #     dplyr::select(
    #       id = pt_root_id,
    #       class = `primary class`,
    #       type = `neuron identity`,
    #       side = `soma side`,
    #       subclass = `anterior-posterior projection pattern`
    #     ) %>%
    #     dplyr::mutate(class = gsub(" ","_", class))
    #
    #   crant.codex.meta <- crant_codex_annotations() %>%
    #     dplyr::distinct(pt_root_id, .keep_all = TRUE) %>%
    #     dplyr::select(
    #       id = pt_root_id,
    #       class = cell_class,
    #       type = cell_type,
    #       side = side,
    #       subclass = cell_subtype
    #     )
    #
    #   rbind(
    #     crant.codex.meta,
    #     crant.community.meta
    #   ) %>%
    #     dplyr::distinct(id, .keep_all = TRUE) %>%
    #     dplyr::mutate(id = as.character(id))
    }
  }
  list(
    create_cache = function(use_seatable=FALSE, return = FALSE) {
      meta <- .refresh_cache(use_seatable=use_seatable)
      .crant_meta_cache <<- meta
      if (return) meta else invisible()
    },
    get_meta = function(ids = NULL) {
      if (is.null(.crant_meta_cache)){
        warning("No CRANTb meta cache loaded. Creating with crant_meta_create_cache(use_seatable=FALSE)")
        crant_meta_create_cache(use_seatable=FALSE)
      }
      meta <- .crant_meta_cache
      if (!is.null(ids)) {
        ids <- extract_ids(unname(unlist(ids)))
        ids <- tryCatch(crant_ids(ids), error = function(e) NULL)
        meta %>% dplyr::filter(id %in% ids)
      } else {
        meta
      }
    }
  )
})

# Exported user-friendly functions
crant_meta_create_cache <- crant_meta$create_cache
crant_meta <- crant_meta$get_meta

# crant_coconat.R
coconat_crant_meta <- function(ids) {
  crant_meta(ids)
}

# hidden
extract_ids <- function (x) {
  if (is.character(x) && length(x) == 1 && !fafbseg:::valid_id(x,
                                                               na.ok = T) && !grepl("http", x) && grepl("^\\s*(([a-z:]{1,3}){0,1}[0-9,\\s]+)+$",
                                                                                                        x, perl = T)) {
    sx = gsub("[a-z:,\\s]+", " ", x, perl = T)
    x = scan(text = trimws(sx), sep = " ", what = "", quiet = T)
    x <- fafbseg:::id64(x)
  }
  if (is.numeric(x) || is.integer(x)) {
    x <- fafbseg:::id64(x)
  }
  x
}

# hidden
coconat_crant_ids <- function(ids=NULL) {
  if(is.null(ids)) return(NULL)
  # extract numeric ids if possible
  ids <- extract_ids(ids)
  if(is.character(ids) && length(ids)==1 && !fafbseg:::valid_id(ids)) {
    # query
    metadf=crant_meta()
    if(isTRUE(ids=='all')) return(crant_ids(metadf$id, integer64 = F))
    if(isTRUE(ids=='neurons')) {
      ids <- metadf %>%
        filter(is.na(class) | class!='glia') %>%
        pull(id)
      return(crant_ids(ids, integer64 = F))
    }
    if(isTRUE(substr(ids, 1, 1)=="/"))
      ids=substr(ids, 2, nchar(ids))
    else warning("All CRANTb queries are regex queries. ",
                 "Use an initial / to suppress this warning!")
    if(!grepl(":", ids)) ids=paste0("type:", ids)
    qsplit=stringr::str_match(ids, pattern = '[/]{0,1}(.+):(.+)')
    field=qsplit[,2]
    value=qsplit[,3]
    if(!field %in% colnames(metadf)) {
      stop(glue("CRANTb queries only work with these fields: ",
                paste(colnames(metadf)[-1], collapse = ',')))
    }
    ids <- metadf %>%
      filter(grepl(value, .data[[field]])) %>%
      pull(id)
  } else if(length(ids)>0) {
    # check they are valid for current materialisation
    crant_latestid(ids, version = crant_version())
  }
  return(crant_ids(ids, integer64 = F))
}

# minimal version of this function
coconat_crant_partners <- function(ids,
                                  partners,
                                  threshold,
                                  version=crant_version(),
                                  ...) {
  tres=crant_partner_summary(crant_ids(ids),
                            partners = partners,
                            threshold = threshold-1L,
                            version=version,
                            ...)
  # partner_col=grep("_id", colnames(tres), value = T)
  # for(pc in partner_col){
  #   tres[[pc]] <- as.character(tres[[pc]])
  # }
  # metadf=crant_meta()
  # colnames(metadf)[[1]]=partner_col
  # tres=left_join(tres, metadf, by = partner_col)
  tres
}

#' Use CRANTb data with coconat for connectivity similarity
#'
#' @description
#' Register the CRANTb dataset with \href{https://github.com/natverse/coconat}{coconat},
#' a natverse R package for between and within dataset connectivity comparisons using cosine similarity.
#'
#' @details
#' `register_crant_coconat()` registers `crantr`-backed functionality for use with
#'
#' @param showerror Logically, error-out silently or not.
#' @export
#' @seealso [crant_meta_create_cache()]
#'
#' @examples
#' \dontrun{
#' library(coconatfly)
#' library(bancr)
#' crant_meta_create_cache(use_seatable=TRUE)
#' banc_meta_create_cache(use_seatable=TRUE)
#' register_crant_coconat()
#' register_banc_coconat()
#' cf_cosine_plot(cf_ids('/type:NSC', datasets = c("crant", "banc")))
#' }
register_crant_coconat <- function(showerror=TRUE){
  if (!requireNamespace("coconat", quietly = TRUE)) {
    stop("Package 'coconat' is required for this function. Please install it with: devtools::install_github(natverse/coconat)")
  }
  if(requireNamespace('coconatfly', quietly = !showerror))
    coconat::register_dataset(
      name = 'crant',
      shortname = 'cr',
      namespace = 'coconatfly',
      metafun = coconat_crant_meta,
      idfun = coconat_crant_ids,
      partnerfun = coconat_crant_partners
    )
}
