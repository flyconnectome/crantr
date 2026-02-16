# Use CRANTb data with coconat for connectivity similarity

Register the CRANTb dataset with
[coconat](https://github.com/natverse/coconat), a natverse R package for
between and within dataset connectivity comparisons using cosine
similarity.

## Usage

``` r
register_crant_coconat(showerror = TRUE)
```

## Arguments

- showerror:

  Logically, error-out silently or not.

## Details

`register_crant_coconat()` registers `crantr`-backed functionality for
use with

## See also

[`crant_meta_create_cache()`](https://flyconnectome.github.io/crantr/reference/crant_meta_create_cache.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(coconatfly)
library(bancr)
crant_meta_create_cache(use_seatable=TRUE)
banc_meta_create_cache(use_seatable=TRUE)
register_crant_coconat()
register_banc_coconat()
cf_cosine_plot(cf_ids('/type:NSC', datasets = c("crant", "banc")))
} # }
```
