# crantr 0.2.1

* New `crant_key_point()` returns a "good" annotation point on a neuron: the
  principal branch point of its L2 skeleton, with the neuron optionally
  rerooted onto its furthest endpoint first. Shares the dataset-agnostic
  `fafbseg::key_point_from_neuron()` helper but reads via `crant_read_l2skel()`
  because the CRANT segmentation is hosted on a separate CAVE server that
  `fafbseg::read_l2skel()` cannot currently reach (requires
  `fafbseg (>= 0.15.15)`).

# crantr 0.2.0

Metadata rework, now backed by `fafbseg::cam_meta()` (requires
`fafbseg (>= 0.15.12)`):

* `crant_meta()` is now a thin wrapper around `fafbseg::cam_meta()` pointed at
  the CRANTb_meta seatable. Column normalisation to the coconat/crantr schema is
  opt-in via `normalise_colnames = TRUE`, and `translate_ids` is exposed to keep
  returned root ids consistent with a requested `version`/`timestamp`.
* `crant_meta()` gains `drop_status` (default `"DUPLICATED"`) so CRANT's known
  duplicate rows are filtered by default; pass `drop_status = NULL` to keep them.
* `crant_ids()` gains `na.rm` (default `FALSE`) to drop missing root ids. The
  coconat id functions set this so CRANTb_meta's incomplete rows no longer
  surface as spurious null-segment `"0"` ids.
* Fixed `crant_ids()` query lookup and its `integer64` default.
* The legacy metadata cache API is deprecated in favour of the above.

# crantr 0.1.0

* Initial CRAN submission.
