#!/usr/bin/env bash
#  Captures one PNG per page into docs/screenshots/, plus the Overview in
#  the light theme. Run through Alire, which provides ADI2_TOOLS:
#
#    alr exec -- tools/screenshots.sh
#
#  Needs a binary built with adi2 in its development profile, which is the
#  one that answers adi2's inspection bridge (`alr build
#  --profiles=adi2=development`). The window is drawn offscreen with SDL's
#  software renderer, and preferences go to a scratch directory, so the
#  captures use default settings and leave the user's alone. The System
#  page prints folder paths; the binary runs from a fixed staging directory
#  under a stand-in home, so the images show no path of the machine that
#  took them.
set -euo pipefail

cd "$(dirname "$0")/.."
: "${ADI2_TOOLS:?ADI2_TOOLS is unset: run through alr, e.g. alr exec -- tools/screenshots.sh}"

readonly OUT=docs/screenshots
readonly PAGES=(overview buttons inputs lists layout styling media document canvas system)
readonly SCRATCH=$(mktemp -d)
readonly STAGE=${TMPDIR:-/tmp}/adi2_demo
trap 'rm -rf "$SCRATCH" "$STAGE"' EXIT

mkdir -p "$OUT"

#  the binary finds share/ beside its own directory, so both are staged
rm -rf "$STAGE"
mkdir -p "$STAGE/bin"
cp bin/adi2_demo "$STAGE/bin/"
cp -r share "$STAGE/"

#  what SDL reports as the user's folders
mkdir -p "$SCRATCH/config"
printf 'XDG_DOCUMENTS_DIR="$HOME/Documents"\n' > "$SCRATCH/config/user-dirs.dirs"

#  asks the bridge of process $1 for a screenshot; prints the PNG path
screenshot() {
  python3 "$ADI2_TOOLS/adi_mcp_server.py" --pid "$1" --cli screenshot 2>/dev/null
}

#  starts the demo on page $1 with preferences file $2, waits for the
#  bridge, lets transitions settle, and copies the capture to $3
capture() {
  local page=$1 settings=$2 target=$3 pid shot=""
  HOME=/home/user XDG_CONFIG_HOME="$SCRATCH/config" XDG_DATA_HOME="$settings" \
    SDL_VIDEO_DRIVER=offscreen SDL_RENDER_DRIVER=software \
    "$STAGE/bin/adi2_demo" --page "$page" >/dev/null 2>&1 &
  pid=$!
  for _ in $(seq 1 50); do
    shot=$(screenshot "$pid") && break
    sleep 0.2
  done
  sleep 1.5
  shot=$(screenshot "$pid")
  cp "$shot" "$target"
  #  SIGTERM would reach the close handler and its quit dialog
  kill -KILL "$pid"
  wait "$pid" 2>/dev/null || true
  rm -rf "${TMPDIR:-/tmp}/adi_mcp/$pid"
  echo "$target"
}

mkdir -p "$SCRATCH/dark" "$SCRATCH/light/adi2/kitchen-sink"
printf '{"ui": {"theme": "LIGHT"}}\n' > "$SCRATCH/light/adi2/kitchen-sink/settings.json"

for page in "${PAGES[@]}"; do
  capture "$page" "$SCRATCH/dark" "$OUT/$page.png"
done
capture overview "$SCRATCH/light" "$OUT/overview-light.png"
