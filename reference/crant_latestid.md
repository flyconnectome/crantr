# Find the latest id for a CRANT root id

Find the latest id for a CRANT root id

## Usage

``` r
crant_latestid(
  rootid,
  sample = 1000L,
  cloudvolume.url = NULL,
  Verbose = FALSE,
  ...
)

crant_updateids(
  x,
  root.column = "root_id",
  supervoxel.column = "supervoxel_id",
  position.column = "position",
  ...
)
```

## Arguments

- rootid:

  One ore more FlyWire rootids defining a segment (in any form
  interpretable by
  [`ngl_segments`](https://rdrr.io/pkg/fafbseg/man/ngl_segments.html))

- sample:

  An absolute or fractional number of supervoxel ids to map to rootids
  or `FALSE` (see details).

- cloudvolume.url:

  URL for CloudVolume to fetch segmentation image data. The default
  value of NULL chooses the flywire production segmentation dataset.

- Verbose:

  When set to `TRUE` prints information about what fraction of

- ...:

  Additional arguments passed to
  [`flywire_latestid`](https://rdrr.io/pkg/fafbseg/man/flywire_latestid.html)

- x:

  a `data.frame` with at least one of: `root_id`, `pt_root_id`,
  `supervoxel_id` and/or `pt_supervoxel_id`. Supervoxels will be
  preferentially used to update the `root_id` column. Else a vector of
  `CRANT` root IDs.

- root.column:

  when `x` is a `data.frame`, the `root_id` column you wish to update

- supervoxel.column:

  when `x` is a `data.frame`, the `supervoxel_id` column you wish to use
  to update `root.column`

- position.column:

  when `x` is a `data.frame`, the `position` column with xyz values you
  wish to use to update `supervoxel.column`

## See also

[`crant_islatest`](https://flyconnectome.github.io/crantr/reference/crant_islatest.md)

Other crant-ids:
[`crant_islatest()`](https://flyconnectome.github.io/crantr/reference/crant_islatest.md),
[`crant_leaves()`](https://flyconnectome.github.io/crantr/reference/crant_leaves.md),
[`crant_rootid()`](https://flyconnectome.github.io/crantr/reference/crant_rootid.md),
[`crant_xyz2id()`](https://flyconnectome.github.io/crantr/reference/crant_xyz2id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
crant_latestid("576460752684030043")
} # }
```
