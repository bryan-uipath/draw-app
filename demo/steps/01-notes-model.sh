#!/usr/bin/env bash
# PR 1 — feat/notes-model: pure note store + /api/notes endpoint.
set -euo pipefail
cd "$(dirname "$0")/../.."

cat > src/notes.js <<'EOF'
// Pure sticky-note store logic. No I/O — fully testable.
export const createNotesStore = () => ({ notes: [], nextId: 1 });

export const addNote = (store, { text, x, y }) => ({
  notes: [...store.notes, { id: store.nextId, text, x, y }],
  nextId: store.nextId + 1,
});

export const getNotes = (store) => store.notes;
EOF

cat > src/server.js <<'EOF'
import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { join, extname } from "node:path";

import { createStore, addStroke, getStrokes } from "./strokes.js";
import { createNotesStore, addNote, getNotes } from "./notes.js";

let strokes = createStore();
let notes = createNotesStore();

const MIME = { ".html": "text/html", ".js": "text/javascript", ".css": "text/css" };

const sendJson = (res, data) => {
  res.setHeader("content-type", "application/json");
  res.end(JSON.stringify(data));
};

const readBody = (req) =>
  new Promise((resolve) => {
    let body = "";
    req.on("data", (chunk) => (body += chunk));
    req.on("end", () => resolve(body));
  });

const server = createServer(async (req, res) => {
  const { url, method } = req;

  // --- Strokes API ---
  if (url === "/api/strokes" && method === "GET") {
    return sendJson(res, getStrokes(strokes));
  }
  if (url === "/api/strokes" && method === "POST") {
    strokes = addStroke(strokes, JSON.parse(await readBody(req)));
    return sendJson(res, { ok: true });
  }

  // --- Notes API ---
  if (url === "/api/notes" && method === "GET") {
    return sendJson(res, getNotes(notes));
  }
  if (url === "/api/notes" && method === "POST") {
    notes = addNote(notes, JSON.parse(await readBody(req)));
    return sendJson(res, getNotes(notes));
  }

  // --- Static files from public/ ---
  const path = url === "/" ? "/index.html" : url;
  try {
    const file = await readFile(join("public", path));
    res.setHeader("content-type", MIME[extname(path)] ?? "text/plain");
    res.end(file);
  } catch {
    res.statusCode = 404;
    res.end("not found");
  }
});

const PORT = process.env.PORT ?? 4123;
server.listen(PORT, () => console.log(`draw-app → http://localhost:${PORT}`));
EOF

echo "✓ wrote src/notes.js + src/server.js  (feat/notes-model)"
