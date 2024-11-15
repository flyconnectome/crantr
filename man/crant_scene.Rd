% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/crant.R
\name{crant_scene}
\alias{crant_scene}
\title{Return a sample Neuroglancer scene URL for crant dataset}
\usage{
crant_scene(
  ids = NULL,
  open = FALSE,
  shorten_url = FALSE,
  layer = "proofreadable seg",
  url = paste0("https://spelunker.cave-explorer.org/#!middleauth+",
    "https://global.daf-apis.com/nglstate/api/v1/", "5733498854834176")
)
}
\arguments{
\item{ids}{A set of root ids to include in the scene. Can also be a data.frame.}

\item{open}{Whether to open the URL in your browser (see
\code{\link{browseURL}})}

\item{shorten_url}{logical, whether or not to produce a shortened URL.}

\item{layer}{the segmentation layer for which \code{ids} intended. Defaults to 'segmentation proofreading',
but could point to another dataset layer.}

\item{url}{a spelunker neuroglancer URL.}
}
\value{
A character vector containing a single Neuroglancer URL (invisibly
when \code{open=TRUE}).
}
\description{
Return a sample Neuroglancer scene URL for crant dataset
}
\examples{
\dontrun{
browseURL(crant_scene())
crant_scene(open=T)
crant_scene("576460752653449509", open=T)
}
}
