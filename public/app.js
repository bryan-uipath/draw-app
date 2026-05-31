const canvas = document.getElementById("c");
const ctx = canvas.getContext("2d");
let drawing = false;

const draw = (x, y) => ctx.fillRect(x, y, 3, 3);

canvas.addEventListener("mousedown", () => (drawing = true));
canvas.addEventListener("mouseup", () => (drawing = false));
canvas.addEventListener("mouseleave", () => (drawing = false));
canvas.addEventListener("mousemove", (e) => {
  if (!drawing) return;
  draw(e.offsetX, e.offsetY);
  fetch("/api/strokes", {
    method: "POST",
    body: JSON.stringify({ x: e.offsetX, y: e.offsetY }),
  });
});

// Replay saved strokes on load.
for (const s of await (await fetch("/api/strokes")).json()) {
  draw(s.x, s.y);
}
