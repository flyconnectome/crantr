# Plot a neuron in the CRANT connectomic dataset using ggplot2

This function visualizes a neuron or neuron-related object from the
CRANT connectomic dataset using ggplot2. The only thing specific to the
CRANT data set is are the prreset 'view' angles.

## Usage

``` r
crant_ggneuron(
  x,
  volume = NULL,
  info = NULL,
  view = c("front", "side", "back"),
  cols1 = c("turquoise", "navy"),
  cols2 = c("grey75", "grey50"),
  alpha = 0.5,
  title.col = "darkgrey",
  ...
)
```

## Arguments

- x:

  A 'neuron', 'neuronlist', 'mesh3d', or 'hxsurf' object to be
  visualized.

- volume:

  A brain/neuropil volume to be plotted in grey, for context. Defaults
  to NULL, no volume plotted.

- info:

  Optional. A string to be used as the plot title.

- view:

  A character string specifying the view orientation. Options are
  "front", "side", "back".

- cols1:

  A vector of two colors for the lowest Z values. Default is
  c("turquoise", "navy").

- cols2:

  A vector of two colors for the highest Z values. Default is
  c("grey75", "grey50").

- alpha:

  Transparency of the neuron visualization. Default is 0.5.

- title.col:

  Color of the plot title. Default is "darkgrey".

- ...:

  Additional arguments passed to `nat.ggplot::geom_neuron().`

## Value

A ggplot object representing the visualized neuron.

## Details

This function is a wrapper around the ggneuron function, specifically
tailored for the CRANT dataset. It applies a rotation matrix based on
the specified view and uses predefined color schemes.
