# Query cached CRANTb meta data

Returns results from the in-memory cache, filtered by `ids` if given.
Cache must be created first using
[`crant_meta_create_cache()`](https://flyconnectome.github.io/crantr/reference/crant_meta_create_cache.md).

## Usage

``` r
crant_meta(ids = NULL)
```

## Arguments

- ids:

  Vector of neuron/root IDs to select, or `NULL` for all.

## Value

tibble/data.frame, possibly filtered by ids.

## Details

`crant_meta()` never queries databases directly. If `ids` are given,
filters the meta table by root_id.

## See also

[`crant_meta_create_cache()`](https://flyconnectome.github.io/crantr/reference/crant_meta_create_cache.md)

## Examples

``` r
if (FALSE) { # \dontrun{
crant_meta_create_cache() # build the cache
all_meta <- crant_meta()  # retrieve all
} # }
```
