// Pure stroke-store logic. No I/O — fully testable.
export const createStore = () => ({ strokes: [] });

const samePoint = (a, b) => a && b && a.x === b.x && a.y === b.y;
const MAX_STROKES = 5000;

export const addStroke = (store, stroke) => {
  const last = store.strokes[store.strokes.length - 1];
  if (samePoint(last, stroke)) return store; // skip duplicate points
  const strokes = [...store.strokes, stroke].slice(-MAX_STROKES); // cap history
  return { ...store, strokes };
};

export const getStrokes = (store) => store.strokes;
