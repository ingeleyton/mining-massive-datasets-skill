---
name: mining-massive-datasets
description: Answer, explain, compare, and implement topics from the Mining of Massive Datasets notes in this repository. Use when Codex needs repo-grounded help on machine learning, big data, statistics, MapReduce, Spark, LSH, PageRank, streams, frequent itemsets, clustering, online ads, recommender systems, graph mining, dimensionality reduction, classical ML, or deep learning, especially for study help, algorithm selection, pseudocode, Python examples, or routing a Spanish or English question to the relevant notes/parte-XX.md files.
---

# Study Mining Massive Datasets

## Overview

Use this skill as a router over the `notes/parte-01-data-mining-fundamentals.md` to `notes/parte-57-regularization-and-generalization.md` notes in the current repository.
The notes already follow a stable template, so the main job is not to memorize everything. The main job is to route the request to the smallest useful slice of the corpus, then answer from that slice.

Prefer this skill when the user asks for:

- concept explanations or comparisons grounded in this repo
- algorithm choice under memory, communication, error, or scalability constraints
- pseudocode or Python sketches derived from the notes
- study guides, recap cards, or exam-style answers
- help finding which `notes/parte-XX.md` file covers a topic

## Quick Start

1. Classify the request into a domain before opening notes.
2. Open exactly one domain reference from `references/` when possible.
3. If the topic is ambiguous, run `scripts/find_corpus_notes.ps1` with a short query.
4. Open only the matched `notes/parte-XX.md` files and focus on the sections that matter.
5. Answer with repo-grounded assumptions, then extend only if the user asks for more depth.

## Routing

Start with [references/corpus-map.md](references/corpus-map.md) if the topic is unclear.

- Use [references/foundations-and-distributed.md](references/foundations-and-distributed.md) for data mining basics, Bonferroni, TF-IDF, hashing, MapReduce, Spark, Pregel, TensorFlow, communication cost, or MapReduce complexity.
- Use [references/similarity-and-lsh.md](references/similarity-and-lsh.md) for Jaccard, shingling, MinHash, LSH, banding, entity resolution, or high-similarity search.
- Use [references/data-streams.md](references/data-streams.md) for Bloom filters, Flajolet-Martin, AMS, DGIM, sampling, sliding windows, or decaying windows.
- Use [references/link-analysis.md](references/link-analysis.md) for PageRank, topic-sensitive PageRank, TrustRank, spam mass, HITS, dead ends, or spider traps.
- Use [references/frequent-itemsets.md](references/frequent-itemsets.md) for market baskets, support, confidence, interest, A-Priori, PCY, SON, Toivonen, or frequent items in streams.
- Use [references/clustering.md](references/clustering.md) for hierarchical clustering, k-means, BFR, CURE, GRGPF, stream clustering, or clustering tradeoffs.
- Use [references/online-ads.md](references/online-ads.md) for online matching, competitive ratio, Adwords, Balance, or budget-aware ad allocation.
- Use [references/recommenders.md](references/recommenders.md) for utility matrices, content-based methods, collaborative filtering, UV factorization, RMSE, or Netflix-style recommendation tasks.
- Use [references/graph-mining.md](references/graph-mining.md) for social graphs, communities, Girvan-Newman, spectral partitioning, SimRank, triangle counting, SCC, ANF, or graph reachability.
- Use [references/dimensionality-reduction.md](references/dimensionality-reduction.md) for eigenpairs, power iteration, PCA, SVD, truncated SVD, CUR, or sparse matrix reduction.
- Use [references/classical-ml.md](references/classical-ml.md) for perceptron, Winnow, SVM, k-NN, decision trees, forests, or classifier tradeoffs.
- Use [references/deep-learning.md](references/deep-learning.md) for MLPs, activations, losses, backprop, CNNs, RNNs, LSTMs, dropout, early stopping, or regularization.

## Search Workflow

If a request is fuzzy, overloaded, or cross-domain, run:

`.\scripts\find_corpus_notes.ps1 "pagerank spam"`

or

`.\scripts\find_corpus_notes.ps1 "lsh cosine similarity" -Top 5`

If local PowerShell blocks direct script execution, run:

`powershell -ExecutionPolicy Bypass -File ".\scripts\find_corpus_notes.ps1" "pagerank spam" -Top 5`

The script normalizes common encoding noise and ranks files by title, metadata, question prompts, action prompts, and full-text matches.

## What To Read Inside A Note

Each source note has the same high-value layout. Do not load the full file unless you need it.

- `## 2`: high-value summary
- `## 4`: principles, rules, and heuristics
- `## 5`: procedures and workflows
- `## 6`: common problems and fixes
- `## 7`: implementation and code generation
- `## 13`: questions the skill should answer
- `## 14`: actions the skill should recommend or execute

## Retrieval Hygiene

- Do not load multiple domain references unless the user is clearly bridging topics.
- Distinguish overloaded terms before answering:
  `hashing` can mean hash tables, MinHash, Bloom-style hashing, or hash-based sampling.
  `similarity` can mean Jaccard, cosine, edit distance, entity resolution, or graph similarity.
  `optimization` can mean communication cost, memory pressure, approximation error, or gradient-based learning.
- Prefer one home domain and add a second one only when the question truly depends on it.
- Treat section `## 13` as a trigger bank and `## 14` as an action bank.
- If a passage looks incomplete or inconsistent, say so instead of overfitting a confident answer.

## Answer Patterns

Use these response shapes often:

- `definition -> intuition -> formula or rule -> tradeoff -> when to use`
- `problem -> assumptions -> algorithm choice -> complexity -> failure mode`
- `small worked example -> scale-up notes -> implementation sketch`
- `symptom -> likely cause -> corrective action -> source file to inspect`

## Cross-Domain Bridges

Common bridges across the corpus:

- recommender systems + dimensionality reduction
- graph mining + distributed computation
- frequent itemsets + streams
- clustering + dimensionality reduction
- similarity search + recommender systems

When bridging, start with the primary task domain and pull only the minimum needed from the secondary domain.

