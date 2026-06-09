#!/usr/bin/env bash
#
# Self-playing HERO demo — the recorded tail (~20s) for a README GIF (Gifox).
# Pre-build the stack first with `demo/hero-setup.sh`, then record this.
#
# The story: a 4-PR stack, fix the EARLIEST PR, and one command re-stacks the
# whole chain — then update every PR at once.
#
#   1) bash demo/hero-setup.sh   # build the 4-PR stack
#   2) start Gifox over the terminal
#   3) bash demo/hero.sh
#   4) stop recording, then `bash demo/reset.sh` to clean up
#
# Knobs:  SPEED=2 (faster typing)   DRY=1 (`us pr --dry-run`, no network)
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

clear
nap 0.6

note "A 4-PR stack — built bottom-up on a root bugfix"
play "us tree" 1.8

note "The earliest PR needs another fix. Jump to the root:"
play "us prev 3" 0.7
code bash demo/steps/00b-root-cap.sh
play "git commit -aqm 'fix: cap stroke history to bound memory'" 0.7

note "One command re-stacks the entire chain on top of the fix ⚡"
play "us restack" 2.0
play "us tree" 1.8

note "…and update every PR in the stack at once"
if [ "${DRY:-}" = "1" ]; then
  play "us pr --dry-run" 2.5
else
  play "us pr" 2.5
fi

printf "\n%s❯%s %sone root fix → the whole stack, re-based and re-published.%s\n\n" "$CY" "$RST" "$DIM" "$RST"
nap 1.2
