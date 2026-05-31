// Pure stroke-store logic. No I/O — fully testable with plain data.

export const createStore = () => ({ strokes: [] });

export const addStroke = (store, stroke) => ({
  ...store,
  strokes: [...store.strokes, stroke],
});

export const getStrokes = (store) => store.strokes;
