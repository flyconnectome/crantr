# Simplified tissue surface for crant

`crantb.surf` is unsymmetrical and not a normalised version of the
dataset mesh. It is the outline of the dataset in nanometers. It can be
seen in neuroglancer
[here](https://spelunker.cave-explorer.org/#!middleauth+https://global.daf-apis.com/nglstate/api/v1/5185996221054976).

## Usage

``` r
crantb.surf
```

## Format

An object of class `hxsurf` (inherits from `list`) of length 4.

## Examples

``` r
if (FALSE) { # \dontrun{
# Depends on nat
library(nat)
rgl::wire3d(crantb.surf)
} # }
```
