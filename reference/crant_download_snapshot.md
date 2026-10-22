# Download or publish CRANT synapse snapshots

`crant_download_snapshot()` downloads the newest published synapse
snapshots into your snapshot folder; select one with
[`crant_use_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_use_snapshot.md)
to use it. The first download fetches the static data and a full
snapshot (about 1.8 GB); later ones usually just fetch a few small
checkpoints.

`crant_publish_snapshot()` is for whoever maintains the snapshots: it
makes the newest snapshot in `root`, and the earlier checkpoints it is
built on, available for download from a folder served over https.

## Usage

``` r
crant_download_snapshot(url = NULL, root = crant_snapshot_root(create = TRUE))

crant_publish_snapshot(dest, root = crant_snapshot_root(), snapshot = "latest")
```

## Arguments

- url:

  The address of the published snapshots (the folder or its
  `manifest.json`). The default (`NULL`) uses the `crantr.snapshot_url`
  option if set, and otherwise the standard address, which needs access
  to the CRANT CAVE datastack to work out.

- root:

  The local snapshot folder. Defaults to
  [`crant_snapshot_root()`](https://flyconnectome.github.io/crantr/reference/crant_snapshot_root.md).

- dest:

  The folder to publish into.

- snapshot:

  The snapshot to publish; `"latest"` (the default) for the newest one
  in `root`.

## Value

`crant_download_snapshot()`: the tags downloaded, invisibly.
`crant_publish_snapshot()`: the manifest, invisibly.

## Details

Snapshots are published with a `manifest.json` that lists every file
with its size and md5. A download only fetches snapshots that are not
already in `root` (snapshots never change once made) and checks each
file's md5, so an interrupted download is never mistaken for a snapshot;
just run it again. Downloads use the `curl` command line tool and resume
partial files.

Publishing hard links the files into `dest` when it is on the same
filesystem as `root` (otherwise they are copied), so it takes no extra
space. `manifest.json` is written last.

## See also

[`crant_use_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_use_snapshot.md),
[`crant_update_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_update_snapshot.md)

## Examples

``` r
if (FALSE) { # \dontrun{
crant_download_snapshot()
} # }
```
