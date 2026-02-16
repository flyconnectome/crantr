# Convert xyz locations to CRANT root or supervoxel ids

Convert xyz locations to CRANT root or supervoxel ids

## Usage

``` r
crant_xyz2id(
  xyz,
  rawcoords = FALSE,
  root = TRUE,
  integer64 = FALSE,
  fast_root = TRUE,
  method = c("cloudvolume", "spine"),
  ...
)
```

## Arguments

- xyz:

  One or more xyz locations as an Nx3 matrix or in any form compatible
  with [`xyzmatrix`](https://rdrr.io/pkg/fafbseg/man/xyzmatrix.html)
  including `neuron` or `mesh3d` surface objects.

- rawcoords:

  whether the input values are raw voxel indices or in nm

- root:

  Whether to return the root id of the whole segment rather than the
  supervoxel id.

- integer64:

  Whether to return ids as integer64 type (more compact but a little
  fragile) rather than character (default `FALSE`).

- fast_root:

  Whether to use a fast but two-step look-up procedure when finding
  roots. This is strongly recommended and the alternative approach has
  only been retained for validation purposes.

- method:

  Whether to use the [spine
  transform-service](https://services.itanna.io/app/transform-service/docs)
  API or cloudvolume for lookup. `"auto"` is presently a synonym for
  `"spine"`.

- ...:

  additional arguments passed to `pbapply` when looking up multiple
  positions.

## Value

A character vector of segment ids, NA when lookup fails.

## Details

This used to be very slow because we do not have a supervoxel field on
spine.

I am somewhat puzzled by the voxel dimensions for crant. Neuroglancer
clearly shows voxel coordinates of 4.3x4.3x45. But in this function, the
voxel coordinates must be set to 4.25 in x-y to give the correct
answers.

## See also

[`flywire_xyz2id`](https://rdrr.io/pkg/fafbseg/man/flywire_xyz2id.html)

Other crant-ids:
[`crant_islatest()`](https://flyconnectome.github.io/crantr/reference/crant_islatest.md),
[`crant_latestid()`](https://flyconnectome.github.io/crantr/reference/crant_latestid.md),
[`crant_leaves()`](https://flyconnectome.github.io/crantr/reference/crant_leaves.md),
[`crant_rootid()`](https://flyconnectome.github.io/crantr/reference/crant_rootid.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# a point from neuroglancer, should map to 576460752684030043
crant_xyz2id(cbind(37306, 31317, 1405), rawcoords=TRUE)
} # }
```
