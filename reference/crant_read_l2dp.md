# Read L2 dotprops for CRANT neurons

Fetches dotprops (points with tangent vectors) for CRANT neurons from
the L2 cache. These are fast to fetch and suitable for NBLAST.

## Usage

``` r
crant_read_l2dp(
  ids,
  units = c("nm", "microns"),
  OmitFailures = TRUE,
  datastack_name = crant_datastack_name(),
  ...
)
```

## Arguments

- ids:

  A vector of one or more neuron segment IDs to read.

- units:

  Units for the returned dotprops.

- OmitFailures:

  Logical; if TRUE, any segments that fail to be read are omitted from
  the results without an error (default=TRUE).

- datastack_name:

  An optional CAVE dataset name (expert use only, by default will choose
  the standard crant dataset). See details.

- ...:

  Additional arguments passed to python
  `fafbseg.flywire.get_l2_dotprops()`, e.g. `max_threads` or `min_size`.

## Value

A `neuronlist` of `dotprops` objects named by root id.

## Details

Each L2 chunk contributes one point (its representative coordinate) and
one vector (the first principal component of its voxels). Chunks missing
from the L2 cache or without a `pca` attribute (very small chunks) are
ignored.

This uses `get_l2_dotprops()` from the python fafbseg package (as does
[`fafbseg::read_l2dp()`](https://rdrr.io/pkg/fafbseg/man/read_l2skel.html)),
which fetches L2 ids and cache data in parallel. fafbseg does not know
about the CRANT CAVE server, so a CRANT client is placed in its client
cache before the call.

## See also

[`crant_read_l2skel()`](https://flyconnectome.github.io/crantr/reference/crant_read_l2skel.md),
[`crant_mirror()`](https://flyconnectome.github.io/crantr/reference/crant_mirror.md)

## Examples

``` r
if (FALSE) { # \dontrun{
dps <- crant_read_l2dp(crant_ids("cell_type:ExR1"), units = "microns")
} # }
```
