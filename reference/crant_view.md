# Set Default View for CRANT EM Dataset

This function sets a default view for visualizing the 'CRANT' Electron
Microscopy (EM) dataset using the rgl package. It adjusts the viewpoint
to a specific orientation and zoom level that is optimal for viewing
this particular dataset.

## Usage

``` r
crant_view()

crant_side_view()

crant_back_view()
```

## Value

This function is called for its side effect of changing the rgl
viewpoint. It does not return a value.

## Details

The function uses
[`rgl::rgl.viewpoint()`](https://dmurdoch.github.io/rgl/dev/reference/rgl-defunct.html)
to set a predefined user matrix and zoom level. This matrix defines the
rotation and translation of the view, while the zoom parameter adjusts
the scale of the visualization.

## Note

This function assumes that an rgl device is already open and that the
CRANT EM dataset has been plotted. It will not create a new plot or open
a new rgl device.

## See also

[`rgl.viewpoint`](https://dmurdoch.github.io/rgl/dev/reference/rgl-defunct.html)
for more details on setting viewpoints in rgl.

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming you have already plotted your CRANT EM data
crant_view()
} # }
```
