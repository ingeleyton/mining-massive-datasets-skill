# Recommenders

## Use When

- The user asks about utility matrices, sparsity, explicit or implicit feedback, content-based systems, collaborative filtering, UV factorization, RMSE, or Netflix-style evaluation.
- The task is recommendation-specific rather than general clustering or dimensionality reduction.

## Source Files

- `../notes/parte-30-recommender-systems-introduction.md`: recommender-system framing, utility matrix, long tail, explicit vs implicit data
- `../notes/parte-31-content-based-recommendation.md`: content-based recommendation, TF-IDF profiles, cosine similarity
- `../notes/parte-32-collaborative-filtering-and-utility-matrices.md`: collaborative filtering, normalization, user-item similarities, clustering
- `../notes/parte-33-uv-factorization-and-netflix-challenge.md`: UV factorization, latent factors, gradient-based optimization, overfitting
- `../notes/parte-34-recommender-systems-wrap-up.md`: Netflix challenge, RMSE, factorization recap

## Common Asks

- Compare content-based and collaborative filtering.
- Interpret sparse utility matrices.
- Normalize ratings before similarity calculations.
- Choose between neighborhood methods and latent-factor methods.
- Explain RMSE and Netflix-style evaluation.

## Fast Routing

- Use `parte-30` to frame the data model.
- Use `parte-31` for content-based methods.
- Use `parte-32` for collaborative filtering and normalization.
- Use `parte-33` to `parte-34` for latent-factor methods and Netflix-style evaluation.

## Watch Outs

- Do not treat missing values as negative feedback unless the note explicitly supports that interpretation.
- UV factorization for recommenders is not the same as general PCA or SVD usage.
- Recommendation questions often bridge to similarity search or dimensionality reduction. Add those only if needed.



