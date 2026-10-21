# Bring a local CRANT synapse snapshot up to date

Saves a new snapshot of the CRANT synapse table at a later time, by
applying the edits made since an existing snapshot. Queries at or near
the new snapshot time are then fast, since they need few or no CAVE
lookups.

## Usage

``` r
crant_update_snapshot(
  timestamp = "now",
  from = "latest",
  tag = NULL,
  root = crant_snapshot_root(),
  rebase = FALSE,
  set = TRUE
)
```

## Arguments

- timestamp:

  The time for the new snapshot: `"now"` (the default), `"latest"` for
  the time of the newest CAVE materialisation version, a POSIXct or a
  string accepted by
  [`as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html).

- from:

  The snapshot to start from, or `"latest"` (the default) for the most
  recent published or full snapshot in `root` at or before `timestamp`.

- tag:

  The name of the new snapshot. Defaults to the timestamp, e.g.
  `"20261001T120000"`.

- root:

  The snapshot folder. Defaults to
  [`crant_snapshot_root()`](https://flyconnectome.github.io/crantr/reference/crant_snapshot_root.md).

- rebase:

  Whether to also save the new snapshot as a full snapshot.

- set:

  Whether to make this the default snapshot for the session.

## Value

The result of
[`crant_use_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_use_snapshot.md)
for the new snapshot.

## Details

Only synapses on neurons that were edited since `from` are looked up in
CAVE, so updating a day-old snapshot typically takes seconds to minutes.
The new snapshot is saved as a small checkpoint of the synapses whose
root ids changed since `from`; use `rebase = TRUE` to also save a full
snapshot that later checkpoints start from.

## See also

[`crant_use_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_use_snapshot.md)

## Examples

``` r
if (FALSE) { # \dontrun{
crant_update_snapshot()
crant_partner_summary("576460752684030043", timestamp = "now")
} # }
```
