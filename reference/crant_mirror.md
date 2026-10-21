# Mirror CRANT neurons or points to the opposite side of the brain

`crant_mirror()` mirrors objects supported by
[`nat::xform()`](https://rdrr.io/pkg/nat/man/xform.html), including
neurons, neuronlists, dotprops, meshes and coordinate matrices, across
the CRANT brain midline.

## Usage

``` r
crant_mirror(
  x,
  units = c("nm", "microns"),
  subset = NULL,
  reg = crantr::crant_mirror_tps,
  ...
)
```

## Arguments

- x:

  An object to mirror.

- units:

  Coordinate units for `x` and the returned object. The mirror
  registration is defined in microns; nm inputs are scaled before and
  after transformation.

- subset:

  Optional subset passed to
  [`nat::xform()`](https://rdrr.io/pkg/nat/man/xform.html), for example
  when transforming selected elements of a neuronlist.

- reg:

  The mirror registration (in microns). Advanced use.

- ...:

  Additional arguments passed to
  [`nat::xform()`](https://rdrr.io/pkg/nat/man/xform.html).

## Value

A transformed object of the same kind as `x`.

## Details

Mirroring uses the thin plate spline
[crant_mirror_tps](https://flyconnectome.github.io/crantr/reference/crant_mirror_tps.md)
and needs the suggested Morpho package at runtime.

## See also

[crant_mirror_tps](https://flyconnectome.github.io/crantr/reference/crant_mirror_tps.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# a point either side of the midline (x ~ 202 um)
crant_mirror(rbind(c(120, 200, 130), c(280, 200, 130)), units = "microns")

library(nat)
crantb.surf.m <- crant_mirror(crantb.surf)
wire3d(crantb.surf, col = "grey")
wire3d(crantb.surf.m, col = "red")
} # }
```
