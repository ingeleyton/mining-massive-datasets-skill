# Classical ML

## Use When

- The task is about supervised learning setup, train-validation-test discipline, perceptron, Winnow, SVM, k-NN, decision trees, forests, or comparing classical classifiers.
- The user wants model-selection help grounded in the notes rather than generic modern tooling advice.

## Source Files

- `../notes/parte-46.md`: supervised learning framing, training sets, batch vs online learning
- `../notes/parte-47.md`: perceptron, Winnow, separability, parallel training
- `../notes/parte-48.md`: SVM, margin, hinge loss, gradient descent, SGD
- `../notes/parte-49.md`: k-NN, Voronoi diagrams, kernel regression, dimensionality issues
- `../notes/parte-50.md`: decision trees, impurity, pruning, forests
- `../notes/parte-51.md`: method comparison, overfitting, classifier tradeoffs

## Common Asks

- Compare perceptron, Winnow, SVM, k-NN, and trees.
- Choose a classifier under interpretability, sparsity, or dimensionality constraints.
- Compute GINI, entropy, margin, hinge loss, or a split criterion.
- Diagnose overfitting, non-convergence, or curse-of-dimensionality issues.
- Recommend a validation strategy.

## Fast Routing

- Use `parte-46` to frame the learning problem.
- Use `parte-47` to `parte-48` for linear classifiers and margin-based methods.
- Use `parte-49` for instance-based methods and high-dimensional warnings.
- Use `parte-50` for tree mechanics.
- Use `parte-51` as a comparison layer, not as the main algorithm source.

## Watch Outs

- `gradient descent` appears here and again in deep learning. Keep the model-specific context clear.
- `parte-51` is best for method selection, not detailed derivations.
- If the question is really about latent-factor models or neural nets, route out early.


