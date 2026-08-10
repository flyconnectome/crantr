# Changelog

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
