# Set the token to be used to authenticate to CRANT autosegmentation resources

Set the token to be used to authenticate to CRANT autosegmentation
resources

## Usage

``` r
crant_set_token(token = NULL, domain = "https://proofreading.zetta.ai")
```

## Arguments

- token:

  An optional token string. When missing you are prompted to generate a
  new token via your browser.

- domain:

  the domain for which your CAVE token is valid, i.e. where the project
  is hosted.

## Value

The path to the token file (invisibly)
