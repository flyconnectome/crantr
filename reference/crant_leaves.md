# Find the supervoxel identifiers of a CRANT neuron

Find the supervoxel identifiers of a CRANT neuron

## Usage

``` r
crant_leaves(x, integer64 = TRUE, ...)
```

## Arguments

- x:

  One or more FlyWire segment ids

- integer64:

  Whether to return ids as integer64 type (the default, more compact but
  a little fragile) rather than character (when `FALSE`).

- ...:

  additional arguments passed to
  [`flywire_leaves`](https://rdrr.io/pkg/fafbseg/man/flywire_leaves.html)

## Value

A vector of supervoxel ids

## See also

[`flywire_leaves`](https://rdrr.io/pkg/fafbseg/man/flywire_leaves.html)

Other crant-ids:
[`crant_islatest()`](https://flyconnectome.github.io/crantr/reference/crant_islatest.md),
[`crant_latestid()`](https://flyconnectome.github.io/crantr/reference/crant_latestid.md),
[`crant_rootid()`](https://flyconnectome.github.io/crantr/reference/crant_rootid.md),
[`crant_xyz2id()`](https://flyconnectome.github.io/crantr/reference/crant_xyz2id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
svids=crant_leaves("576460752684030043")
head(svids)
} # }
```
