# Changelog

## crantr 0.3.0

Fast local synapse snapshots for connectivity queries at any time up to
the present, plus mirroring across the midline and fast L2 dotprops for
mirrored NBLAST. See
[`vignette("synapse-snapshots")`](https://flyconnectome.github.io/crantr/articles/synapse-snapshots.md).

- New local synapse snapshot functions, using the snapshot code in aedes
  (Suggests):
  [`crant_use_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_use_snapshot.md),
  [`crant_download_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_download_snapshot.md),
  [`crant_update_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_update_snapshot.md),
  [`crant_synapse_data()`](https://flyconnectome.github.io/crantr/reference/crant_synapse_data.md),
  [`crant_snapshot_root()`](https://flyconnectome.github.io/crantr/reference/crant_snapshot_root.md)
  and
  [`crant_publish_snapshot()`](https://flyconnectome.github.io/crantr/reference/crant_download_snapshot.md).
  The first download is about 1.8 GB; daily checkpoints are then fetched
  automatically
  ([\#4](https://github.com/flyconnectome/crantr/issues/4)).
- [`crant_partner_summary()`](https://flyconnectome.github.io/crantr/reference/crant_partner_summary.md)
  and
  [`crant_partners()`](https://flyconnectome.github.io/crantr/reference/crant_partner_summary.md)
  gain `method = c("auto", "cave", "local")` and explicit
  `version`/`timestamp`; `"auto"` answers from the selected snapshot
  when possible, otherwise CAVE as before
  ([\#4](https://github.com/flyconnectome/crantr/issues/4)).
- `data-raw` scripts to download a CAVE synapse table and build the
  first snapshot, and an internal `crant_synsnap_server()` with a cron
  script (`inst/scripts/synsnap-cron.sh`) to make and publish daily
  checkpoints ([\#4](https://github.com/flyconnectome/crantr/issues/4)).
- New
  [`crant_mirror()`](https://flyconnectome.github.io/crantr/reference/crant_mirror.md)
  mirrors points, neurons, meshes and dotprops across the midline (nm or
  microns), keeping dotprops tangent vectors
  ([\#5](https://github.com/flyconnectome/crantr/issues/5)).
- New `crant_mirror_tps` dataset: a thin plate spline mirror
  registration built from CRANT synapse density
  ([\#5](https://github.com/flyconnectome/crantr/issues/5)).
- New
  [`crant_read_l2dp()`](https://flyconnectome.github.io/crantr/reference/crant_read_l2dp.md)
  quickly fetches dotprops suitable for NBLAST from the L2 cache, via
  python fafbseg using the CRANT token
  ([\#6](https://github.com/flyconnectome/crantr/issues/6)).
- New vignette on synapse snapshots (fc00222).
- Fixed
  [`crant_updateids()`](https://flyconnectome.github.io/crantr/reference/crant_latestid.md)
  bookkeeping of old ids during the position-based update (3eb567b).
- Documentation regenerated with roxygen2 8.1.0 (01fed0b).

**Full Changelog**:
<https://github.com/flyconnectome/crantr/compare/7861ea3>…v0.3.0

## crantr 0.2.1

- New
  [`crant_key_point()`](https://flyconnectome.github.io/crantr/reference/crant_key_point.md)
  returns a “good” annotation point on a neuron: the principal branch
  point of its L2 skeleton, with the neuron optionally rerooted onto its
  furthest endpoint first. Shares the dataset-agnostic
  [`fafbseg::key_point_from_neuron()`](https://rdrr.io/pkg/fafbseg/man/key_point_from_neuron.html)
  helper but reads via
  [`crant_read_l2skel()`](https://flyconnectome.github.io/crantr/reference/crant_read_l2skel.md)
  because the CRANT segmentation is hosted on a separate CAVE server
  that
  [`fafbseg::read_l2skel()`](https://rdrr.io/pkg/fafbseg/man/read_l2skel.html)
  cannot currently reach (requires `fafbseg (>= 0.15.15)`).

## crantr 0.2.0

Metadata rework, now backed by
[`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html)
(requires `fafbseg (>= 0.15.12)`):

- [`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md)
  is now a thin wrapper around
  [`fafbseg::cam_meta()`](https://rdrr.io/pkg/fafbseg/man/cam_meta.html)
  pointed at the CRANTb_meta seatable. Column normalisation to the
  coconat/crantr schema is opt-in via `normalise_colnames = TRUE`, and
  `translate_ids` is exposed to keep returned root ids consistent with a
  requested `version`/`timestamp`.
- [`crant_meta()`](https://flyconnectome.github.io/crantr/reference/crant_meta.md)
  gains `drop_status` (default `"DUPLICATED"`) so CRANT’s known
  duplicate rows are filtered by default; pass `drop_status = NULL` to
  keep them.
- [`crant_ids()`](https://flyconnectome.github.io/crantr/reference/crant_ids.md)
  gains `na.rm` (default `FALSE`) to drop missing root ids. The coconat
  id functions set this so CRANTb_meta’s incomplete rows no longer
  surface as spurious null-segment `"0"` ids.
- Fixed
  [`crant_ids()`](https://flyconnectome.github.io/crantr/reference/crant_ids.md)
  query lookup and its `integer64` default.
- The legacy metadata cache API is deprecated in favour of the above.

## crantr 0.1.0

- Initial CRAN submission.
