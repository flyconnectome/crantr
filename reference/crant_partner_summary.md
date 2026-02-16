# Summarise the connectivity of CRANTb neurons

Returns synaptically connected partners for specified neurons.
Understanding synaptic partnerships is crucial for analyzing neural
circuits in the CRANTb connectome.

`crant_partners` returns details of each unitary synaptic connection
(including its xyz location).

## Usage

``` r
crant_partner_summary(
  rootids,
  partners = c("outputs", "inputs"),
  synapse_table = c("synapses_v2"),
  threshold = 0,
  remove_autapses = TRUE,
  cleft.threshold = 0,
  datastack_name = NULL,
  ...
)

crant_partners(
  rootids,
  partners = c("input", "output"),
  synapse_table = c("synapses_v2"),
  ...
)
```

## Arguments

- rootids:

  Character vector specifying one or more crant rootids. As a
  convenience this argument is passed to
  [`crant_ids`](https://flyconnectome.github.io/crantr/reference/crant_ids.md)
  allowing you to pass in data.frames, crant URLs or simple ids.

- partners:

  Character vector, either "input" or "output" to specify the direction
  of synaptic connections to retrieve.

- synapse_table:

  Character, the name of the synapse CAVE table you wish to use.
  Defaults to the latest.

- threshold:

  Integer threshold for minimum number of synapses (default 0).

- remove_autapses:

  Logical, whether to remove self-connections (default TRUE).

- cleft.threshold:

  Numeric threshold for cleft filtering (default 0).

- datastack_name:

  An optional CAVE `datastack_name`. If unset a sensible default is
  chosen.

- ...:

  Additional arguments passed to
  [`flywire_partner_summary`](https://rdrr.io/pkg/fafbseg/man/flywire_partners.html)

## Value

a data.frame

## Details

note that the rootids you pass in must be up to date. See example.

## See also

[`flywire_partner_summary`](https://rdrr.io/pkg/fafbseg/man/flywire_partners.html),
[`crant_latestid`](https://flyconnectome.github.io/crantr/reference/crant_latestid.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic connectivity analysis
sample_id=crant_latestid("576460752716912866")
head(crant_partner_summary(sample_id))
head(crant_partner_summary(sample_id, partners='inputs'))
} # }
if (FALSE) { # \dontrun{
# plot input and output synapses of a neuron
nclear3d()
fpi=crant_partners(crant_latestid("576460752716912866"), partners='in')
points3d(crant_raw2nm(fpi$post_pt_position), col='cyan')
fpo=crant_partners(crant_latestid("576460752716912866"), partners='out')
points3d(crant_raw2nm(fpo$pre_pt_position), col='red')
} # }
```
