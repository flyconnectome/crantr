# Read and write to the seatable for draft CRANT annotations

These functions use the logic and wrap some code from the `flytable_.*`
functions in the `fafbseg` R package. `crant_table_set_token` will
obtain and store a permanent seatable user-level API token.
`crant_table_query` performs a SQL query against a crant_table database.
You can omit the `base` argument unless you have tables of the same name
in different bases. `crant_table_base` returns a `base` object
(equivalent to a mysql database) which allows you to access one or more
tables, logging in to the service if necessary. The returned base object
give you full access to the Python
[`Base`](https://seatable.github.io/seatable-scripts/python/base/) API
allowing a range of row/column manipulations. `crant_table_update_rows`
updates existing rows in a table, returning TRUE on success.

## Usage

``` r
crant_table_query(
  sql = "SELECT * FROM CRANTb_meta",
  limit = 200000L,
  base = "CRANTb",
  python = FALSE,
  convert = TRUE,
  ac = NULL,
  workspace_id = "62919",
  token_name = "CRANTTABLE_TOKEN"
)

crant_table_set_token(
  user,
  pwd,
  url = "https://cloud.seatable.io/",
  token_name = "CRANTTABLE_TOKEN"
)

crant_table_login(
  url = "https://cloud.seatable.io/",
  token = Sys.getenv("CRANTTABLE_TOKEN", unset = NA_character_)
)

crant_table_update_rows(
  df,
  table = "CRANTb_meta",
  base = "CRANTb",
  append_allowed = FALSE,
  chunksize = 1000L,
  workspace_id = "62919",
  token_name = "CRANTTABLE_TOKEN",
  ...
)

crant_table_append_rows(
  df,
  table,
  base = NULL,
  chunksize = 1000L,
  token_name = "CRANTTABLE_TOKEN",
  workspace_id = "62919",
  ...
)

crant_table_updateids(table = "CRANTb_meta", base = "CRANTb")

crant_table_annotate(
  root_ids,
  update,
  overwrite = FALSE,
  append = FALSE,
  column = "notes",
  table = "CRANTb_meta",
  base = "CRANTb",
  workspace_id = "62919",
  token_name = "CRANTTABLE_TOKEN"
)
```

## Arguments

- sql:

  A SQL query string. See examples and [seatable
  docs](https://seatable.github.io/seatable-scripts/python/query/).

- limit:

  An optional limit, which only applies if you do not specify a limit
  directly in the `sql` query. By default seatable limits SQL queries to
  100 rows. We increase the limit to 200000 rows by default.

- base:

  Character vector specifying the `base`

- python:

  Logical. Whether to return a Python pandas DataFrame. The default of
  FALSE returns an R data.frame

- convert:

  Expert use only: Whether or not to allow the Python seatable module to
  process raw output from the database. This is is principally for
  debugging purposes. NB this imposes a requirement of seatable_api
  \>=2.4.0.

- ac:

  A seatable connection object as returned by `crant_table_login`.

- workspace_id:

  A numeric id specifying the workspace. Advanced use only

- token_name:

  The name of the token in your .Renviron file, should be
  `CRANTTABLE_TOKEN`.

- user, pwd:

  crant_table user and password used by `crant_table_set_token` to
  obtain a token

- url:

  Optional URL to the server

- token:

  normally retrieved from `CRANTTABLE_TOKEN` environment variable.

- df:

  A data.frame containing the data to upload including an `_id` column
  that can identify each row in the remote table.

- table:

  Character vector specifying a table for which you want a `base`
  object.

- append_allowed:

  Logical. Whether rows without row identifiers can be appended.

- chunksize:

  To split large requests into smaller ones with max this many rows.

- ...:

  additional arguments passed to pbsapply which might include cl=2 to
  specify a number of parallel jobs to run.

- root_ids:

  the CRANTb root ids to update, must be present in the seatable.

- update:

  the replacement entries you want in the chosen `column` for the given
  `root_ids`.

- overwrite:

  whether or not to overwrite entries in the chosen `column` for the
  given `root_ids`.

- append:

  if `overwrite==FALSE`, then whether or not to append (separated by a
  `,`) entries in the chosen `column` for the given `root_ids`.

- column:

  the column in the seatable to update for the given `root_ids`.

## Value

a `data.frame` of results. There should be 0 rows if no rows matched
query.

## See also

`fafbseg::`[`flytable_query`](https://rdrr.io/pkg/fafbseg/man/flytable-queries.html)

## Examples

``` r
if (FALSE) { # \dontrun{
# Do this once
crant_table_set_token(user="MY_EMAIL_FOR_SEATABLE.com",
                    pwd="MY_SEATABLE_PASSWORD",
                    url="https://cloud.seatable.io/")

# Thereafter:
crant.meta <- crant_table_query()

# A simple way to add annotations to specific neurons in the table quickly
# this is just for one entry type for one chosen column
crant_table_annotate(root_ids = c("576460752667713229",
                              "576460752662519193",
                              "576460752730083020",
                              "576460752673660716",
                              "576460752662521753"),
                 update = "lindsey_lopes",
                 overwrite = FALSE,
                 append = FALSE,
                 column = "user_annotator")
} # }
```
