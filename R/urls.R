# hidden
crant_ngl_segments <- function(ngl_link){
  fafbseg::ngl_decode_scene(ngl_link)$layers$`proofreadable seg`$segments
}

# hidden
crant_shorturl <- bancr:::banc_shorturl

# hidden
`crant_ngl_segments<-` <- function (x, layer = "proofreadable seg", value) {
  bancr:::`banc_ngl_segments<-`(x, layer = layer, value)
}

# Make a neuroglancer layer with 3D points in it, for synapse review
crant_annotation_layer <- function(data,
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
  su<-bancr:::banc_shorturl(u)
  # # Extract annotations!
  # ngl_annotations(su)
  if(open){
    browseURL(u)
  }else{
    su
  }
}
