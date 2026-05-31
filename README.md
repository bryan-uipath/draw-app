# draw-app

A tiny canvas drawing app. Draw with the mouse; strokes are saved to a small
in-memory server and replayed on reload.

This repo is a **demo sandbox for [stacked PRs](https://github.com/UiPath/stacked-prs)** —
the [`us` CLI](https://github.com/UiPath/stacked-prs) presentation builds a
"sticky notes" feature on top of it as a stack of small, dependent PRs.

## Run

```bash
npm start          # http://localhost:3000
npm test           # node --test
```

No dependencies — just Node 18+ (`node:http`, `node:test`, vanilla `<canvas>`).

## Layout

```
src/strokes.js   pure stroke-store logic (testable)
src/server.js    node:http server: /api/strokes + static files
public/          the canvas UI
test/            node:test unit tests
demo/reset.sh    reset the repo to a clean pre-demo state
```
