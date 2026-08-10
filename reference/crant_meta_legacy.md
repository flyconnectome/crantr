# Legacy in-memory cache for CRANTb meta data (deprecated)

`crant_meta_create_cache()` and `crant_meta_legacy()` reproduce the
previous closure-based metadata cache from earlier versions of crantr.
They are retained only so that existing scripts can be migrated; new
code should use
[`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md)
which delegates to
[`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html)
and gets transparent disk caching, delta sync, and query parsing for
free.

## Usage

``` r
crant_meta_create_cache(
  use_seatable = nzchar(Sys.getenv("CRANTTABLE_TOKEN")),
  return = FALSE
)

crant_meta_legacy(ids = NULL)
```

## Arguments

- use_seatable:

  Whether to build CRANTb meta data from the internal seatable
  (development) or the `cell_info` CAVE table (production, never
  implemented).

- return:

  Logical; if `TRUE`, return the cache tibble.

- ids:

  Vector of neuron/root ids to select, or `NULL` for all.

## Value

Invisibly returns the cache (data.frame) if `return=TRUE`; otherwise
invisibly `NULL`. `crant_meta_legacy()` returns a tibble.

## See also

[`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md)
