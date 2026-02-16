# Read CRANT CAVE-tables, good sources of metadata

Read CRANT CAVE-tables, good sources of metadata

## Usage

``` r
crant_cave_tables(datastack_name = "kronauer_ant", select = NULL, ...)
```

## Arguments

- datastack_name:

  Defaults to "kronauer_ant" i.e. CRANTb.

- select:

  A regex term for the name of the table you want

- ...:

  Additional arguments passed to
  `fafbseg::`[`flywire_cave_query`](https://rdrr.io/pkg/fafbseg/man/flywire_cave_query.html)

## Value

A `data.frame` describing a CAVE-table related to the CRANT project. In
the case of `crant_cave_tables`, a vector is returned containing the
names of all query-able cave tables.

## See also

`fafbseg::`[`flywire_cave_query`](https://rdrr.io/pkg/fafbseg/man/flywire_cave_query.html)

## Examples

``` r
if (FALSE) { # \dontrun{
all_crant_soma_positions <- crant_nuclei()
points3d(nat::xyzmatrix(all_crant_soma_positions$pt_position))

# Another way to query a specific table
crant_backbone_proofread <- with_crant(bancr:::get_cave_table_data("backbone_proofread"))
} # }
```
