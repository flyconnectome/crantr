# Handle raw and nm calibrated CRANT coordinates

`crant_voxdims` returns the image voxel dimensions which are normally
used to scale between **raw** and **nm** coordinates.

## Usage

``` r
crant_voxdims(url = choose_crant(set = FALSE)[["fafbseg.sampleurl"]])

crant_nm2raw(x, vd = crant_voxdims())

crant_raw2nm(x, vd = crant_voxdims())
```

## Arguments

- url:

  Optional neuroglancer URL containing voxel size. Defaults to
  `getOption("fafbseg.sampleurl")` as set by
  [`choose_crant`](https://flyconnectome.github.io/crantr/reference/choose_crant.md).

- x:

  3D coordinates in any form compatible with
  [`xyzmatrix`](https://rdrr.io/pkg/fafbseg/man/xyzmatrix.html)

- vd:

  The voxel dimensions in nm. Expert use only. Normally found
  automatically.

## Value

For `crant_voxdims` A 3-vector

for `crant_raw2nm` and `crant_nm2raw` an Nx3 matrix of coordinates

## Details

relies on nat \>= 1.10.4

## Examples

``` r
if (FALSE) { # \dontrun{
crant_voxdims()
} # }
if (FALSE) { # \dontrun{
crant_raw2nm(c(37306, 31317, 1405))
crant_raw2nm('37306 31317 1405')
crant_nm2raw(clipr::read_clip())
} # }
```
