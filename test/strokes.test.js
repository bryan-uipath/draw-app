import test from "node:test";
import assert from "node:assert/strict";

import { createStore, addStroke, getStrokes } from "../src/strokes.js";

test("a new store has no strokes", () => {
  assert.deepEqual(getStrokes(createStore()), []);
});

test("addStroke appends a stroke", () => {
  const store = addStroke(createStore(), { x: 1, y: 2 });
  assert.deepEqual(getStrokes(store), [{ x: 1, y: 2 }]);
});
