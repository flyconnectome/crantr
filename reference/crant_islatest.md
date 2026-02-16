# Check if a CRANT root id is up to date

Check if a CRANT root id is up to date

## Usage

``` r
crant_islatest(x, timestamp = NULL, ...)
```

## Arguments

- x:

  FlyWire rootids in any format understandable to
  [`ngl_segments`](https://rdrr.io/pkg/fafbseg/man/ngl_segments.html)
  including as `integer64`

- timestamp:

  (optional) argument to set an endpoint - edits after this time will be
  ignored (see details).

- ...:

  Additional arguments passed to
  [`flywire_islatest`](https://rdrr.io/pkg/fafbseg/man/flywire_islatest.html)

## See also

Other crant-ids:
[`crant_latestid()`](https://flyconnectome.github.io/crantr/reference/crant_latestid.md),
[`crant_leaves()`](https://flyconnectome.github.io/crantr/reference/crant_leaves.md),
[`crant_rootid()`](https://flyconnectome.github.io/crantr/reference/crant_rootid.md),
[`crant_xyz2id()`](https://flyconnectome.github.io/crantr/reference/crant_xyz2id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
crant_islatest("576460752684030043")
} # }
```
