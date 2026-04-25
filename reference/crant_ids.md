# Make sure given root IDs look like CRANT root IDs

Make sure given root IDs look like CRANT root IDs

## Usage

``` r
crant_ids(x, integer64 = NA)
```

## Arguments

- x:

  A data.frame, URL or vector of ids

- integer64:

  Whether to return ids as
  [`bit64::integer64`](https://bit64.r-lib.org/reference/bit64-package.html)
  or character vectors. Default value of NA leaves the ids unmodified.
