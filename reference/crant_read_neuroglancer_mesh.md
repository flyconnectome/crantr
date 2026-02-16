# Read CRANT neuroglancer meshes, e.g., ROI meshes

Read CRANT neuroglancer meshes, e.g., ROI meshes

## Usage

``` r
crant_read_neuroglancer_mesh(
  x = 1,
  url = paste0("https://www.googleapis.com/storage/v1/b/",
    "dkronauer-ant-001-alignment-final/o/tissue_mesh%2F",
    "mesh%2Ftissue_mesh.frag?alt=media",
    "&neuroglancer=a2b0cf07baf8c501891d6c683cc7e24a"),
  ...
)
```

## Arguments

- x:

  the numeric identifier that specifies the mesh to read, defaults to
  `1` the CRANTb outline mesh.

- url:

  the URL that directs `bancr` to where CRANT meshes are stored.

- ...:

  additional arguments to `GET`

## Value

a mesh3d object for the specified mesh.

## See also

[`crant_read_neuron_meshes`](https://flyconnectome.github.io/crantr/reference/crant_read_neuron_meshes.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# default is brain mesh
crant.mesh  <- crant_read_neuroglancer_mesh()
} # }
```
