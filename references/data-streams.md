# Data Streams

## Use When

- The user is dealing with unbounded data, sliding windows, decaying windows, or approximate summaries.
- The task mentions Bloom filters, Flajolet-Martin, AMS moments, DGIM, or stream sampling.

## Source Files

- `../notes/parte-12-stream-model-sampling-and-windows.md`: stream model, sampling, standing vs ad-hoc queries, windows
- `../notes/parte-13-bloom-flajolet-martin-ams-and-dgim.md`: Bloom filters, Flajolet-Martin, AMS, DGIM
- `../notes/parte-14-decaying-windows-and-frequent-items.md`: decaying windows, DGIM extensions, frequent items in streams

## Common Asks

- Choose the right summary for membership, distinct counting, frequency, or window queries.
- Explain tradeoffs between exact and approximate stream algorithms.
- Recommend a structure under memory and error constraints.
- Compare sliding and decaying windows.

## Fast Routing

- Start with `parte-12` for problem framing and stream query types.
- Start with `parte-13` for approximate sketches.
- Start with `parte-14` for decaying windows and frequent items.

## Watch Outs

- `stream` may refer to a data-stream problem or stream clustering. Check the object type first.
- Bloom filters answer membership, not distinct counts or exact frequency.
- A `0`-error mindset is usually the wrong frame here. Start from the memory and error budget.



