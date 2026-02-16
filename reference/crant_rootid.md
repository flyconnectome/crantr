# Find the root identifier of a CRANT neuron

Find the root identifier of a CRANT neuron

## Usage

``` r
crant_rootid(x, integer64 = FALSE, ...)
```

## Arguments

- x:

  One or more FlyWire segment ids

- integer64:

  Whether to return ids as integer64 type (more compact but a little
  fragile) rather than character (default `FALSE`).

- ...:

  Additional arguments passed to
  [`pbapply::pbsapply`](https://peter.solymos.org/pbapply/reference/pbapply.html)
  and eventually to Python `cv$CloudVolume` object.

## Value

A vector of root ids (by default character)

## See also

[`flywire_rootid`](https://rdrr.io/pkg/fafbseg/man/flywire_rootid.html)

Other crant-ids:
[`crant_islatest()`](https://flyconnectome.github.io/crantr/reference/crant_islatest.md),
[`crant_latestid()`](https://flyconnectome.github.io/crantr/reference/crant_latestid.md),
[`crant_leaves()`](https://flyconnectome.github.io/crantr/reference/crant_leaves.md),
[`crant_xyz2id()`](https://flyconnectome.github.io/crantr/reference/crant_xyz2id.md)

## Examples

``` r
# \donttest{
crant_rootid("576460752684030043")
#> Error in flywire_errorhandle(req) : Unauthorized (HTTP 401).
#> Error in crant_scene(): You have a token but it doesn't seem to be authorised for CAVE or global.daf-apis.com.
#> Have you definitely used `flywire_set_token()` to make a token for the CAVE datasets?Note you may have to do this in addition to `crantr_set_token()`
# }
```
