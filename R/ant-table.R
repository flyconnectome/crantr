#' @title Read and write to the seatable for draft CRANT annotations
#'
#' @description These functions use the logic and wrap some code
#' from the `flytable_.*` functions in the `fafbseg` R package.
#' \code{crant_table_set_token} will obtain and store a permanent
#'   seatable user-level API token.
#'   \code{crant_table_query} performs a SQL query against a crant_table
#'   database. You can omit the \code{base} argument unless you have tables of
#'   the same name in different bases.
#'   \code{crant_table_base} returns a \code{base} object (equivalent to
#'   a mysql database) which allows you to access one or more tables, logging in
#'   to the service if necessary. The returned base object give you full access
#'   to the Python
#'   \href{https://seatable.github.io/seatable-scripts/python/base/}{\code{Base}}
#'    API allowing a range of row/column manipulations.
#'    \code{crant_table_update_rows} updates existing rows in a table, returning TRUE on success.
#'
#' @param sql A SQL query string. See examples and
#'   \href{https://seatable.github.io/seatable-scripts/python/query/}{seatable
#'   docs}.
#' @param limit An optional limit, which only applies if you do not specify a
#'   limit directly in the \code{sql} query. By default seatable limits SQL
#'   queries to 100 rows. We increase the limit to 100000 rows by default.
#' @param convert Expert use only: Whether or not to allow the Python seatable
#'   module to process raw output from the database. This is is principally for
#'   debugging purposes. NB this imposes a requirement of seatable_api >=2.4.0.
#' @param python Logical. Whether to return a Python pandas DataFrame. The default of FALSE returns an R data.frame
#' @param base Character vector specifying the \code{base}
#' @param table Character vector specifying a table foe which you want a
#'   \code{base} object.
#' @param workspace_id A numeric id specifying the workspace. Advanced use only
#   since we can normally figure this out from \code{base_name}.
# @param cached Whether to use a cached base object
#' @param token normally retrieved from \code{CRANTTABLE_TOKEN} environment
#'   variable.
#' @param user,pwd crant_table user and password used by \code{crant_table_set_token}
#'   to obtain a token
#' @param url Optional URL to the server
#' @param ac A seatable connection object as returned by \code{crant_table_login}.
#' @param df A data.frame containing the data to upload including an `_id`
#' column that can identify each row in the remote table.
#' @param append_allowed Logical. Whether rows without row identifiers can be appended.
#' @param chunksize To split large requests into smaller ones with max this many rows.
#' @param token_name The name of the token in your .Renviron file, should be \code{CRANTTABLE_TOKEN}.
#' @param root_ids the CRANTb root ids to update, must be present in the seatable.
#' @param column the column in the seatable to update for the given `root_ids`.
#' @param update the replacement entries you want in the chosen `column` for the given `root_ids`.
#' @param overwrite whether or to overwrite entries in the chosen `column` for the given `root_ids`.
#' @param append if `overwrite==FALSE`, then whether or to append (separated by a `,`) entries in the chosen `column` for the given `root_ids`.
#' @param ... additional arguments passed to pbsapply which might include cl=2 to specify a number of parallel jobs to run.
#'
#' @return a \code{data.frame} of results. There should be 0 rows if no rows
#'   matched query.
#'
#' @seealso \code{fafbseg::\link{flytable_query}}
#' @examples
#' \dontrun{
#' # Do this once
#' crant_table_set_token(user="MY_EMAIL_FOR_SEATABLE.com",
#'                     pwd="MY_SEATABLE_PASSWORD",
#'                     url="https://cloud.seatable.io/")
#'
#' # Thereafter:
#' crant.meta <- crant_table_query()
#'
#' # A simple way to add annotations to specific neurons in the table quickly
#' # this is just for one entry type for one chosen column
#'crant_table_annotate(root_ids = c("576460752667713229",
#'                               "576460752662519193",
#'                               "576460752730083020",
#'                               "576460752673660716",
#'                               "576460752662521753"),
#'                  update = "lindsey_lopes",
#'                  overwrite = FALSE,
#'                  append = FALSE,
#'                  column = "user_annotator")
#' }
#' @export
#' @rdname crant_table_query
crant_table_query <- function(sql = "SELECT * FROM CRANTb_meta",
                             limit = 200000L,
                             base = "CRANTb",
                             python = FALSE,
                             convert = TRUE,
                             ac = NULL,
                             workspace_id = "62919",
                             token_name = "CRANTTABLE_TOKEN"){
  bancr::banctable_query(sql = sql,
                         limit = limit,
                         base = base,
                         python = python,
                         convert = convert,
                         ac = ac,
                         token_name = token_name,
                         workspace_id = workspace_id)
}

