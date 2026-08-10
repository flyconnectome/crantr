# Choose or (temporarily) use the CRANT autosegmentation

Choose or (temporarily) use the CRANT autosegmentation

## Usage

``` r
choose_crant(set = TRUE)

with_crant(expr)
```

## Arguments

- set:

  Whether or not to permanently set the CRANT auto-segmentation as the
  default for
  [`fafbseg`](https://rdrr.io/pkg/fafbseg/man/fafbseg-package.html)
  functions.

- expr:

  An expression to evaluate while CRANT is the default autosegmentation

## Value

If `set=TRUE` a list containing the previous values of the relevant
global options (in the style of
[`options`](https://rdrr.io/r/base/options.html). If `set=FALSE` a named
list containing the option values.

## Details

`bancr` inherits a significant amount of infrastructure from the
[`fafbseg`](https://rdrr.io/pkg/fafbseg/man/fafbseg-package.html)
package. This has the concept of the *active* autosegmentation, which in
turn defines one or more R options containing URLs pointing to
voxel-wise segmentation, mesh etc data. These are normally contained
within a single neuroglancer URL which points to multiple data layers.
For banc this is the neuroglancer scene returned by
[`crant_scene`](https://flyconnectome.github.io/crantr/reference/crant_scene.md).

`with_crant` and `choose_crant` also redirect the `fafbseg` flytable
infrastructure (see
[`cam_meta`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html)) at the
CRANTb seatable instance via the `fafbseg.flytable.url` option (requires
`fafbseg >= 0.15.7`). Inside `with_crant()` the `FLYTABLE_TOKEN`
environment variable is temporarily replaced with the value of
`CRANTTABLE_TOKEN` so that
[`flytable_login`](https://rdrr.io/pkg/fafbseg/man/flytable_login.html)
authenticates against the CRANTb seatable; the original value is
restored on exit.

## Examples

``` r
if (FALSE) { # \dontrun{
choose_crant()
options()[grep("^fafbseg.*url", names(options()))]
} # }
if (FALSE) { # \dontrun{
with_crant(fafbseg::flywire_islatest('576460752653449509'))
} # }
if (FALSE) { # \dontrun{
with_crant(fafbseg::flywire_latestid('576460752653449509'))
with_crant(fafbseg::cam_meta('/super_class:descending', table='CRANTb_meta'))
} # }
```
