#!/usr/bin/env bash
#
# Pre-build the hero stack. Run this BEFORE recording, then run
# `demo/hero.sh` while recording.
#
#   fix/blocking-notes-bug   (root / earliest PR, on main)
#   └── feat/notes-model
#       └── feat/notes-ui    ← you end up here (the top)
#
# `us prev 2` from the top lands on the earliest PR (fix/blocking-notes-bug).
# Creates real PRs on GitHub (so `us tree` shows live statuses). DRY=1 skips
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

if [ "${DRY:-}" != "1" ]; then
  echo "→ Publishing the stack…"
  $US pr
fi

$US tree
echo
echo "✓ Stack ready (you're on feat/notes-ui, the top)."
echo "  Start recording, then run:  bash demo/hero.sh"
