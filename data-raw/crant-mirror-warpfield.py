"""Mirror landmarks for CRANT from a warpfield registration.

Registers the X-flipped synapse density image (see crant-synapse-density.R)
onto the original with warpfield (https://github.com/danionella/warpfield; the
MLX backend for Apple Silicon is in schlegelp/warpfield@mlx_prototype_v2) and
writes a grid of points in neuropil with their mirror images to a CSV, which
crant-mirror-tps.R turns into a thin plate spline.

Images have origin 0 and 1 um voxels, so voxel coordinates are microns
(= CRANT nm / 1000).

Usage (from the package root):
  python data-raw/crant-mirror-warpfield.py \
    data-raw/crant_syndensity_1um.nrrd data-raw/crant_syndensity_1um_flip.nrrd \
    data-raw/crant-mirror-warpfield.yml data-raw/crant_mirror_landmarks.csv
"""

import sys

import numpy as np
import warpfield

ref_path, mov_path, recipe_path, out_path = sys.argv[1:5]
spacing = 12  # grid spacing in voxels (um)
threshold = 20  # minimum 8 bit density for a grid point to count as neuropil

ref, _ = warpfield.load_data(ref_path)  # pynrrd reads axes as x, y, z
mov, _ = warpfield.load_data(mov_path)
recipe = warpfield.Recipe.from_yaml(recipe_path)
_, wm, _ = warpfield.register_volumes(
    ref.astype(np.float32), mov.astype(np.float32), recipe, verbose=False
)

# push_coordinates maps fixed (original) to moving (flipped) voxel coordinates;
# undoing the flip gives the mirror image in original coordinates
nx = ref.shape[0]


def mirror(p):
    q = np.asarray(wm.push_coordinates(p.astype(np.float32)), dtype=np.float64)
    q[0] = (nx - 1) - q[0]
    return q


grid = np.mgrid[tuple(slice(spacing // 2, n, spacing) for n in ref.shape)]
p = grid.reshape(3, -1)
p = p[:, ref[tuple(p)] >= threshold].astype(np.float64)
mp = mirror(p)
mmp = mirror(mp)

out = np.column_stack([p.T, mp.T, mmp.T])
np.savetxt(out_path, out, delimiter=",", fmt="%.3f", comments="",
           header="x,y,z,mx,my,mz,mmx,mmy,mmz")
err = np.linalg.norm(mmp - p, axis=0)
print(f"{p.shape[1]} points; round trip error median {np.median(err):.2f} "
      f"90% {np.percentile(err, 90):.2f} um")
