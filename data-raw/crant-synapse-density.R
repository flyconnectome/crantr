## Synapse density image of the CRANT brain, for building a mirror registration
## with CMTK (as for aedes_aedesSym_1000_tps.rds in the aedes package).
##
## Counts presynaptic points from the local synapse snapshot (see
## crant_use_snapshot()) on a regular grid in DuckDB, smooths with a Gaussian
## and writes an 8-bit NRRD in microns. A copy flipped along the mirror axis
## is written too.
##
## Run from the package root:
##   Rscript data-raw/crant-synapse-density.R [outdir] [voxel_um] [sigma_vox]

args <- commandArgs(trailingOnly = TRUE)
outdir <- if (length(args) >= 1) args[1] else "."
vox <- if (length(args) >= 2) as.numeric(args[2]) else 1      # microns
sigma <- if (length(args) >= 3) as.numeric(args[3]) else 1.5 # voxels
flip_axis <- 1L  # x is medio-lateral in CRANT

suppressMessages(devtools::load_all(quiet = TRUE))
library(dplyr)

# every pre/post pair counts, so polyadic T-bars are weighted by their number
# of partners. Synapses on root 0 are kept: they are still real synapses.
# Voxel i is centred on i * vox microns, so the image origin is 0 (CMTK
# dislikes non-zero origins) and image coordinates are CRANT nm / 1000.
vnm <- vox * 1000
counts <- crant_synapse_data(details = TRUE) %>%
  filter(!is.na(.data$pre_x)) %>%
  mutate(i = as.integer(round(.data$pre_x / vnm)),
         j = as.integer(round(.data$pre_y / vnm)),
         k = as.integer(round(.data$pre_z / vnm))) %>%
  count(.data$i, .data$j, .data$k) %>%
  collect()

pad <- ceiling(4 * sigma)
dims <- c(max(counts$i), max(counts$j), max(counts$k)) + 1L + pad
img <- array(0, dim = dims)
img[cbind(counts$i + 1L, counts$j + 1L, counts$k + 1L)] <- as.numeric(counts$n)

# separable Gaussian smoothing
gauss_smooth <- function(a, sigma) {
  if (sigma <= 0) return(a)
  r <- ceiling(3 * sigma)
  kern <- dnorm(-r:r, sd = sigma)
  kern <- kern / sum(kern)
  # zero pad so the kernel fits at the edges (the brain reaches z = 0)
  smooth1 <- function(v) {
    z <- stats::filter(c(rep(0, r), v, rep(0, r)), kern, sides = 2)
    z[(r + 1):(r + length(v))]
  }
  for (d in 1:3) {
    perm <- c(d, setdiff(1:3, d))
    a <- aperm(a, perm)
    dd <- dim(a)
    a <- array(apply(matrix(a, nrow = dd[1]), 2, smooth1), dim = dd)
    a <- aperm(a, order(perm))
  }
  a
}
img <- gauss_smooth(img, sigma)

# scale to 8 bit, saturating the densest 0.1% of non-empty voxels
top <- stats::quantile(img[img > 0], 0.999)
img8 <- array(as.integer(round(pmin(img / top, 1) * 255)), dim = dims)

base <- file.path(outdir, sprintf("crant_syndensity_%gum", vox))
write_img <- function(a, f)
  nat::write.im3d(nat::im3d(a, voxdims = rep(vox, 3), origin = c(0, 0, 0)), f,
                  dtype = "byte")
write_img(img8, paste0(base, ".nrrd"))
flipped <- switch(flip_axis,
                  img8[dims[1]:1, , ], img8[, dims[2]:1, ], img8[, , dims[3]:1])
write_img(flipped, paste0(base, "_flip.nrrd"))

# maximum projections to check orientation and contrast
for (d in 1:3) {
  mip <- apply(img8, setdiff(1:3, d), max)
  png::writePNG(t(mip) / 255, paste0(base, "_mip", c("x", "y", "z")[d], ".png"))
}
message("Wrote ", base, ".nrrd: ", paste(dims, collapse = " x "),
        " voxels at ", vox, " um; mirror axis size ",
        (dims[flip_axis] - 1) * vox, " um")
