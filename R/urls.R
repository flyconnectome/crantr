
# hidden
banc_shorturl <- function (x,
                           baseurl = NULL,
                           cache = TRUE,
                           ...)
{
  if (fafbseg:::is.ngscene(x)) {
    sc <- x
    x <- fafbseg::ngl_encode_url(sc, ...)
  }
  else {
    stopifnot(is.character(x))
    if (length(x) > 1) {
      res = pbapply::pbsapply(x,
                              banc_shorturl,
                              baseurl = baseurl,
                              cache = cache,
                              ...)
      return(res)
    }
    sc = fafbseg::ngl_decode_scene(x)
  }
  state_server = "https://global.daf-apis.com/nglstate/post"
  json = fafbseg::ngl_decode_scene(x, return.json = TRUE)
  res = fafbseg::flywire_fetch(state_server, body = json, cache = cache)
  sprintf("https://spelunker.cave-explorer.org/#!middleauth+https://global.daf-apis.com/nglstate/api/v1/%s",basename(res))
}



# hidden
`banc_ngl_segments<-` <- function (x, layer = NULL, value) {
  was_char <- is.character(x)
  baseurl <- if (was_char)
    x
  else NULL
  x = fafbseg::ngl_decode_scene(x)
  layers = fafbseg::ngl_layers(x)
  nls = fafbseg:::ngl_layer_summary(layers)
  sel = which(nls$type == "segmentation_with_graph")
  if (length(sel) == 0)
    sel = which(nls$visible & grepl("^segmentation", nls$type))
  if (length(sel) == 0)
    stop("Could not find a visible segmentation layer!")
  if (length(sel) > 1) {
    if(is.null(layer)){
      sel = 1
    }else{
      sel = match(layer,nls$name)
    }
  }
  if (is.null(value))
    value <- character()
  newsegs = fafbseg::ngl_segments(value, as_character = TRUE, must_work = FALSE)
  if (!all(fafbseg:::valid_id(newsegs)))
    warning("There are ", sum(!fafbseg:::valid_id(newsegs)), " invalid segments")
  x[["layers"]][[sel]][["segments"]] = newsegs
  nls$nhidden[sel] <- 1
  if (nls$nhidden[sel] > 0)
    x[["layers"]][[sel]][["hiddenSegments"]] = NULL
  if (was_char)
    as.character(x, baseurl = baseurl)
  else x
}

# Make a neuroglancer layer with 3D points in it, for synapse review
banc_annotation_layer <- function(data,
                                  layer = "sample",
                                  open = FALSE,
                                  rawcoords = NA,
                                  colpal = NULL){
  #data <- read_csv('/Users/abates/projects/flyconnectome/bancpipeline/tracing/2024-08-12_banc_synapse_sample_v1.csv')
  #data$pt_position<-data$`Coordinate 1`
  data$layer <- "synapse_sample"
  al <- ngl_annotation_layers(data[,c("pt_position", "layer")], rawcoords=rawcoords, colpal=colpal)
  sc<-fafbseg::ngl_decode_scene(banc_scene())
  sc2<-sc+al
  u<-as.character(sc2)
  su<-banc_shorturl(u)
  # # Extract annotations!
  # ngl_annotations(su)
  if(open){
    browseURL(u)
  }else{
    su
  }
}
