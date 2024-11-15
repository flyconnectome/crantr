% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/coords.R
\name{crant_voxdims}
\alias{crant_voxdims}
\alias{crant_nm2raw}
\alias{crant_raw2nm}
\title{Handle raw and nm calibrated CRANT coordinates}
\usage{
crant_voxdims(url = choose_crant(set = FALSE)[["fafbseg.sampleurl"]])

crant_nm2raw(x, vd = crant_voxdims())

crant_raw2nm(x, vd = crant_voxdims())
}
\arguments{
\item{url}{Optional neuroglancer URL containing voxel size. Defaults to
\code{getOption("fafbseg.sampleurl")} as set by
\code{\link{choose_crant}}.}

\item{x}{3D coordinates in any form compatible with \code{\link{xyzmatrix}}}

\item{vd}{The voxel dimensions in nm. Expert use only. Normally found
automatically.}
}
\value{
For \code{crant_voxdims} A 3-vector

for \code{crant_raw2nm} and \code{crant_nm2raw} an Nx3 matrix of
coordinates
}
\description{
\code{crant_voxdims} returns the image voxel dimensions which
are normally used to scale between \bold{raw} and \bold{nm} coordinates.
}
\details{
relies on nat >= 1.10.4
}
\examples{
crant_voxdims()
crant_raw2nm(c(37306, 31317, 1405))
crant_raw2nm('37306 31317 1405')
\dontrun{
crant_nm2raw(clipr::read_clip())
}
}
