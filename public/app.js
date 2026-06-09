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

// Clear button — wipe the canvas and reset strokes on the server.
const clearBtn = document.createElement("button");
clearBtn.textContent = "Clear";
clearBtn.style.cssText =
  "font:inherit;font-weight:500;letter-spacing:-0.35px;background:#27272a;" +
  "color:#fafafa;border:1px solid #27272a;border-radius:8px;padding:9px 16px;cursor:pointer;";
clearBtn.addEventListener("mouseenter", () => (clearBtn.style.background = "#3f3f46"));
clearBtn.addEventListener("mouseleave", () => (clearBtn.style.background = "#27272a"));
document.querySelector("header").appendChild(clearBtn);
clearBtn.addEventListener("click", async () => {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  await fetch("/api/strokes", { method: "DELETE" });
});

// Replay saved strokes on load.
for (const s of await (await fetch("/api/strokes")).json()) {
  dot(s.x, s.y);
}
