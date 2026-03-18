# Deep Learning

## Use When

- The task is about MLPs, activations, losses, backprop, CNNs, RNNs, LSTMs, BPTT, dropout, early stopping, or regularization.
- The user wants conceptual or implementation guidance from the notes rather than framework-specific production advice.

## Source Files

- `../notes/parte-52-neural-networks-and-deep-learning-intro.md`: neural-net framing, perceptrons, deep learning motivation, CNN setup
- `../notes/parte-53-dense-neural-networks-and-loss-functions.md`: dense feedforward nets, activations, losses, gradient descent
- `../notes/parte-54-backpropagation-and-cnn-intro.md`: backpropagation, computation graphs, Jacobians, CNN transition
- `../notes/parte-55-cnns-and-rnns.md`: CNNs, convolution, pooling, matrix implementation, RNN intro
- `../notes/parte-56-rnns-lstms-and-bptt.md`: RNNs, LSTMs, BPTT, vanishing and exploding gradients, GRU
- `../notes/parte-57-regularization-and-generalization.md`: regularization, L1/L2, dropout, early stopping, augmentation, validation discipline

## Common Asks

- Compare sigmoid, tanh, ReLU, softmax, or loss functions.
- Explain backprop or derive a training update.
- Compute CNN output shapes or parameter counts.
- Compare RNN and LSTM behavior on sequences.
- Diagnose overfitting, dying ReLU, vanishing gradients, or unstable training.
- Recommend regularization and validation practices.

## Fast Routing

- Use `parte-53` for activations, losses, and dense-network basics.
- Use `parte-54` for backprop.
- Use `parte-55` for CNN details.
- Use `parte-56` for sequential models.
- Use `parte-57` for regularization and evaluation strategy.

## Watch Outs

- CNN content is foreshadowed before it is fully developed. Prefer `parte-55` for direct CNN questions.
- RNN content is mentioned earlier but explained most directly in `parte-56`.
- Keep framework-neutral answers unless the user explicitly asks for TensorFlow or another library.



