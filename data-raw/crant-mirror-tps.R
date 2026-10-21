## Thin plate spline mirror registration for CRANT (data/crant_mirror_tps.rda)
##
## Reads the mirror landmarks written by crant-mirror-warpfield.py (points on a
## 12 um grid in neuropil, their mirror images and mirror-of-mirror images, all
## in microns) and fits a TPS that maps each point to its mirror image.
##
## To make the spline (nearly) its own inverse, only points left of the
## midline are used, each as a pair in both directions (p -> M(p) and
## M(p) -> p). Points within half a grid step of the midline map one way only.
## Half the grid (a checkerboard) is held out to check the fit.
##
## Run from the package root:
##   Rscript data-raw/crant-mirror-tps.R

lm <- read.csv("data-raw/crant_mirror_landmarks.csv")
p <- as.matrix(lm[c("x", "y", "z")])
mp <- as.matrix(lm[c("mx", "my", "mz")])
colnames(p) <- colnames(mp) <- c("X", "Y", "Z")

spacing <- 12
xm <- median((p[, 1] + mp[, 1]) / 2)
cell <- round((p - spacing / 2) / spacing)
fit <- rowSums(cell) %% 2 == 0
left <- p[, 1] < xm - spacing / 2
mid <- abs(p[, 1] - xm) <= spacing / 2

use <- fit & left
usemid <- fit & mid
sample <- rbind(p[use, ], mp[use, ], p[usemid, ])
reference <- rbind(mp[use, ], p[use, ], mp[usemid, ])
crant_mirror_tps <- nat::tpsreg(sample, reference)
message(nrow(sample), " landmarks; midline x = ", round(xm, 1), " um")

# held out points: compare with warpfield and check the round trip
test <- !fit
tp <- nat::xform(p[test, ], crant_mirror_tps)
ttp <- nat::xform(tp, crant_mirror_tps)
d_wf <- sqrt(rowSums((tp - mp[test, ])^2))
d_rt <- sqrt(rowSums((ttp - p[test, ])^2))
q <- function(x) round(stats::quantile(x, c(0.5, 0.9, 1)), 2)
message("held out vs warpfield (um) median/90%/max: ",
        paste(q(d_wf), collapse = " / "))
message("held out round trip (um) median/90%/max: ",
        paste(q(d_rt), collapse = " / "))

usethis::use_data(crant_mirror_tps, overwrite = TRUE)
