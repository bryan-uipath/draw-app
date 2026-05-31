#!/usr/bin/env bash
# PR 3 — feat/notes-persist: save notes to the server + load them on startup.
set -euo pipefail
cd "$(dirname "$0")/../.."

cat > public/notes-ui.js <<'EOF'
const board = document.getElementById("board");

const renderNote = ({ text, x, y }) => {
  const el = document.createElement("div");
  el.className = "note";
  el.textContent = text;
  el.style.left = `${x}px`;
  el.style.top = `${y}px`;
  board.appendChild(el);
};

document.getElementById("add-note").addEventListener("click", async () => {
  const text = prompt("Note text:");
  if (!text) return;
  const note = {
    text,
    x: 40 + Math.round(Math.random() * 600),
    y: 40 + Math.round(Math.random() * 360),
  };
  renderNote(note);
  await fetch("/api/notes", { method: "POST", body: JSON.stringify(note) });
});

// Load saved notes on startup.
for (const note of await (await fetch("/api/notes")).json()) {
  renderNote(note);
}
EOF

echo "✓ wrote public/notes-ui.js  (feat/notes-persist)"
