#!/usr/bin/env bash
# Independent bugfix — fix/smooth-strokes: interpolate between points so fast
# mouse movement draws a continuous line instead of gappy dots.
# Genuinely independent of the notes feature → demo `us extract` to make it a
# standalone PR off trunk.
set -euo pipefail
cd "$(dirname "$0")/../.."

cat > public/app.js <<'EOF'
const canvas = document.getElementById("c");
const ctx = canvas.getContext("2d");
ctx.strokeStyle = "#22d3ee";
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
  lineTo(e.offsetX, e.offsetY); // connect points — no more gaps
  fetch("/api/strokes", {
    method: "POST",
    body: JSON.stringify({ x: e.offsetX, y: e.offsetY }),
  });
});

// Replay saved strokes on load.
for (const s of await (await fetch("/api/strokes")).json()) {
  dot(s.x, s.y);
}
EOF

echo "✓ wrote public/app.js with interpolated strokes  (fix/smooth-strokes)"
