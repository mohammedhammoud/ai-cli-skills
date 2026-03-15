#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGETS=(
  "codex:${HOME}/.codex"
  "copilot:${HOME}/.copilot"
)

link_skills() {
  local dest="$1"
  local label="$2"
  local skill

  mkdir -p "$dest"

  for skill in "$ROOT"/*; do
    [ -f "$skill/SKILL.md" ] || continue
    ln -sfn "$skill" "$dest/$(basename "$skill")"
    echo "$label: linked $(basename "$skill")"
  done
}

for target in "${TARGETS[@]}"; do
  label="${target%%:*}"
  home="${target#*:}"
  dest="${home}/skills"

  if [ -d "$home" ]; then
    link_skills "$dest" "$label"
  else
    echo "$label: skipped, $home does not exist"
  fi
done
