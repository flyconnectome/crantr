# Read L2 skeleton for crant neurons using pcg_skel

This function reads level 2 (L2) node data for neuron segmentations in
the crant ant brain connectome dataset. It uses the pcg_skel Python
library to create a skeleton object, which is then converted into a nat
neuron object in R.

## Usage

``` r
crant_read_l2skel(
  ids,
  OmitFailures = TRUE,
  datastack_name = crant_datastack_name(),
  ...
)
```

## Arguments

- ids:

  A vector of one or more neuron segment IDs to read.

- OmitFailures:

  Logical; if TRUE, any segments that fail to be read are omitted from
  the results without an error (default=TRUE).

- datastack_name:

  An optional CAVE dataset name (expert use only, by default will choose
  the standard crant dataset). See details.

- ...:

  Additional arguments passed to internal functions.

## Value

A `neuronlist` containing one or more `neuron` objects. Note that
neurons will be calibrated in nanometers (nm).

## Details

`crant_read_l2skel` works by:

1.  Validating the input IDs using `crant_ids`.

2.  Using pcg_skel to generate a skeleton for each neuron segment.

3.  Converting the pcg_skel skeleton to an SWC format DataFrame.

4.  Converting the SWC DataFrame into a nat neuron object.

This function relies on the pcg_skel Python library
(https://github.com/AllenInstitute/pcg_skel) for skeleton generation.
Ensure that pcg_skel is installed in your Python environment.

## References

pcg_skel Python library: https://github.com/AllenInstitute/pcg_skel

## See also

[`crant_ids`](https://flyconnectome.github.io/crantr/reference/crant_ids.md)
for ID validation [`neuron`](https://rdrr.io/pkg/nat/man/neuron.html)
for details on the neuron object structure
[`neuronlist`](https://rdrr.io/pkg/nat/man/neuronlist.html) for details
on the neuronlist object structure

## Examples

``` r
if (FALSE) { # \dontrun{
# One-time installation of necessary Python packages
fafbseg::simple_python('none', pkgs='numpy~=1.23.5')
fafbseg::simple_python(pkgs="pcg_skel")

# Read a single neuron
ant.neuron <- crant_read_l2skel("576460752653449509")

# Plot the neuron
plot3d(ant.neuron)

# Plot with crant surface (assuming crant.surf is available)
plot3d(crant.surf, alpha = 0.1, col = "lightgrey")
} # }
```
