# Use a local snapshot of the CRANT synapse table

Selects a downloaded snapshot of the CRANT synapse table so that
[`crant_partner_summary()`](https://flyconnectome.github.io/crantr/reference/crant_partner_summary.md),
[`crant_partners()`](https://flyconnectome.github.io/crantr/reference/crant_partner_summary.md)
and
[`crant_synapse_data()`](https://flyconnectome.github.io/crantr/reference/crant_synapse_data.md)
can answer queries locally, without contacting CAVE for synapses. Each
snapshot records the root id of both partners of every synapse at one
moment in time.

## Usage

``` r
crant_use_snapshot(
  snapshot = NULL,
  version = NULL,
  timestamp = NULL,
  root = crant_snapshot_root(),
  set = TRUE
)
```

## Arguments

- snapshot:

  The snapshot tag, or `"latest"` for the most recent snapshot in
  `root`. The default (`NULL`) chooses one to match `version` or
  `timestamp`.

- version, timestamp:

  A CAVE materialisation version or a timestamp (including `"now"`) to
  choose the snapshot for.

- root:

  The snapshot folder. Defaults to
  [`crant_snapshot_root()`](https://flyconnectome.github.io/crantr/reference/crant_snapshot_root.md).

- set:

  Whether to make this the default snapshot for the session.

## Value

When `set = TRUE`, the previous option values (invisibly, suitable for
passing to [`options()`](https://rdrr.io/r/base/options.html)).
Otherwise a list with the snapshot `tag`, `timestamp` and `root`.

## Details

A snapshot folder contains `static.parquet` (one row per synapse, with
its supervoxels, positions in nm and size) and one sub-folder per
snapshot tag. A full snapshot has the root ids of every synapse; a
checkpoint has only the synapses whose root ids changed since an earlier
snapshot. Queries use DuckDB (from the suggested packages duckdb, DBI
and dbplyr) and only read the parts of the parquet files that they need.
DuckDB uses every core; set the `aedes.duckdb_threads` option before the
first query to use fewer, e.g. on a shared machine.

The snapshot code currently lives in the aedes package, which must be
installed (see the vignette).

When no `snapshot` is given, the newest one at or before `timestamp` (or
the time of `version`) is used, or the newest one of all when neither is
given. Queries for times after the snapshot fetch the edits made since
then from CAVE (see
[`crant_synapse_data()`](https://flyconnectome.github.io/crantr/reference/crant_synapse_data.md)).

If there is no snapshot in `root`, you are asked whether to download one
with
[`crant_download_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_download_snapshot.md)
(in an interactive session) or get an error saying how to.

Every few hours (the `crantr.snapshot_check_hours` option, default 6;
`Inf` turns this off) it also downloads any new checkpoints that have
been published. A new full snapshot is only announced, since it is
larger: fetch it with
[`crant_download_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_download_snapshot.md).

## See also

[`crant_partner_summary()`](https://flyconnectome.github.io/crantr/reference/crant_partner_summary.md),
[`crant_synapse_data()`](https://flyconnectome.github.io/crantr/reference/crant_synapse_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
crant_use_snapshot()
# now answered locally
crant_partner_summary("576460752684030043")
} # }
```
