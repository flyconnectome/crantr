# Use CRANTb data with coconat for connectivity similarity

Register the CRANTb dataset with
[coconat](https://github.com/natverse/coconat), a natverse R package for
between- and within-dataset connectivity comparisons using cosine
similarity. Once registered, CRANTb participates in `coconatfly::cf_*()`
calls under the dataset name `"crant"`.

## Usage

``` r
register_crant_coconat(showerror = TRUE)
```

## Arguments

- showerror:

  Logical; if `FALSE`, return invisibly when dependencies are missing
  instead of erroring.

## Details

Metadata access goes through
[`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md),
which is itself a wrapper around
[`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html)
with the seatable URL/token set locally for the duration of each call.
There is no separate cache to populate before registering.

## See also

[`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md),
[`crant_table_set_token()`](https://flyconnectome.github.io/crantr/reference/crant_table_query.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(coconatfly)
register_crant_coconat()
cf_meta(cf_ids(crant = "/class:descending"))
cf_cosine_plot(cf_ids("/type:NSC", datasets = c("crant", "flywire")))
} # }
```
