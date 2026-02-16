# Return a sample Neuroglancer scene URL for crant dataset

Return a sample Neuroglancer scene URL for crant dataset

## Usage

``` r
crant_scene(
  ids = NULL,
  open = FALSE,
  shorten_url = FALSE,
  layer = "proofreadable seg",
  url = paste0("https://spelunker.cave-explorer.org/#!middleauth+",
    "https://global.daf-apis.com/nglstate/api/v1/", "5733498854834176")
)
```

## Arguments

- ids:

  A set of root ids to include in the scene. Can also be a data.frame.

- open:

  Whether to open the URL in your browser (see
  [`browseURL`](https://rdrr.io/r/utils/browseURL.html))

- shorten_url:

  logical, whether or not to produce a shortened URL.

- layer:

  the segmentation layer for which `ids` intended. Defaults to
  'segmentation proofreading', but could point to another dataset layer.

- url:

  a spelunker neuroglancer URL.

## Value

A character vector containing a single Neuroglancer URL (invisibly when
`open=TRUE`).

## Examples

``` r
if (FALSE) { # \dontrun{
browseURL(crant_scene())
crant_scene(open=T)
crant_scene("576460752653449509", open=T)
} # }
```
