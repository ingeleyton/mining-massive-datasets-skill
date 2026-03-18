# Graph Mining

## Use When

- The task is about communities, spectral partitioning, overlapping communities, SimRank, triangle counting, directed neighborhoods, SCC, ANF, or graph reachability.
- The user is analyzing graph structure rather than graph ranking.

## Source Files

- `../notes/parte-35.md`: social networks as graphs, locality, graph clustering framing
- `../notes/parte-36.md`: betweenness, Girvan-Newman, community detection
- `../notes/parte-37.md`: direct discovery of communities, bicliques, itemset-style graph mining
- `../notes/parte-38.md`: graph partitioning, Laplacian, normalized cuts, overlap setup
- `../notes/parte-39.md`: overlapping communities, MLE, SimRank, conductance
- `../notes/parte-40.md`: triangle counting, heavy hitters, MapReduce multiway joins
- `../notes/parte-41.md`: directed neighborhoods, transitive closure, SCC, ANF

## Common Asks

- Compare Girvan-Newman, spectral partitioning, and overlap-friendly methods.
- Explain conductance, betweenness, Laplacian intuition, or SimRank.
- Count triangles efficiently or in MapReduce.
- Analyze reachability, SCC, or neighborhood growth.

## Fast Routing

- Use `parte-35` to `parte-36` for graph-community intuition.
- Use `parte-38` to `parte-39` for spectral and overlap questions.
- Use `parte-40` for triangle counting and graph joins.
- Use `parte-41` for directed-graph reachability and SCC.

## Watch Outs

- Separate graph ranking from graph community detection.
- Some overlap content in `parte-38` to `parte-39` is more advanced and less complete than the earlier notes. Say when the source is partial.
- If the real issue is execution cost, pair this with distributed references only after choosing the graph task.


