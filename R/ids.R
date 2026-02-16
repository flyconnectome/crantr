#' Find the root identifier of a CRANT neuron
#'
#' @inheritParams fafbseg::flywire_rootid
#' @param ... Additional arguments passed to \code{pbapply::pbsapply} and
#'   eventually to Python \code{cv$CloudVolume} object.
#' @return A vector of root ids (by default character)
#' @export
#' @family crant-ids
#' @seealso \code{\link{flywire_rootid}}
#' @examples
#' \donttest{
#' crant_rootid("576460752684030043")
#' }
crant_rootid <- function(x, integer64 = FALSE, ...) {
  rid = fafbseg::flywire_rootid(
    x = x,
    integer64 = integer64,
    method = "cloudvolume",
    cloudvolume.url = crant_cloudvolume_url(),
    ...
  )
  rid
}

#' Find the supervoxel identifiers of a CRANT neuron
#'
#' @param ... additional arguments passed to \code{\link{flywire_leaves}}
#' @inheritParams fafbseg::flywire_leaves
#'
#' @return A vector of supervoxel ids
#' @family crant-ids
#' @seealso \code{\link{flywire_leaves}}
#' @export
#'
#' @examples
#' \dontrun{
#' svids=crant_leaves("576460752684030043")
#' head(svids)
#' }
crant_leaves <- function(x, integer64=TRUE, ...) {
  svids=with_crant(fafbseg::flywire_leaves(x=x, integer64 = integer64, ...))
  svids
}

#' Convert xyz locations to CRANT root or supervoxel ids
#'
#' @details This used to be very slow because we do not have a supervoxel
#'   field on spine.
#'
#'   I am somewhat puzzled by the voxel dimensions for crant. Neuroglancer
#'   clearly shows voxel coordinates of 4.3x4.3x45. But in this function, the
#'   voxel coordinates must be set to 4.25 in x-y to give the correct answers.
#'
#' @inheritParams fafbseg::flywire_xyz2id
#'
#' @return A character vector of segment ids, NA when lookup fails.
#' @family crant-ids
#' @seealso \code{\link{flywire_xyz2id}}
#' @export
#' @importFrom nat xyzmatrix
#' @examples
#' \dontrun{
#' # a point from neuroglancer, should map to 576460752684030043
#' crant_xyz2id(cbind(37306, 31317, 1405), rawcoords=TRUE)
#' }
crant_xyz2id <- function(xyz,
                        rawcoords = FALSE,
                        root = TRUE,
                        integer64 = FALSE,
                        fast_root = TRUE,
                        method = c("cloudvolume", "spine"),
                        ...) {
  fafbseg:::check_cloudvolume_reticulate()
  voxdims <- crant_voxdims()
  method = match.arg(method)
  if (isTRUE(is.numeric(xyz) && is.vector(xyz) && length(xyz) ==
             3)) {
    xyz = matrix(xyz, ncol = 3)
  }
  else {
    xyz = nat::xyzmatrix(xyz)
  }
  if (isTRUE(rawcoords)) {
    xyz <- scale(xyz, scale = 1/voxdims, center = FALSE)
  }
  checkmate::assertNumeric(xyz)
  if (method %in% c("spine")) {
    res <- crant_supervoxels(xyz, voxdims=voxdims)
  }
  else {
    cv = crant_cloudvolume()
    pycode = sprintf("\nfrom cloudvolume import Vec\n\ndef py_flywire_xyz2id(cv, xyz, agglomerate):\n  pt = Vec(*xyz) // cv.meta.resolution(0)\n  img = cv.download_point(pt, mip=0, size=1, agglomerate=agglomerate)\n  return str(img[0,0,0,0])\n")
    pydict = reticulate::py_run_string(pycode)
    safexyz2id <- function(pt) {
      tryCatch(pydict$py_flywire_xyz2id(cv, pt, agglomerate = root &&
                                          !fast_root), error = function(e) {
                                            warning(e)
                                            NA_character_
                                          })
    }
    res = pbapply::pbapply(xyz, 1, safexyz2id, ...)
  }
  if (fast_root && root) {
    res = crant_rootid(res,
                     integer64 = integer64,
                     ...)
  }
  if (isFALSE(rawcoords) && sum(res == 0) > 0.25 * length(res)) {
    if (all(fafbseg:::is_rawcoord(xyz))) {
      warning("It looks like you may be passing in raw coordinates. If so, use rawcoords=TRUE")
    }
  }
  if (integer64)
    bit64::as.integer64(res)
  else as.character(res)
}

# hidden, not yet implemented, could speak to Eric about it
crant_supervoxels <- function(x,
                             voxdims=crant_voxdims()) {
  pts=scale(nat::xyzmatrix(x), center = F, scale = voxdims)
  nas=rowSums(is.na(pts))>0
  if(any(nas)) {
    svids=rep("0", nrow(pts))
    svids[!nas]=crant_supervoxels(pts[!nas,,drop=F], voxdims = c(1,1,1))
    return(svids)
  }
  u="https://services.itanna.io/app/transform-service/query/dataset/crant_v1/s/2/values_array_string_response" #PLACEHOLDER
  body=jsonlite::toJSON(list(x=pts[,1], y=pts[,2], z=pts[,3]))
  res=httr::POST(u, body = body, httr::content_type("application/json"))
  httr::stop_for_status(res)
  j=httr::content(res, as='text', encoding = 'UTF-8')
  svids=unlist(jsonlite::fromJSON(j, simplifyVector = T), use.names = F)
  svids
}

