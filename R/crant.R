#' Return a sample Neuroglancer scene URL for crant dataset
#'
#' @param url a spelunker neuroglancer URL.
#' @param ids A set of root ids to include in the scene. Can also be a data.frame.
#' @param layer the segmentation layer for which `ids` intended. Defaults to 'segmentation proofreading',
#' but could point to another dataset layer.
#' @param open Whether to open the URL in your browser (see
#'   \code{\link{browseURL}})
#' @return A character vector containing a single Neuroglancer URL (invisibly
#'   when \code{open=TRUE}).
#' @export
#' @importFrom utils browseURL
#' @examples
#' \dontrun{
#' browseURL(crant_scene())
#' crant_scene(open=T)
#' crant_scene("576460752653449509", open=T)
#' }
crant_scene <- function(ids=NULL,
                        open=FALSE,
                        layer = NULL,
                        url=paste0("https://spelunker.cave-explorer.org/#!middleauth+",
                                   "https://global.daf-apis.com/nglstate/api/v1/",
                                   "5733498854834176")) {
  url=sub("#!middleauth+", "?", url, fixed = T)
  parts=unlist(strsplit(url, "?", fixed = T))
  json=try(fafbseg::flywire_fetch(parts[2], token=fafbseg::chunkedgraph_token(), return = 'text', cache = TRUE)) # token = crant_token()
  if(inherits(json, 'try-error')) {
    badtoken=paste0("You have a token but it doesn't seem to be authorised for CAVE or global.daf-apis.com.\n",
                    "Have you definitely used `crant_set_token()` to make a token for the CAVE datasets?")
    if(grepl(500, json))
      stop("There seems to be a (temporary?) problem with the zetta server!")
    else if(grepl(401, json))
      stop(badtoken)

    token=try(crant_token(), silent = T)
    if(inherits(token, 'try-error'))
      stop("It looks like you do not have a stored token. Please use `flywire_set_token()` to make one.")
    else
      stop(badtoken)
  }
  u=fafbseg::ngl_encode_url(json, baseurl = parts[1])
  if(!is.null(ids)){
    banc_ngl_segments(u, layer=layer) <- crant_ids(ids)
  }
  if(open) {
    browseURL(u)
    invisible(u)
  } else (u)
}

#' Set the token to be used to authenticate to CRANT autosegmentation resources
#'
#' @param token An optional token string. When missing you are prompted to
#'   generate a new token via your browser.
#' @param domain the domain for which your CAVE token is valid, i.e. where the
#' project is hosted.
#'
#' @return The path to the token file (invisibly)
#' @export
crant_set_token <- function(token=NULL, domain = 'https://proofreading.zetta.ai') {
  if (is.null(token)) {
    if (!interactive())
      stop("I can only request tokens in interactive mode!")
    resp = readline("Would you like to generate a new chunkedgraph token in your browser [y/n]?")
    if (!isTRUE(tolower(resp) == "y")) {
      stop("OK! Next time, please pass the token to this function!")
    }
    u <-"https://proofreading.zetta.ai/auth/api/v1/refresh_token"
    browseURL(u)
    tok = readline("Please paste in the token and close your browser window: ")
    token = gsub("\"", "", fixed = T, tok)
  }
  else if (!isTRUE(nchar(token) == 32)) {
    stop("Sorry. Bad token. They should look like: 2f88e16c4f21bfcb290b2a8288c05bd0")
  }
  cvv = fafbseg:::cloudvolume_version()
  if (is.na(cvv) || cvv < numeric_version("3.11"))
    warning("You will need to install cloudvolume >=3.11.0 to use your token!\n",
            "You can do this conveniently with `fafbseg::simple_python()`")
  invisible(fafbseg:::cv_write_secret(list(token = token), fqdn = "proofreading.zetta.ai", type = "cave"))
  invisible(fafbseg:::cv_write_secret(list(token = token), fqdn = "data.proofreading.zetta.ai", type = "cave"))
}

# hidden
crant_token <- function(cached=TRUE) {
  fafbseg::chunkedgraph_token(url='https://proofreading.zetta.ai', cached = cached)
}

# hidden
crant_token_available <- function() {
  !inherits(try(crant_token(), silent = TRUE), 'try-error')
}

#' Choose or (temporarily) use the CRANT autosegmentation
#'
#' @details \code{bancr} inherits a significant amount of infrastructure from
#'   the \code{\link{fafbseg}} package. This has the concept of the
#'   \emph{active} autosegmentation, which in turn defines one or more R options
#'   containing URLs pointing to voxel-wise segmentation, mesh etc data. These
#'   are normally contained within a single neuroglancer URL which points to
#'   multiple data layers. For banc this is the neuroglancer scene returned by
#'   \code{\link{crant_scene}}.
#' @param set Whether or not to permanently set the CRANT auto-segmentation as the
#'   default for \code{\link{fafbseg}} functions.

#' @return If \code{set=TRUE} a list containing the previous values of the
#'   relevant global options (in the style of \code{\link{options}}. If
#'   \code{set=FALSE} a named list containing the option values.
#' @export
#'
#' @examples
#' \dontrun{
#' choose_crant()
#' options()[grep("^fafbseg.*url", names(options()))]
#' }
choose_crant <- function(set=TRUE) {
  fafbseg::choose_segmentation(
    release <- crant_scene(),
    set <- set,
    moreoptions=list(
      fafbseg.cave.datastack_name=crant_datastack_name()
    ))
}

#' @param expr An expression to evaluate while CRANT is the default
#'   autosegmentation
#' @rdname choose_crant
#' @export
#' @examples
#' \donttest{
#' with_crant(fafbseg::flywire_islatest('576460752653449509'))
#' }
#' \dontrun{
#' with_crant(fafbseg::flywire_latestid('576460752653449509')
#' }
with_crant <- function(expr) {
  op <- choose_crant(set = TRUE)
  on.exit(options(op))
  force(expr)
}

# Connect to CAVE client
cave_client <- function(datastack_name,
                        server_address="https://proofreading.zetta.ai",
                        auth_token = crant_token()){
  cavec <- fafbseg:::check_cave()
  client <- try(cavec$CAVEclient(datastack_name, server_address=server_address, auth_token=auth_token))
  if (inherits(client, "try-error")) {
    cat("\nPlease run dr_fafbseg() to help diagnose.\n")
    stop("There seems to be a problem connecting to datastack: ",
         datastack_name)
  }
  client
}

# Get datastack name
crant_datastack_name <- memoise::memoise(function() {
  cat("you are using CRANTb\n")
  "kronauer_ant" # is CRANTb
})

# hidden
crant_fetch <- function(url, token=crant_token(), ...) {
  fafbseg::flywire_fetch(url, token=token, ...)
}

#' Make sure given root IDs look like CRANT root IDs
#' @inheritParams bancr::banc_ids
#' @rdname crant_ids
#' @export
crant_ids <- function(x, integer64 = NA){
  bancr::banc_ids(x=x, integer64=integer64)
}

