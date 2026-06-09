#!/usr/bin/env bash
# Root of the hero stack — fix/blocking-notes-bug: a fix in the stroke store the
# whole feature builds on. Touches ONLY src/strokes.js (no upper branch touches
# it), so the stack restacks onto it with zero conflicts.
set -euo pipefail
cd "$(dirname "$0")/../.."

cat > src/strokes.js <<'EOF'
// Pure stroke-store logic. No I/O — fully testable.
export const createStore = () => ({ strokes: [] });

const samePoint = (a, b) => a && b && a.x === b.x && a.y === b.y;

export const addStroke = (store, stroke) => {
  const last = store.strokes[store.strokes.length - 1];
  if (samePoint(last, stroke)) return store; // skip duplicate points
  return { ...store, strokes: [...store.strokes, stroke] };
};

export const getStrokes = (store) => store.strokes;
EOF

echo "✓ wrote src/strokes.js — skip duplicate points  (fix/blocking-notes-bug)"