#' Check if a CRANT root id is up to date
#'
#' @inheritParams fafbseg::flywire_islatest
#' @param ... Additional arguments passed to \code{\link{flywire_islatest}}
#'
#' @export
#' @family crant-ids
#' @examples
#' \dontrun{
#' crant_islatest("576460752684030043")
#' }
crant_islatest <- function(x,
                           timestamp=NULL,
                           ...) {
  with_crant(fafbseg::flywire_islatest(x=x,
                                      timestamp = timestamp,
                                      ...))
}

#' Find the latest id for a CRANT root id
#'
#' @inheritParams fafbseg::flywire_latestid
#' @param x a `data.frame` with at least one of: `root_id`, `pt_root_id`, `supervoxel_id` and/or `pt_supervoxel_id`.
#' Supervoxels will be preferentially used to update the `root_id` column.
#' Else a vector of `CRANT` root IDs.
#' @param ... Additional arguments passed to \code{\link{flywire_latestid}}
#' @param root.column when `x` is a `data.frame`, the `root_id` column you wish to update
#' @param supervoxel.column when `x` is a `data.frame`, the `supervoxel_id` column you wish to use to update `root.column`
#' @param position.column when `x` is a `data.frame`, the `position` column with xyz values you wish to use to update `supervoxel.column`
#' @export
#' @seealso \code{\link{crant_islatest}}
#' @family crant-ids
#' @examples
#' \dontrun{
#' crant_latestid("576460752684030043")
#' }
crant_latestid <- function(rootid,
                           sample=1000L,
                           cloudvolume.url=NULL,
                           Verbose=FALSE, ...) {
  with_crant(fafbseg::flywire_latestid(rootid=rootid,
                                       sample = sample,
                                       Verbose=Verbose,
                                       ...))
}

#' @export
#' @rdname crant_latestid
crant_updateids <- function(x,
                           root.column = "root_id",
                           supervoxel.column = "supervoxel_id",
                           position.column = "position",
                           ...){
  if(is.data.frame(x)){

    # Update supervoxel IDs
    if(all(c(position.column,supervoxel.column)%in%colnames(x))){
      no.sp <- is.na(x[[supervoxel.column]])|x[[supervoxel.column]]=="0"
      if(sum(no.sp)){
        cat('determining missing supervoxel_ids ...\n')
        x[no.sp,][[supervoxel.column]] <- unname(pbapply::pbsapply(x[no.sp,][[position.column]], function(row){
          tryCatch(crant_xyz2id(row,rawcoords = TRUE, root = FALSE, ...), error = function(e) NA)
        }))
      }
    }

    # what needs updating?
    if(!length(root.column)){
      root.column <- "root_id"
    }
    if(root.column%in%colnames(x)){
      cat('determining old root_ids...\n')
      old <- !crant_islatest(x[[root.column]], ...)
    }else{
      old <- rep(TRUE,nrow(x))
    }
    old[is.na(old)] <- TRUE
    if(!sum(old)){
      return(x)
    }

    # update based on supervoxels
    if(supervoxel.column%in%colnames(x)){
      cat('updating root_ids with a supervoxel_id...\n')
      update <- unname(pbapply::pbsapply(x[old,][[supervoxel.column]], crant_rootid, ...))
      bad <- is.na(update)|update=="0"
      update <- update[!bad]
      if(length(update)) x[old,][[root.column]][!bad] <- update
      old[old][!bad] <- TRUE
    }
    old[is.na(old)] <- TRUE

    # update based on position
    if(any(c("position","pt_position")%in%colnames(x)) && sum(old)){
      cat('updating root_ids with a position ...\n')
      update <- unname(pbapply::pbsapply(x[old,][[position.column]], function(row){
        tryCatch(quiet_function(crant_xyz2id, row, rawcoords = TRUE, root = TRUE, ...),
                 error = function(e) NA)
      }))
      bad <- is.na(update)|update=="0"
      update <- update[!bad]
      if(length(update)) x[old,][[root.column]][!bad] <- update
      old[!bad] <- FALSE
    }
    old[is.na(old)] <- TRUE

    # update based on root Ids
    if(root.column%in%colnames(x) && sum(old)){
      cat('updating root_ids without a supervoxel_id...\n')
      update <- crant_latestid(x[old,][[root.column]], ...)
      bad <- is.na(update)|update=="0"
      update <- update[!bad]
      if(length(update)) x[old,][[root.column]][!bad] <- update
      old[old][!bad] <- FALSE
    }
    old[is.na(old)] <- FALSE

  }else{
    cat('updating root_ids directly ...\n')
    old <- !crant_islatest(x, ...)
    old[is.na(old)] <- TRUE
    update <- crant_latestid(x[old], ...)
    bad <- is.na(update)|update=="0"
    update <- update[!bad]
    if(length(update)) x[old][!bad]  <- update
    old[!bad] <- FALSE
  }

  # return
  if(sum(old)){
    warning("failed to update: ", sum(old),"\n")
  }
  x
}

# hidden
quiet_function <- function(func, ...) {
  suppressMessages(
    suppressWarnings(
      capture.output(
        func(...),
        file = nullfile()
      )
    )
  )
}

