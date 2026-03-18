# Frequent Itemsets

## Use When

- The task is about market baskets, support, confidence, interest, A-Priori, PCY, SON, Toivonen, or frequent items in a stream.
- The user asks how to reduce passes, save memory, or choose a counting structure.

## Source Files

- `../notes/parte-19-market-basket-model-and-association-rules.md`: market-basket model, support, confidence, interest
- `../notes/parte-20-apriori-and-pair-counting.md`: A-Priori, monotonicity, pair counting, triangular matrix vs triples
- `../notes/parte-21-pcy-multistage-and-multihash.md`: PCY, Multistage, Multihash, sampling
- `../notes/parte-22-son-toivonen-and-limited-pass-mining.md`: limited-pass algorithms, SON, Toivonen, MapReduce framing
- `../notes/parte-23-frequent-items-in-streams.md`: frequent items in streams, decaying windows, hybrid methods

## Common Asks

- Explain support, confidence, and interest.
- Compare A-Priori, PCY, SON, and Toivonen.
- Choose a counting structure under memory pressure.
- Diagnose thrashing or pair-count explosions.
- Extend basket mining ideas to streams.

## Fast Routing

- Use `parte-19` to define the problem and metrics.
- Use `parte-20` for A-Priori and the pair-count bottleneck.
- Use `parte-21` to `parte-22` for memory savings and limited-pass variants.
- Use `parte-23` for stream-specific frequent-item questions.

## Watch Outs

- Keep `support`, `confidence`, and `interest` separate. Users often blend them.
- The triangular matrix rule of thumb assumes dense enough pair counts.
- Streaming variants are not just smaller A-Priori. They change the data model.



