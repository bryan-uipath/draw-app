#!/usr/bin/env bash
# Part 4 — review feedback on feat/notes-model: ignore empty notes.
# Run from feat/notes-model, then commit and `us sync`.
set -euo pipefail
cd "$(dirname "$0")/../.."

cat > src/notes.js <<'EOF'
// Pure sticky-note store logic. No I/O — fully testable.
export const createNotesStore = () => ({ notes: [], nextId: 1 });

export const addNote = (store, { text, x, y }) => {
  if (!text || !text.trim()) return store; // ignore empty notes (review feedback)
  return {
    notes: [...store.notes, { id: store.nextId, text, x, y }],
    nextId: store.nextId + 1,
  };
};

export const getNotes = (store) => store.notes;
EOF

echo "✓ wrote src/notes.js with empty-note guard  (review feedback)"
