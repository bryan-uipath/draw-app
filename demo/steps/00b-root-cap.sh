#!/usr/bin/env bash
# The recorded root commit — completes the blocking-bug fix by capping the stroke
# history so the in-memory store can't grow unbounded. Still only src/strokes.js,
# so `us restack` cascades it through the whole stack cleanly.
set -euo pipefail
cd "$(dirname "$0")/../.."

cat > src/strokes.js <<'EOF'
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
EOF

echo "✓ wrote src/strokes.js — cap stroke history  (root fix)"
