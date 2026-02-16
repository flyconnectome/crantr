# Add synapses to neuron objects

This function family adds synaptic data to neuron objects or neuron
lists. It retrieves synaptic connections and attaches them to the neuron
object(s).

## Usage

``` r
crant_add_synapses(
  x,
  id = NULL,
  connectors = NULL,
  size.threshold = 5,
  remove.autapses = TRUE,
  update.id = TRUE,
  ...
)

# S3 method for class 'neuron'
crant_add_synapses(
  x,
  id = NULL,
  connectors = NULL,
  size.threshold = 5,
  remove.autapses = TRUE,
  update.id = TRUE,
  ...
)

# S3 method for class 'neuronlist'
crant_add_synapses(
  x,
  id = NULL,
  connectors = NULL,
  size.threshold = 5,
  remove.autapses = TRUE,
  update.id = TRUE,
  ...
)

# Default S3 method
crant_add_synapses(
  x,
  id = NULL,
  connectors = NULL,
  size.threshold = 5,
  remove.autapses = TRUE,
  update.id = TRUE,
  ...
)
```

## Arguments

- x:

  A neuron object, neuronlist, or other object to add synapses to

- id:

  The root ID of the neuron. If `NULL`, it uses the ID from the neuron
  object

- connectors:

  A dataframe of synaptic connections. If `NULL`, it retrieves the data

- size.threshold:

  Minimum size threshold for synapses to include

- remove.autapses:

  Whether to remove autapses (self-connections)

- update.id:

  Logical, whether or not to use `crant_latestid` to update the neuron's
  `root_id` when fetching synapses.

- ...:

  Additional arguments passed to methods,
  [`nat::nlapply`](https://rdrr.io/pkg/nat/man/nlapply.html)

## Value

An object of the same type as `x`, with synapses added

## Examples

``` r
if (FALSE) { # \dontrun{
# Get CRANT ID for a olfactory PN
id <- "720575941572711675"
id <- crant_latestid(id)

# Get the L2 skeletons
n <- crant_read_l2skel(id)

# Add synapse information, stored at n.syn[[1]]$connectors
n.syn <- crant_add_synapses(n)

# Split neuron
n.split <- hemibrainr::flow_centrality(n.syn)

} # }
```
