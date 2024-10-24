#' Query CRANT tables in the CAVE annotation system
#'
#' @param ... Additional arguments passed to \code{\link{flywire_cave_query}}
#'   \code{\link[fafbseg]{flywire_cave_query}}
#' @inheritParams bancr::banc_partner_summary
#' @inheritParams fafbseg::flywire_cave_query
#'
#' @return A data.frame
#'
#' @family crant-cave
#' @export
#' @seealso \code{\link[fafbseg]{flywire_cave_query}}
#' @examples
#' \dontrun{
#' library(dplyr)
#' cell_info=crant_cave_query('cell_info')
#' cell_info %>%
#'   filter(tag2=='anterior-posterior projection pattern') %>%
#'   count(tag)
#'
#' # Another way to query a specific table
#' crant_backbone_proofread <- with_crant(bancr:::get_cave_table_data("cell_info"))
#' }
crant_cave_query <- function(table, live=TRUE, ...) {
  with_crant(fafbseg::flywire_cave_query(table = table, live=live, ...))
}

#' Low level access to crant's CAVE annotation infrastructure
#'
#' @return A reticulate R object wrapping the python CAVEclient.
#' @export
#'
#' @examples
#' \dontrun{
#' fcc=crant_cave_client()
#' tables=fcc$annotation$get_tables()
#' fcc$materialize$get_table_metadata(tables[1])
#' }
crant_cave_client <- function() {
  with_crant(fafbseg::flywire_cave_client())
}

#' Read CRANT CAVE-tables, good sources of metadata
#'
#' @param select A regex term for the name of the table you want
#' @param datastack_name  Defaults to "kronauer_ant" i.e. CRANTb.
#' @param ... Additional arguments passed to
#'   \code{fafbseg::\link{flywire_cave_query}}
#'
#' @return A \code{data.frame} describing a CAVE-table related to the CRANT project.
#' In the case of \code{crant_cave_tables}, a vector is returned containing the names of
#' all query-able cave tables.
#'
#' @seealso \code{fafbseg::\link{flywire_cave_query}}
#'
#' @export
#' @examples
#' \dontrun{
#' all_crant_soma_positions <- crant_nuclei()
#' points3d(nat::xyzmatrix(all_crant_soma_positions$pt_position))
#'
#' # Another way to query a specific table
#' crant_backbone_proofread <- with_crant(bancr:::get_cave_table_data("backbone_proofread"))
#' }
#' @importFrom magrittr "%>%"
crant_cave_tables <- function(datastack_name = "kronauer_ant",
                              select = NULL,
                              ...){
  if(is.null(datastack_name))
    datastack_name=crant_datastack_name()
  fac <- fafbseg::flywire_cave_client(datastack_name = datastack_name, ...)
  dsinfo <- fac$info$get_datastack_info()
  tt <- fac$annotation$get_tables()
  if(!is.null(select)){
    chosen_tables <- grep(select, tt)
    if (length(chosen_tables) == 0)
      stop(sprintf("I cannot find a '%s' table for datastack: ", select),
           datastack_name, "\nPlease ask for help on #crant-b https://app.slack.com/client/T07RC68DXQA/C07S10GRL9W")
    if (length(chosen_tables) == 1)
      return(tt[chosen_tables])
    chosen <- tt[rev(chosen_tables)[1]]
    warning(sprintf("Multiple candidate '%s' tables. Choosing: ", select),
            chosen)
    return(chosen)
  }else{
    return(tt)
  }
}

