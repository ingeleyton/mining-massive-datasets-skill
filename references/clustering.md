# Clustering

## Use When

- The user asks about hierarchical clustering, k-means, BFR, CURE, GRGPF, stream clustering, or clustering tradeoffs.
- The task is about partitioning points rather than ranking, matching, or classification.

## Source Files

- `../notes/parte-24.md`: clustering basics, distances, curse of dimensionality, hierarchical clustering
- `../notes/parte-25.md`: k-means, initialization, BFR, Mahalanobis distance
- `../notes/parte-26.md`: CURE, GRGPF, non-Euclidean settings, representative points
- `../notes/parte-27.md`: clustering for streams, MapReduce clustering, windowed settings

## Common Asks

- Compare hierarchical clustering and k-means.
- Explain how BFR summarizes clusters.
- Choose between BFR, CURE, and GRGPF.
- Diagnose bad initialization or non-spherical cluster failure modes.
- Adapt clustering to streams or distributed data.

## Fast Routing

- Use `parte-24` for conceptual framing and distance choices.
- Use `parte-25` for k-means and BFR.
- Use `parte-26` for CURE, GRGPF, and non-Euclidean tradeoffs.
- Use `parte-27` for stream or distributed clustering.

## Watch Outs

- Many methods here assume Euclidean geometry or Gaussian-style structure.
- `stream` clustering is not the same as generic data-stream sketches.
- If the user needs overlap or graph communities, switch to graph mining instead.


