#!/usr/bin/env bash
#
# Reset the draw-app repo to a clean pre-demo state.
# Deletes the sticky-notes demo branches (local + remote), closes their PRs,
# resets main to origin/main, and clears local `us` state.
#
# Safe to run repeatedly. Run this before each rehearsal and right before the talk.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

BRANCHES=(feat/notes-model feat/notes-ui feat/notes-persist test/notes)

echo "→ Returning to main…"
git checkout main 2>/dev/null
git reset --hard origin/main 2>/dev/null

echo "→ Closing PRs and deleting demo branches…"
for b in "${BRANCHES[@]}"; do
  gh pr close "$b" --delete-branch 2>/dev/null && echo "  closed PR + deleted remote: $b" || true
  git push origin --delete "$b" 2>/dev/null && echo "  deleted remote: $b" || true
  git branch -D "$b" 2>/dev/null && echo "  deleted local: $b" || true
done

echo "→ Clearing local us state…"
rm -f .git/us/us.db .git/us/us-restack-state.json .git/us/command-log

# Re-point origin/HEAD so `us` can resolve the trunk.
git remote set-head origin main >/dev/null 2>&1

echo "✓ Clean. On main, no demo branches. Run the runbook from the top."
