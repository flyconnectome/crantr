# Make sure given root IDs look like CRANT root IDs

If `x` is a single character query (e.g. `"/cell_type:ExR1"` or
`"/super_class:descending"`), it is looked up in the CRANTb seatable via
[`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md)
and the matching root ids are returned. Set `normalise_colnames = TRUE`
to enable coconat-style aliases such as `"/type:ExR1"`,
`"class:descending"`, or a bare type name like `"ExR1"`. Otherwise
validation is delegated to
[`fafbseg::flywire_ids()`](https://rdrr.io/pkg/fafbseg/man/flywire_ids.html).

## Usage

``` r
crant_ids(
  x,
  integer64 = NA,
  unique = FALSE,
  normalise_colnames = FALSE,
  na.rm = FALSE
)
```

## Arguments

- x:

  A character or bit64::integer64 vector or a dataframe specifying ids,
  or a single character query (see description).

- integer64:

  Whether to return ids as 64 bit integers rather than character
  vectors. Default value of NA leaves the ids unmodified.

- unique:

  For query inputs only, whether to drop rows with duplicate root ids
  (passed to
  [`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md)).
  Ignored for non-query inputs.

- normalise_colnames:

  Logical; if `TRUE`, pass `normalise_colnames = TRUE` to
  [`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md)
  so query aliases such as `class:`/`type:` and bare type tokens are
  translated to the underlying seatable schema before lookup.

- na.rm:

  Whether to drop missing (`NA`) root ids rather than returning them as
  the null segment `"0"` (passed to
  [`fafbseg::flywire_ids()`](https://rdrr.io/pkg/fafbseg/man/flywire_ids.html)).
  CRANTb_meta contains some incomplete rows with no root id.

## Examples

``` r
if (FALSE) { # \dontrun{
# all descending neuron root ids
crant_ids("/super_class:descending")
# a specific cell type, as integer64
crant_ids("/cell_type:MDN", integer64 = TRUE)
# coconat-friendly query aliases (requires normalise_colnames = TRUE)
crant_ids("/class:descending", normalise_colnames = TRUE)
# a bare type name, likewise treated as a cell_type/type query
crant_ids("ExR1", normalise_colnames = TRUE)
} # }
```
