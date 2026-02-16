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

## Examples
