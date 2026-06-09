#!/usr/bin/env bash
#
# Self-playing HERO demo for a README GIF (Gifox) — STANDALONE.
# Builds the stack itself, waits for you to start recording, then plays:
#   us tree → us prev 2 (the earliest PR) → fix the root → us restack (cascade) → us pr
#
#   1) bash demo/hero.sh        # builds the 3-PR stack, then prompts you
#   2) start your Gifox recording over the terminal, press Enter
#   3) afterwards: bash demo/reset.sh
#
# Knobs:  SPEED=2 (faster typing)   DRY=1 (no GitHub — `us pr --dry-run`)
#
set -euo pipefail
cd "$(dirname "$0")/.."

US=${US:-us}
SPEED=${SPEED:-1}
CY=$'\033[36m'; DIM=$'\033[2m'; RST=$'\033[0m'

nap() { awk "BEGIN{system(\"sleep \" $1/$SPEED)}"; }
play() {
  local cmd="$1" pause="${2:-0.8}" i
  printf "%s❯%s " "$CY" "$RST"
  for ((i = 0; i < ${#cmd}; i++)); do printf "%s" "${cmd:i:1}"; nap 0.02; done
  printf "\n"; nap 0.3
  eval "${cmd/#us /$US }"
  nap "$pause"
}
note() { printf "\n%s# %s%s\n" "$DIM" "$1" "$RST"; nap 0.6; }
code() { "$@" >/dev/null 2>&1; }

# --- Build the stack off-camera: fix/blocking-notes-bug → notes-model → notes-ui
printf "Building the demo stack…\n"
bash demo/reset.sh >/dev/null 2>&1 || true
$US home >/dev/null
$US branch fix/blocking-notes-bug >/dev/null
code bash demo/steps/00-blocking-bug.sh; git commit -aqm "fix: skip duplicate stroke points"
$US branch feat/notes-model >/dev/null
code bash demo/steps/01-notes-model.sh; git commit -aqm "feat: sticky-note model + /api/notes endpoint"
$US branch feat/notes-ui >/dev/null
code bash demo/steps/02-notes-ui.sh; git add -A; git commit -qm "feat: add-note button + rendering"

# --- Wait for the recording to start
clear
printf "%s✦ Stack ready — you're on feat/notes-ui (top of a 3-PR stack).%s\n\n" "$CY" "$RST"
printf "  ▶︎  Start your Gifox recording over this terminal,\n     then press %sEnter%s to play the demo…" "$CY" "$RST"
read -r || true
clear
nap 0.6

# --- The recorded demo
note "A 3-PR stack — built bottom-up on a root bugfix"
play "us tree" 1.8

note "The earliest PR needs another fix. Jump to the root:"
play "us prev 2" 0.7
code bash demo/steps/00b-root-cap.sh
play "git commit -aqm 'fix: cap stroke history to bound memory'" 0.7

note "One command re-stacks the entire chain on top of the fix ⚡"
play "us restack" 2.0
play "us tree" 1.8

note "…then publish the whole stack — correct bases + stack comments"
if [ "${DRY:-}" = "1" ]; then
  play "us pr --dry-run" 2.5
else
  play "us pr" 2.5
fi

printf "\n%s❯%s %sone root fix → the whole stack, re-based and published.%s\n\n" "$CY" "$RST" "$DIM" "$RST"
nap 1.2
