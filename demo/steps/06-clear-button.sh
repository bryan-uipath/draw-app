#!/usr/bin/env bash
# Independent feature — feat/clear-button: a "Clear" button that wipes the canvas
# and resets strokes on the server. Has nothing to do with the notes feature.
#
# Edits are ADDITIVE (inserted at stable anchors present in both the base and the
# notes versions of each file), so the commit rebases cleanly onto main — which
# is what makes the `us reparent --on main` / `us extract` beat conflict-free.
set -euo pipefail
cd "$(dirname "$0")/../.."

node --input-type=module <<'NODE'
import { readFileSync, writeFileSync } from "node:fs";

// 1) server.js — add DELETE /api/strokes just before the static-files section.
let server = readFileSync("src/server.js", "utf8");
if (!server.includes('method === "DELETE"')) {
  const block =
    '  if (url === "/api/strokes" && method === "DELETE") {\n' +
    "    strokes = createStore();\n" +
    "    return sendJson(res, { ok: true });\n" +
    "  }\n\n";
  server = server.replace("  // --- Static files", block + "  // --- Static files");
  writeFileSync("src/server.js", server);
}

// 2) index.html — add a Clear button to the header + a generic button style.
let html = readFileSync("public/index.html", "utf8");
if (!html.includes('id="clear"')) {
  html = html.replace("    </header>", '      <button id="clear">Clear</button>\n    </header>');
  if (!html.includes("\n      button {")) {
    const css =
      "      button {\n" +
      "        font: inherit;\n" +
      "        font-weight: 500;\n" +
      "        letter-spacing: -0.35px;\n" +
      "        background: var(--surface-overlay, #27272a);\n" +
      "        color: var(--foreground);\n" +
      "        border: 1px solid var(--border);\n" +
      "        border-radius: 8px;\n" +
      "        padding: 9px 16px;\n" +
      "        cursor: pointer;\n" +
      "        transition: background 0.15s ease;\n" +
      "      }\n" +
      "      button:hover { background: var(--border); }\n";
    html = html.replace("      #board {", css + "      #board {");
  }
  writeFileSync("public/index.html", html);
}

// 3) app.js — add the clear handler just before the replay loop.
let app = readFileSync("public/app.js", "utf8");
if (!app.includes('getElementById("clear")')) {
  const handler =
    "// Clear the canvas and reset strokes on the server.\n" +
    'document.getElementById("clear").addEventListener("click", async () => {\n' +
    "  ctx.clearRect(0, 0, canvas.width, canvas.height);\n" +
    '  await fetch("/api/strokes", { method: "DELETE" });\n' +
    "});\n\n";
  app = app.replace("// Replay saved strokes on load.", handler + "// Replay saved strokes on load.");
  writeFileSync("public/app.js", app);
}
NODE

echo "✓ added Clear button + DELETE /api/strokes  (feat/clear-button)"
