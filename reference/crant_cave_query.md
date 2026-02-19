# Query CRANT tables in the CAVE annotation system

Query CRANT tables in the CAVE annotation system

## Usage

``` r
crant_cave_query(table, live = 2, ...)

crant_backbone_proofread(live = 2, ...)

crant_version()
```

## Arguments

- table:

  The name of the table (or view, see views section) to query

- live:

  Whether to use live query mode, which updates any root ids to their
  current value (or to another `timestamp` when provided). Values of
  `TRUE` or `1` select CAVE's *Live* mode, while `2` selects `Live live`
  mode which gives access even to annotations that are not part of a
  materialisation version. See section **Live and Live Live queries**
  for details.

- ...:

  Additional arguments passed to
  [`flywire_cave_query`](https://rdrr.io/pkg/fafbseg/man/flywire_cave_query.html)
  [`flywire_cave_query`](https://rdrr.io/pkg/fafbseg/man/flywire_cave_query.html)

## Value

A data.frame

## See also

[`flywire_cave_query`](https://rdrr.io/pkg/fafbseg/man/flywire_cave_query.html)

## Examples

``` r
if (FALSE) { # \dontrun{
backbone.proofread=crant_cave_query('backbone_proofread')
View(backbone.proofread)
} # }
```
