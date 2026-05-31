const board = document.getElementById("board");

const renderNote = ({ text, x, y }) => {
  const el = document.createElement("div");
  el.className = "note";
  el.textContent = text;
  el.style.left = `${x}px`;
  el.style.top = `${y}px`;
  board.appendChild(el);
};

document.getElementById("add-note").addEventListener("click", () => {
  const text = prompt("Note text:");
  if (!text) return;
  renderNote({
    text,
    x: 40 + Math.round(Math.random() * 600),
    y: 40 + Math.round(Math.random() * 360),
  });
});
