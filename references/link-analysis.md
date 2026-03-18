# Link Analysis

## Use When

- The task is about PageRank, topic-sensitive PageRank, TrustRank, spam mass, HITS, dead ends, or spider traps.
- The user wants graph ranking rather than community detection.

## Source Files

- `../notes/parte-15.md`: PageRank basics, transition matrices, Markov chains, dead ends, spider traps
- `../notes/parte-16.md`: scalable PageRank, sparse matrices, block-stripe partitioning, MapReduce
- `../notes/parte-17.md`: topic-sensitive PageRank, link spam, spam farms, TrustRank, spam mass
- `../notes/parte-18.md`: HITS, hubs and authorities, summary links to the rest of chapter 5

## Common Asks

- Explain teleportation and why it fixes dead ends or spider traps.
- Compare PageRank and HITS.
- Design scalable PageRank computation.
- Detect or mitigate link spam.
- Decide when topic-sensitive ranking is worth the extra cost.

## Fast Routing

- Use `parte-15` first for intuition and equations.
- Use `parte-16` when the user cares about scalability or sparse implementation.
- Use `parte-17` for spam and trust-oriented ranking.
- Use `parte-18` for HITS-specific questions.

## Watch Outs

- Do not confuse ranking tasks with community-detection tasks from graph mining.
- `beta = 0.85` is a common default in the notes, not a universal law.
- Some answers need both graph intuition and distributed execution details. Pull from foundations only if needed.


