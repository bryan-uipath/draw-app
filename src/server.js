import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { join, extname } from "node:path";

import { createStore, addStroke, getStrokes } from "./strokes.js";
import { createNotesStore, addNote, getNotes } from "./notes.js";

let strokes = createStore();
let notes = createNotesStore();

const MIME = { ".html": "text/html", ".js": "text/javascript", ".css": "text/css" };

// This function sends JSON
const sendJson = (res, data) => {
  res.setHeader("content-type", "application/json");
  res.end(JSON.stringify(data));
};

// This function reads the body
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
