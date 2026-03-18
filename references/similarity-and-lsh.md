# Similarity And LSH

## Use When

- The task is about near-duplicate detection, Jaccard, shingling, MinHash, LSH, banding, entity resolution, or high-similarity filtering.
- The user wants to choose a similarity metric or compare exact and approximate similarity search.

## Source Files

- `../notes/parte-07.md`: Jaccard, finding similar items, set and bag similarity
- `../notes/parte-08.md`: shingling, k-shingles, MinHash, signature matrices
- `../notes/parte-09.md`: banding, LSH thresholds, distance families
- `../notes/parte-10.md`: LSH families for Hamming, cosine, and Euclidean distance
- `../notes/parte-11.md`: entity resolution, fingerprints, stop-word shingles, prefix filtering

## Common Asks

- Choose between Jaccard, cosine, Hamming, Euclidean, or edit distance.
- Explain how MinHash approximates Jaccard.
- Tune LSH bands and rows.
- Decide when exact high-similarity filtering beats LSH.
- Build an entity-resolution workflow.

## Fast Routing

- Use `parte-07` to `parte-08` for document similarity and MinHash basics.
- Use `parte-09` to `parte-10` for threshold curves, banding, and metric-specific LSH.
- Use `parte-11` for entity resolution and exact filtering methods.

## Watch Outs

- `similarity` alone is too vague. Pin the representation first: set, bag, vector, or string.
- Do not use LSH by default if the user needs exact answers or extremely high precision.
- Banding advice depends on the similarity threshold, not only on dataset size.