#' @export
#' @rdname crant_table_query
crant_table_set_token <- function(user,
                                pwd,
                                url = "https://cloud.seatable.io/",
                                token_name = "CRANTTABLE_TOKEN"){
  bancr::banctable_set_token(user = user,
                             pwd = pwd,
                             url = url,
                             token_name = token_name)
}

#' @export
#' @rdname crant_table_query
crant_table_login <- function(url = "https://cloud.seatable.io/",
                            token = Sys.getenv("CRANTTABLE_TOKEN",
                                               unset = NA_character_)){
  bancr::banctable_login(url = url,
                         token = token)
}

#' @export
#' @rdname crant_table_query
crant_table_update_rows <- function(df,
                                   table = "CRANTb_meta",
                                   base = "CRANTb",
                                   append_allowed = FALSE,
                                   chunksize = 1000L,
                                   workspace_id = "62919",
                                   token_name = "CRANTTABLE_TOKEN",
                                   ...) {
  bancr::banctable_update_rows(df = df,
                        table = table,
                        base = base,
                        append_allowed = append_allowed,
                        chunksize = chunksize,
                        token_name=token_name,
                        workspace_id=workspace_id,
                        ...)
}

# hidden
crant_table_base <- function(base = "CRANTb",
                          table = NULL,
                          url = "https://cloud.seatable.io/",
                          token_name = "CRANTTABLE_TOKEN",
                          workspace_id = "62919",
                          cached = TRUE,
                          ac = NULL) {
  bancr:::banctable_base(base_name = base,
                 table = table,
                 url = url,
                 token_name = token_name,
                 workspace_id = workspace_id,
                 cached = cached,
                 ac = ac)
}

#' @export
#' @rdname crant_table_query
crant_table_append_rows <- function (df,
                                    table,
                                    base = NULL,
                                    chunksize = 1000L,
                                    token_name = "CRANTTABLE_TOKEN",
                                    workspace_id = "62919",
                                    ...) {
  bancr::banctable_append_rows(
    df = df,
    table = table,
    base = base,
    chunksize = chunksize,
    workspace_id = workspace_id,
    token_name = token_name,
    workspace_id = workspace_id,
    ...
  )
}

# Update the CRANT IDs
#' @export
#' @rdname crant_table_query
crant_table_updateids <- function(table = "CRANTb_meta",
                                  base = "CRANTb"){

  # Get current table
  cat('reading CRANT meta seatable...\n')
  ac <- crant_table_query(sql = sprintf('select _id, root_id, supervoxel_id, position from %s',table),
                          base = base) %>%
    dplyr::select(!!rlang::sym("root_id"),
                  !!rlang::sym("supervoxel_id"),
                  !!rlang::sym("position"),
                  !!rlang::sym("_id"))
  ac[ac=="0"] <- NA
  ac[ac==""] <- NA

  # Update root IDs directly where needed
  ac.new <- crant_updateids(ac,
                            root.column = "root_id",
                            supervoxel.column = "supervoxel_id",
                            position.column = "position")

  # Update
  cat('updating CRANTb_meta seatable...\n')
  ac.new[is.na(ac.new)] <- ''
  ac.new[ac.new=="0"] <- ''
  crant_table_update_rows(df = ac.new,
                        base = "CRANTb",
                        table = "CRANTb_meta",
                        append_allowed = FALSE,
                        chunksize = 1000)
  cat('done.\n')

  # Return
  invisible()
}

