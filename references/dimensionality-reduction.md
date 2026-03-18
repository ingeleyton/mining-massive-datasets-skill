# Dimensionality Reduction

## Use When

- The user asks about eigenvalues, eigenvectors, power iteration, PCA, SVD, truncated SVD, CUR, or sparse matrix reduction.
- The task is about lower-dimensional representation rather than direct recommendation or classification.

## Source Files

- `../notes/parte-42-eigenvalues-power-iteration-and-pca-intro.md`: eigenpairs, symmetric matrices, power iteration, deflation
- `../notes/parte-43-pca-and-svd-introduction.md`: PCA, principal components, geometric interpretation, SVD intro
- `../notes/parte-44-svd-and-cur-introduction.md`: SVD, concept spaces, Frobenius norm, CUR intro
- `../notes/parte-45-cur-decomposition-and-sparse-matrices.md`: CUR, sparse matrices, pseudoinverse, SVD vs CUR tradeoffs

## Common Asks

- Explain power iteration and deflation.
- Compare PCA and SVD.
- Decide when CUR is preferable to SVD.
- Build a dimensionality-reduction workflow for sparse matrices.
- Interpret latent-space projections.

## Fast Routing

- Use `parte-42` for eigenpair mechanics.
- Use `parte-43` for PCA intuition.
- Use `parte-44` for SVD workflows.
- Use `parte-45` for CUR and sparse-matrix tradeoffs.

## Watch Outs

- Use UV for recommender-specific latent factors and PCA/SVD for general reduction unless the user explicitly bridges them.
- CUR is especially useful when preserving sparsity or interpretability matters.
- Some user questions that mention `factorization` actually belong in recommenders.



