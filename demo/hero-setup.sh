#!/usr/bin/env bash
#
# Pre-build the 4-PR hero stack. Run this BEFORE recording, then run
# `demo/hero.sh` while recording.
#
#   fix/blocking-notes-bug   (root, on main)
#   └── feat/notes-model
#       └── feat/notes-ui
#           └── feat/clear-button   ← you end up here
#
# Creates 4 real PRs on GitHub (so `us tree` shows live statuses). DRY=1 skips
# publishing (local only). Run `bash demo/reset.sh` afterward to clean up.
#
set -euo pipefail
cd "$(dirname "$0")/.."
US=${US:-us}

echo "→ Clean slate…"
bash demo/reset.sh >/dev/null 2>&1 || true

echo "→ Building the stack…"
$US home >/dev/null
$US branch fix/blocking-notes-bug >/dev/null
bash demo/steps/00-blocking-bug.sh >/dev/null
git commit -aqm "fix: skip duplicate stroke points"

$US branch feat/notes-model >/dev/null
bash demo/steps/01-notes-model.sh >/dev/null
git commit -aqm "feat: sticky-note model + /api/notes endpoint"

$US branch feat/notes-ui >/dev/null
bash demo/steps/02-notes-ui.sh >/dev/null
git add -A && git commit -qm "feat: add-note button + rendering"

$US branch feat/clear-button >/dev/null
bash demo/steps/06-clear-button.sh >/dev/null
git add -A && git commit -qm "feat: add a Clear button"

if [ "${DRY:-}" != "1" ]; then
  echo "→ Publishing 4 PRs…"
  $US pr --all
fi

$US tree
echo
echo "✓ 4-PR stack ready (you're on feat/clear-button)."
echo "  Start recording, then run:  bash demo/hero.sh"