# Annotate the table easily
#' @export
#' @rdname crant_table_query
crant_table_annotate <- function(root_ids,
                              update,
                              overwrite = FALSE,
                              append = FALSE,
                              column="notes",
                              table = "CRANTb_meta",
                              base = "CRANTb",
                              workspace_id = "62919",
                              token_name = "CRANTTABLE_TOKEN"){
  # Get current table
  column <- column[1]
  update <- update[1]
  cat(sprintf('updating %s with %s ... \n',column, update))
  cat('reading banc meta seatable...\n')
  ac <- crant_table_query(sql = sprintf('select _id, root_id, supervoxel_id, %s from %s',column, table),
                          base = base,
                          workspace_id = workspace_id,
                          token_name = token_name) %>%
    dplyr::filter(!!rlang::sym("root_id") %in% root_ids)

  # Rest of the function stays the same but use !!sym() for dynamic column references
  if(!nrow(ac)){
    message(sprintf("root_ids not in table %s",table))
    return(invisible())
  }
  ac[ac=="0"] <- NA
  ac[ac==""] <- NA

  # Update
  cat(sprintf('updating column: %s ...\n', column))
  ac.new <- ac
  if(overwrite){
    cat(sprintf('overwriting column: %s ...\n', column))
    ac.new[[column]] <- NA
  }else if(append){
    cat(sprintf('appending to column: %s ...\n', column))
    ac.new <- ac.new %>%
      dplyr::rowwise() %>%
      dplyr::mutate(update = dplyr::case_when(
        is.na(!!rlang::sym(column)) ~ update,
        TRUE ~ paste(!!rlang::sym(column), update, sep = ", ", collapse = ", ")
      ))
  }else{
    ac.new <- ac.new %>%
      dplyr::rowwise() %>%
      dplyr::mutate(update = dplyr::case_when(
        is.na(!!rlang::sym(column)) ~ update,
        TRUE ~ !!rlang::sym(column)
      ))
  }
  ac.new[[column]][is.na(ac.new[[column]])] <- "NA"
  changed <- sum(ac.new[[column]] != ac.new$update, na.rm = TRUE)
  ac.new[[column]] <- ac.new$update
  ac.new$update <- NULL

  # Summarise update
  message("changed ", changed, " rows")
  cat(sprintf("%s before update: \n",column))
  if(nrow(ac.new)==1){
    knitr::kable(ac[[column]])
  }else{
    knitr::kable(sort(table(ac[[column]])))
  }
  cat(sprintf("\n %s after update: \n",column))
  if(nrow(ac.new)==1){
    knitr::kable(ac.new[[column]])
  }else{
    knitr::kable(sort(table(ac.new[[column]])))
  }

  # Update
  cat('updating CRANTb_meta seatable...\n')
  ac.new <- as.data.frame(ac.new)
  ac.new[is.na(ac.new)] <- ''
  crant_table_update_rows(df = ac.new,
                        base = "CRANTb",
                        table = "CRANTb_meta",
                        append_allowed = FALSE,
                        chunksize = 1000)
  cat('done.')

  # Return
  invisible()
}

# crant table update tracing
# hidden
crant_table_update_tracing <- function(table = "CRANTb_meta",
                                       base = "CRANTb"){

  # Get current table
  cat('reading CRANT meta seatable...\n')
  ac <- crant_table_query(sql = sprintf('select _id, root_id, status, ngl_link from %s',table),
                          base = base) %>%
    dplyr::select(!!rlang::sym("root_id"),
                  !!rlang::sym("status"),
                  !!rlang::sym("ngl_link"),
                  !!rlang::sym("_id"))
  ac[ac=="0"] <- NA
  ac[ac==""] <- NA

  # Only add ngl_link for a certain set of statuses
  cat('generating neuroglancer links ...\n')
  n_rows <- nrow(ac %>% dplyr::filter(grepl("TRACING_ISSUE$|TRACING_ISSUE,|PROOFREADING_ISSUE$|PROOFREADING_ISSUE,|PARTIALLY_PROOFREAD$|PARTIALLY_PROOFREAD,", status)))
  p <- dplyr::progress_estimated(n_rows)
  ac.new <- ac %>%
    dplyr::filter(grepl("TRACING_ISSUE$|PROOFREADING_ISSUE$|PARTIALLY_PROOFREAD$", !!rlang::sym("status"))) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      ngl_id = {
        p$tick()$print() # Update progress bar
        tryCatch(paste(crant_ngl_segments(!!rlang::sym("ngl_link")),collapse="_"), error = function(e) NA)
      }
    ) %>%
    dplyr::mutate(ngl_link = dplyr::case_when(
      is.na(!!rlang::sym("ngl_link")) ~ crant_scene(!!rlang::sym("root_id"), shorten_url = TRUE),
      !is.na(!!rlang::sym("ngl_id")) & !grepl(!!rlang::sym("root_id"),!!rlang::sym("ngl_id")) ~ crant_scene(!!rlang::sym("root_id"), shorten_url = TRUE),
      TRUE ~ ngl_link
    )) %>%
    dplyr::ungroup() %>%
    dplyr::select(-!!rlang::sym("ngl_id")) %>%
    as.data.frame()

  # Update
  cat('updating CRANTb_meta seatable...\n')
  ac.new[is.na(ac.new)] <- ''
  crant_table_update_rows(df = ac.new,
                          base = "CRANTb",
                          table = "CRANTb_meta",
                          append_allowed = FALSE,
                          chunksize = 1000)
  cat('done.')

  # Return
  invisible()
}
