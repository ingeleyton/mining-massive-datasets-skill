# Foundations And Distributed Systems

## Use When

- The user asks about basic data mining concepts, statistical sanity checks, or why a result may be bogus.
- The task mentions TF-IDF, hashing, disk I/O, power laws, MapReduce, Spark, Pregel, TensorFlow, joins, or communication cost.
- The user wants to design a distributed workflow or compare cluster execution models.

## Source Files

- `../notes/parte-01-data-mining-fundamentals.md`: Bonferroni, TF-IDF, hashing, storage cost, power laws
- `../notes/parte-02-mapreduce-basics-and-cluster-architecture.md`: DFS, cluster architecture, MapReduce basics, combiners, skew, fault tolerance
- `../notes/parte-03-mapreduce-relational-algebra-and-matrix-ops.md`: relational algebra, matrix-vector and matrix-matrix multiplication in MapReduce
- `../notes/parte-04-spark-pregel-and-distributed-workflows.md`: Spark, RDDs, workflows, Pregel, BSP, TensorFlow
- `../notes/parte-05-communication-cost-and-multiway-joins.md`: communication-cost model, multiway joins, wall-clock tradeoffs
- `../notes/parte-06-mapreduce-complexity-and-replication-rate.md`: MapReduce complexity, replication rate, reducer size, lower bounds

## Common Asks

- Explain Bonferroni and when it invalidates a pattern search.
- Compute or interpret TF-IDF.
- Compare MapReduce and Spark.
- Design a MapReduce key strategy.
- Reason about reducer size, replication, shuffle, or communication cost.
- Decide whether a workflow should use batch, iterative, or graph-centric execution.

## Fast Routing

- Start with `parte-01` for definitions, rules, and sanity checks.
- Start with `parte-02` to `parte-04` for architecture and execution models.
- Start with `parte-05` to `parte-06` when the real bottleneck is communication cost or theoretical limits.

## Watch Outs

- Do not mix simple hash tables with MinHash or Bloom filters.
- Do not answer Spark questions with pure MapReduce tradeoffs unless the user is explicitly comparing them.
- When the user says `cost`, clarify whether they mean network communication, wall-clock time, or memory pressure.



