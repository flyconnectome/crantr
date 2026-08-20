# Find a good "key" point on a CRANT neuron to associate with annotations

The chosen point sits at the major branch point of the L2 skeleton of
each neuron. By default the L2 skeleton is rerooted onto the endpoint
furthest from the current root so that a simplified representation with
one branch point can be calculated; without this, the longest path from
the root may not contain a branch point at all. If no branch point can
be identified the original root point is used as a fallback.

## Usage

``` r
crant_key_point(ids, raw = TRUE, reroot = TRUE, ...)
```

## Arguments

- ids:

  One or more CRANT root ids (anything accepted by
  [`crant_ids()`](https://flyconnectome.github.io/crantr/reference/crant_ids.md)).

- raw:

  Whether to return points in raw (voxel) space (default) or nm.

- reroot:

  Whether to reroot the incoming neuron onto the furthest endpoint
  before simplifying.

- ...:

  Additional arguments passed to
  [`crant_read_l2skel()`](https://flyconnectome.github.io/crantr/reference/crant_read_l2skel.md).

## Value

An N x 3 matrix of point locations (one row per input id). Ids whose
skeleton or key point could not be computed yield a row of `NA`s.

## Details

Reads an L2 skeleton for each id via
[`crant_read_l2skel()`](https://flyconnectome.github.io/crantr/reference/crant_read_l2skel.md)
and picks the principal branch point with
[`fafbseg::key_point_from_neuron()`](https://rdrr.io/pkg/fafbseg/man/key_point_from_neuron.html).

Unlike the flywire and aedes datasets, the CRANT segmentation is hosted
on a separate CAVE server (proofreading.zetta.ai), which the Python
`fafbseg` package cannot currently target. This means
[`fafbseg::read_l2skel()`](https://rdrr.io/pkg/fafbseg/man/read_l2skel.html)
(and therefore
[`fafbseg::flywire_key_point()`](https://rdrr.io/pkg/fafbseg/man/key_point_from_neuron.html))
cannot reach it, so this function reads via
[`crant_read_l2skel()`](https://flyconnectome.github.io/crantr/reference/crant_read_l2skel.md)
(pcg_skel) rather than sharing the flywire read path. It is consequently
slower than its flywire/aedes equivalent.

## See also

[`fafbseg::key_point_from_neuron()`](https://rdrr.io/pkg/fafbseg/man/key_point_from_neuron.html),
[`crant_read_l2skel()`](https://flyconnectome.github.io/crantr/reference/crant_read_l2skel.md)

## Examples

``` r
if (FALSE) { # \dontrun{
crant_key_point("576460752653449509")
} # }
```
