# Folder for local CRANT synapse snapshots

Returns the folder that the synapse snapshot functions use when no
`root` is given: the `crantr.synapse_snapshot_root` option if set,
otherwise `syn_snapshot` in the user data folder for the package (see
[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)).

## Usage

``` r
crant_snapshot_root(create = FALSE)
```

## Arguments

- create:

  Whether to create the folder (and any missing parent folders) if it
  does not exist yet.

## Value

The path to the folder, with `~` expanded.

## See also

[`crant_use_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_use_snapshot.md)

## Examples

``` r
crant_snapshot_root()
#> [1] "/home/runner/.local/share/R/crantr/syn_snapshot"
```
