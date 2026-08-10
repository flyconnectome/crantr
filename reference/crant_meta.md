# Return metadata about CRANTb neurons from the project seatable

`crant_meta()` is a thin wrapper around
[`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html)
that points it at the CRANTb seatable instance (`cloud.seatable.io`,
table `CRANTb_meta`). By default it returns the underlying seatable
column names unchanged. Set `normalise_colnames = TRUE` to translate
them to the coconat-friendly schema (`id`, `class`, `type`, etc.), which
also enables query aliases such as `"/class:descending"` or
`"/type:NSC"`. Plain root id vectors are also accepted.

## Usage

``` r
crant_meta(
  ids = NULL,
  ignore.case = FALSE,
  fixed = FALSE,
  version = NULL,
  timestamp = NULL,
  unique = FALSE,
  normalise_colnames = FALSE,
  translate_ids = NA,
  drop_status = "DUPLICATED",
  ...
)
```

## Arguments

- ids:

  Root ids (character/int64 vector) or a single query string such as
  `"/class:descending"` (see
  [`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html)).
  `NULL` returns the full table.

- ignore.case:

  For query strings, whether to ignore case.

- fixed:

  For query strings, whether to treat queries as fixed strings rather
  than regular expressions.

- version, timestamp:

  Optional CAVE materialisation version / timestamp to which root ids in
  the returned table should be mapped.

- unique:

  Whether to drop duplicate `id` rows.

- normalise_colnames:

  Logical; if `TRUE`, rename metadata columns to the coconat/crantr
  schema (`root_id` -\> `id`, `super_class` -\> `class`, etc.) and
  translate query aliases such as `class:` -\> `super_class:` and bare
  tokens like `"NSC"` -\> `"cell_type:NSC"`.

- translate_ids:

  Whether to bring explicitly supplied `ids` forward to the requested
  `version`/`timestamp` before matching, so stale ids don't silently
  drop out of the result (see
  [`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html)
  for details). `NA` (the default) enables this automatically whenever
  `version` or `timestamp` is supplied.

- drop_status:

  Character vector of `status` tokens whose rows are dropped before any
  query/join/`unique` step. Defaults to CRANT's capitalised multi-select
  duplicate marker `"DUPLICATED"`; pass `NULL` to keep known duplicates.
  See
  [`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html).

- ...:

  Passed to
  [`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html)
  (and via that to
  [`fafbseg::flytable_cached_table()`](https://rdrr.io/pkg/fafbseg/man/flytable_cached_table.html)).

## Value

By default, a data.frame with the underlying seatable columns such as
`root_id`, `super_class`, `cell_class`, `cell_type`, `cell_subtype`,
`cell_instance`, `hemilineage`, `side`, `nerve`, `tract`. When
`normalise_colnames = TRUE`, these are renamed to the crantr/coconat
schema (`id`, `class`, `subclass`, `type`, `subtype`, `instance`,
`lineage`) and `side` is normalised to `"L"`/`"R"`.

## Details

Disk caching with delta sync is handled by
[`fafbseg::flytable_cached_table()`](https://rdrr.io/pkg/fafbseg/man/flytable_cached_table.html)
under the hood, so repeated calls are fast. Pass `expiry`, `refresh`
etc. via `...` to control cache behaviour.

Internally `crant_meta()` uses
[`withr::local_options()`](https://withr.r-lib.org/reference/with_options.html)
to point `fafbseg`'s flytable client at the CRANTb seatable and
[`withr::local_envvar()`](https://withr.r-lib.org/reference/with_envvar.html)
to temporarily pass `CRANTTABLE_TOKEN` through as `FLYTABLE_TOKEN`
before calling
[`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html).
Requires `CRANTTABLE_TOKEN` to be set; see
[`crant_table_set_token()`](https://flyconnectome.github.io/crantr/reference/crant_table_query.md).

## See also

[`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html),
[`crant_ids()`](https://flyconnectome.github.io/crantr/reference/crant_ids.md),
[`crant_table_set_token()`](https://flyconnectome.github.io/crantr/reference/crant_table_query.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# all descending neurons
crant_meta("/super_class:descending")
# a specific descending neuron type
crant_meta("/cell_type:MDN")
# regex queries match anywhere in the field, e.g. all central complex
# (CX) neuron classes
crant_meta("/super_class:CX.+")

# the coconat-friendly schema and its query aliases
crant_meta("/class:descending", normalise_colnames = TRUE)
crant_meta("/type:MDN", normalise_colnames = TRUE)
# a bare token is treated as a cell_type/type query
crant_meta("ExR1", normalise_colnames = TRUE)
# ... equivalently, on the raw seatable schema
crant_meta("/cell_class:olfactory_projection_neuron")

crant_meta(c("576460752684030043", "576460752653449509"))
} # }
```
