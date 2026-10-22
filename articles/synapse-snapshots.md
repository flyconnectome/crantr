# Local Synapse Snapshots

A local synapse snapshot is a copy of the whole CRANTb synapse table on
your own machine. Partner queries for hundreds of neurons then take
seconds rather than minutes, at a materialisation version or right up to
the current time. You also get the full synapse table, including the
position of every synapse.

The code is shared with the
[aedes](https://flyconnectome.github.io/aedes/) package, which must be
installed (it is only suggested by crantr):

``` r

pak::pak("flyconnectome/aedes")
```

See the aedes [Local Synapse
Snapshots](https://flyconnectome.github.io/aedes/articles/synapse-snapshots.html)
article for how snapshots work, how recent edits are handled and how
they are built and published. Everything there applies to crantr, with
`aedes_*` functions replaced by their `crant_*` equivalents.

## Getting started

You need access to the CRANT CAVE datastack.

``` r

library(crantr)
crant_use_snapshot()
```

The first time,
[`crant_use_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_use_snapshot.md)
offers to download a snapshot; you can also do this with
[`crant_download_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_download_snapshot.md).
This is about 1.8 GB, once only: 1.35 GB of static data for the 88
million synapses (ids, supervoxels, positions and size), which never
changes, and a 0.4 GB base snapshot giving the root ids of every synapse
at one materialisation version. After that, daily checkpoints of a few
tens of KB are fetched automatically when you use the snapshot.

## Partner queries

Once a snapshot is selected,
[`crant_partner_summary()`](https://flyconnectome.github.io/crantr/reference/crant_partner_summary.md)
and
[`crant_partners()`](https://flyconnectome.github.io/crantr/reference/crant_partner_summary.md)
answer queries from it whenever they can, and otherwise fall back to
CAVE. Use `method = "local"` to insist on the snapshot, or
`method = "cave"` to skip it.

``` r

id <- "576460752684030043"
# up to the second: edits since the newest snapshot are fetched from CAVE
crant_partner_summary(id, partners = "inputs")
# at a materialisation version, with no CAVE lookups
crant_partner_summary(id, partners = "inputs", version = crant_version())
# individual synapses, with their positions
crant_partners(id, partners = "output", method = "local")
```

Root ids only make sense at one time, so for an analysis that makes
several queries fix the time once and use it throughout:

``` r

now <- Sys.time()
ins <- crant_partner_summary(id, partners = "inputs", timestamp = now)
outs <- crant_partner_summary(id, partners = "outputs", timestamp = now)
```

## The synapse table

[`crant_synapse_data()`](https://flyconnectome.github.io/crantr/reference/crant_synapse_data.md)
gives the whole table as a lazy `dplyr` table backed by
[DuckDB](https://duckdb.org), so you can run your own queries over all
synapses, at a snapshot or (with `timestamp`) any later time.
`details = TRUE` adds supervoxels, positions (in nm) and size.

``` r

library(dplyr)
id64 <- bit64::as.integer64(id)
crant_synapse_data(timestamp = now) |>
  filter(pre_root %in% id64) |>
  count(post_root, sort = TRUE) |>
  collect()
```

## Updating a snapshot

Snapshots are updated automatically, but you can save your own snapshot
at a later time, which makes repeated queries at that time fast:

``` r

crant_update_snapshot()
```
