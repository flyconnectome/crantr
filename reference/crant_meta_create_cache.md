# Create or refresh cache of CRANTb meta information

`crant_meta_create_cache()` builds or refreshes an in-memory cache of
CRANTb metadata for efficient repeated lookups. You can choose the data
source using `use_seatable`. The main accessor function
[`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md)
will always use the most recently created cache.

## Usage

``` r
crant_meta_create_cache(use_seatable = FALSE, return = FALSE)
```

## Arguments

- use_seatable:

  Whether to build CRANTb meta data from the `cell_info` CAVE table
  (production) or our internal seatable (development). Both require
  different types of authenticated access, for details see `crantr`
  documentation.

- return:

  Logical; if `TRUE`, return the cache tibble/invisible.

## Value

Invisibly returns the cache (data.frame) if `return=TRUE`; otherwise
invisibly `NULL`.

## Details

CRANTb meta queries can be slow; caching avoids repeated
computation/database access. Whenever labels are updated, simply rerun
this function to update the cache.

## Examples

``` r
if (FALSE) { # \dontrun{
#' # Requires authenticated access to CRANTb CAVE
crant_meta_cache(use_seatable=FALSE)

crant_meta_create_cache(use_seatable=TRUE) # create cache
## CRANTbTABLE_TOKEN must be set, see crantr package
result <- crant_meta() # use cache

# use cache to quickly make plot
library(coconatfly)
register_crant_coconat()
cf_cosine_plot(cf_ids('/type:NSC', datasets = c("crant", "flywire")))
} # }
```
