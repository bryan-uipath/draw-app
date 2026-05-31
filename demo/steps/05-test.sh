#!/usr/bin/env bash
# Part 5a — test/notes: an integration test for the notes model.
# Create the branch rooted on main (`us home` then `us branch test/notes`) so it
# is RED until reparented onto feat/notes-model.
set -euo pipefail
cd "$(dirname "$0")/../.."

cat > test/notes.test.js <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";

import { createNotesStore, addNote, getNotes } from "../src/notes.js";

test("addNote assigns an incrementing id", () => {
  let store = createNotesStore();
  store = addNote(store, { text: "hello", x: 10, y: 20 });
  store = addNote(store, { text: "world", x: 30, y: 40 });
  assert.deepEqual(getNotes(store), [
    { id: 1, text: "hello", x: 10, y: 20 },
    { id: 2, text: "world", x: 30, y: 40 },
  ]);
});
EOF

echo "✓ wrote test/notes.test.js  (test/notes)"
