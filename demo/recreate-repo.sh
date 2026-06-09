#!/usr/bin/env bash
#
# Recreate the demo repo from scratch — wipes ALL PR history.
#
# Why: `us pr` skips branches that already have a closed/merged PR, and
# `reset.sh` closes PRs (which can't be deleted). After enough rehearsals the
# demo branch names get "burned" and `us pr` starts skipping them. Recreating
# the repo gives a clean slate so `us pr` creates every PR fresh.
#
# DESTRUCTIVE: deletes github.com/<REPO> and re-pushes your local `main`.
#
#   bash demo/recreate-repo.sh           # interactive confirm
#   FORCE=1 bash demo/recreate-repo.sh   # skip the confirmation prompt
#
set -euo pipefail
cd "$(dirname "$0")/.."

REPO="bryan-uipath/draw-app"

# 1. Sanity — correct repo, clean tree.
origin_url="$(git remote get-url origin 2>/dev/null || true)"
case "$origin_url" in
  *"$REPO"*) ;;
  *) echo "✗ origin ($origin_url) doesn't match $REPO — aborting."; exit 1 ;;
esac
if [ -n "$(git status --porcelain)" ]; then
  echo "✗ Working tree is not clean. Commit or stash first."; exit 1
fi

# 2. Drop local demo branches so ONLY main is pushed.
git checkout -q main
for b in $(git branch --format='%(refname:short)' | grep -vx main || true); do
  git branch -D "$b" >/dev/null 2>&1 || true
done
git fetch --prune origin >/dev/null 2>&1 || true

# Clear the local us database too — it holds stale branch parents and PR
# numbers that won't exist after the repo is recreated.
rm -f .git/us/us.db .git/us/us-restack-state.json .git/us/command-log

# 3. Confirm (destructive + outward-facing).
if [ "${FORCE:-}" != "1" ]; then
  echo "⚠️  This DELETES github.com/$REPO and recreates it from local main."
  echo "    All remote PRs / issues / history will be gone."
  printf "    Type the repo name to confirm (%s): " "$REPO"
  read -r reply
  [ "$reply" = "$REPO" ] || { echo "Aborted."; exit 1; }
fi

# 4. Ensure the delete_repo scope (interactive if missing).
if ! gh auth status 2>&1 | grep -q "delete_repo"; then
  echo "→ Granting delete_repo scope (follow the browser prompt)…"
  gh auth refresh -h github.com -s delete_repo
fi

# 5. Delete → recreate → push.
echo "→ Deleting $REPO…"
gh repo delete "$REPO" --yes
echo "→ Recreating $REPO (private)…"
gh repo create "$REPO" --private
echo "→ Pushing main…"
git push -u origin main
git remote set-head origin main >/dev/null 2>&1 || true

echo
echo "✓ Fresh repo — PR history wiped. Open PRs now:"
gh pr list --repo "$REPO" --state all 2>/dev/null || echo "  (none)"
echo "✓ Done. 'us pr' will create every PR cleanly. Run 'bash demo/hero.sh' to rehearse."
