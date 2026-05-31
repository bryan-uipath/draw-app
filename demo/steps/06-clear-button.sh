#!/usr/bin/env bash
# Independent feature — feat/clear-button: a "Clear" button that wipes the canvas
# and resets strokes on the server. Has nothing to do with the notes feature →
# demo `us extract` to make it a standalone PR off trunk.
set -euo pipefail
cd "$(dirname "$0")/../.."

cat > src/server.js <<'EOF'
import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { join, extname } from "node:path";

import { createStore, addStroke, getStrokes } from "./strokes.js";

let strokes = createStore();

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
  if (url === "/api/strokes" && method === "DELETE") {
    strokes = createStore();
    return sendJson(res, { ok: true });
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

cat > public/app.js <<'EOF'
const canvas = document.getElementById("c");
const ctx = canvas.getContext("2d");
ctx.strokeStyle = "#22d3ee"; // cyan pen — visible on the dark board
ctx.fillStyle = "#22d3ee";
ctx.lineWidth = 3;
ctx.lineCap = "round";
ctx.lineJoin = "round";

let drawing = false;
let last = null;

const dot = (x, y) => ctx.fillRect(x, y, 3, 3);

const lineTo = (x, y) => {
  ctx.beginPath();
  ctx.moveTo(last.x, last.y);
  ctx.lineTo(x, y);
  ctx.stroke();
  last = { x, y };
};

canvas.addEventListener("mousedown", (e) => {
  drawing = true;
  last = { x: e.offsetX, y: e.offsetY };
  dot(e.offsetX, e.offsetY);
});
canvas.addEventListener("mouseup", () => (drawing = false));
canvas.addEventListener("mouseleave", () => (drawing = false));
canvas.addEventListener("mousemove", (e) => {
  if (!drawing) return;
  lineTo(e.offsetX, e.offsetY);
  fetch("/api/strokes", {
    method: "POST",
    body: JSON.stringify({ x: e.offsetX, y: e.offsetY }),
  });
});

// Clear the canvas and reset strokes on the server.
document.getElementById("clear").addEventListener("click", async () => {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  await fetch("/api/strokes", { method: "DELETE" });
});

// Replay saved strokes on load.
for (const s of await (await fetch("/api/strokes")).json()) {
  dot(s.x, s.y);
}
EOF

cat > public/index.html <<'EOF'
<!doctype html>
<html lang="en" class="future-dark">
  <head>
    <meta charset="utf-8" />
    <title>draw·app</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link
      href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
      rel="stylesheet"
    />
    <style>
      /* Apollo "Future" foundation — zinc surfaces + cyan brand, Inter type. */
      :root {
        --surface: #09090b;
        --surface-raised: #18181b;
        --surface-overlay: #27272a;
        --border: #27272a;
        --foreground: #fafafa;
        --foreground-muted: #a1a1aa;
        --brand: #0891b2;
        --brand-hover: #22d3ee;
      }
      * { box-sizing: border-box; }
      body {
        font-family: "Inter", system-ui, -apple-system, sans-serif;
        letter-spacing: -0.4px;
        background: var(--surface);
        color: var(--foreground);
        margin: 0;
        min-height: 100vh;
        padding: 40px;
      }
      header {
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        width: 800px;
        max-width: 100%;
        margin: 0 auto 20px;
      }
      h1 {
        font-size: 28px;
        font-weight: 600;
        letter-spacing: -0.8px;
        margin: 0;
      }
      h1 .accent { color: var(--brand-hover); }
      .subtitle {
        color: var(--foreground-muted);
        font-size: 14px;
        letter-spacing: -0.35px;
        margin-top: 4px;
      }
      button {
        font: inherit;
        font-weight: 500;
        letter-spacing: -0.35px;
        background: var(--surface-overlay);
        color: var(--foreground);
        border: 1px solid var(--border);
        border-radius: 8px;
        padding: 9px 16px;
        cursor: pointer;
        transition: background 0.15s ease;
      }
      button:hover { background: var(--border); }
      #board {
        position: relative;
        width: 800px;
        max-width: 100%;
        margin: 0 auto;
        background-color: var(--surface-raised);
        /* subtle grid behind the canvas */
        background-image:
          linear-gradient(to right, rgba(255, 255, 255, 0.035) 1px, transparent 1px),
          linear-gradient(to bottom, rgba(255, 255, 255, 0.035) 1px, transparent 1px);
        background-size: 24px 24px;
        border: 1px solid var(--border);
        border-radius: 24px;
        box-shadow: 0px 4px 24px 0px rgba(0, 0, 0, 0.25);
        overflow: hidden;
      }
      #c {
        display: block;
        cursor: crosshair;
        box-shadow: inset 0 0 80px rgba(0, 0, 0, 0.35);
      }
    </style>
  </head>
  <body>
    <header>
      <div>
        <h1>draw<span class="accent">·</span>app</h1>
        <div class="subtitle">a tiny canvas — demo sandbox for stacked PRs</div>
      </div>
      <button id="clear">Clear</button>
    </header>
    <div id="board">
      <canvas id="c" width="800" height="500"></canvas>
    </div>
    <script type="module" src="/app.js"></script>
  </body>
</html>
EOF

echo "✓ wrote src/server.js (DELETE) + public/app.js (clear) + public/index.html (button)  (feat/clear-button)"
