# Corpus Map

## Overview

The repository contains `notes/parte-01-data-mining-fundamentals.md` to `notes/parte-57-regularization-and-generalization.md`.
Every file follows the same 15-section template, which makes the corpus easy to route if you avoid loading too much at once.

## Chapter Map

- `parte-01`: data mining foundations, Bonferroni, TF-IDF, hashing, disk I/O, power laws
- `parte-02` to `parte-06`: DFS, MapReduce, Spark, Pregel, communication cost, MapReduce complexity
- `parte-07` to `parte-11`: similarity, shingling, MinHash, banding, LSH, entity resolution
- `parte-12` to `parte-14`: data streams, sampling, Bloom, FM, AMS, DGIM, decaying windows
- `parte-15` to `parte-18`: PageRank, topic-sensitive PageRank, spam, TrustRank, HITS
- `parte-19` to `parte-23`: market baskets, A-Priori, PCY, SON, Toivonen, frequent items in streams
- `parte-24` to `parte-27`: hierarchical clustering, k-means, BFR, CURE, GRGPF, stream clustering
- `parte-28` to `parte-29`: online ads, bipartite matching, Adwords, Balance
- `parte-30` to `parte-34`: recommender systems, utility matrix, collaborative filtering, UV, Netflix
- `parte-35` to `parte-41`: social graphs, communities, spectral methods, SimRank, triangle counting, SCC, ANF
- `parte-42` to `parte-45`: eigenpairs, PCA, SVD, CUR
- `parte-46` to `parte-51`: supervised learning, perceptron, Winnow, SVM, k-NN, trees, forests
- `parte-52` to `parte-57`: neural nets, activations, losses, backprop, CNNs, RNNs, LSTMs, regularization

## Standard Sections

Each note exposes the same high-value sections:

- `## 2`: summary
- `## 4`: principles and heuristics
- `## 5`: workflows
- `## 6`: common problems
- `## 7`: implementation and code
- `## 13`: likely user questions
- `## 14`: likely recommended actions

## Common Ambiguities

- `hashing`: table hashing, MinHash, Bloom-style hashing, or hash-based sampling
- `similarity`: Jaccard, cosine, edit distance, entity resolution, or graph similarity
- `optimization`: communication, memory, approximation error, or gradient descent
- `streams`: data-stream algorithms or stream clustering
- `factorization`: UV for recommenders, SVD/PCA for reduction, or CUR for sparse matrices

## Retrieval Rule

Open one domain reference first, then open the smallest set of matching source notes.
If the domain is not obvious, run `scripts/find_corpus_notes.ps1`.

