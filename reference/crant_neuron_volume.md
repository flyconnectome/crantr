# Calculate neuron volume from CAVE L2 cache

Computes the total volume (in nm³) for one or more CRANTb neurons by
summing pre-computed `size_nm3` values from the CAVE L2 cache. This is
much faster than downloading full meshes.

## Usage

``` r
crant_neuron_volume(
  ids,
  OmitFailures = TRUE,
  datastack_name = crant_datastack_name(),
  ...
)
```

## Arguments

- ids:

  A vector of one or more neuron root IDs.

- OmitFailures:

  Logical; if `TRUE`, neurons that fail are returned as `NA` rather than
  raising an error (default `TRUE`).

- datastack_name:

  An optional CAVE dataset name (expert use only).

- ...:

  Additional arguments (currently unused).

## Value

A `data.frame` with columns:

- root_id:

  Character root ID

- volume_nm3:

  Total volume in cubic nanometers

## Details

For each neuron, `crant_neuron_volume` retrieves all Level 2 chunk IDs
via the chunkedgraph, then queries the L2 cache for the `size_nm3`
attribute of each chunk. The total neuron volume is the sum across all
chunks.

The L2 cache stores pre-computed statistics that are updated after every
CAVE edit, so results reflect the current segmentation state.

## See also

[`crant_read_l2skel`](https://flyconnectome.github.io/crantr/reference/crant_read_l2skel.md)
for L2 skeleton data

## Examples

``` r
if (FALSE) { # \dontrun{
# Single neuron
crant_neuron_volume("576460752653449509")

# Multiple neurons
ids <- c("576460752653449509", "576460752686359273")
crant_neuron_volume(ids)
} # }
```
