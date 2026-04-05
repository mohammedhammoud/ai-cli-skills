#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="${ROOT}/skills"
SHARED_INSTRUCTIONS="${ROOT}/instructions.md"
TARGETS=(
  "codex:${HOME}/.codex:AGENTS.md"
  "copilot:${HOME}/.copilot:copilot-instructions.md"
)

cleanup_stale_links() {
  local dest="$1"
  local label="$2"
  local dest_name entry current_target legacy_target target

  mkdir -p "$dest"

  for entry in "$dest"/*; do
    [ -L "$entry" ] || continue
    dest_name="$(basename "$entry")"
    current_target="$SKILLS_ROOT/$dest_name"
    legacy_target="$ROOT/$dest_name"
    target="$(readlink "$entry")" || continue

    case "$target" in
      "$current_target" | "$legacy_target") ;;
      *) continue ;;
    esac

    if [ ! -f "$current_target/SKILL.md" ]; then
      rm -f "$entry"
      echo "$label: removed stale $dest_name"
    fi
  done
}

link_skills() {
  local dest="$1"
  local label="$2"
  local skill

  mkdir -p "$dest"

  for skill in "$SKILLS_ROOT"/*; do
    [ -f "$skill/SKILL.md" ] || continue
    ln -sfn "$skill" "$dest/$(basename "$skill")"
    echo "$label: linked $(basename "$skill")"
  done
}

link_instruction() {
  local source="$1"
  local target="$2"
  local label="$3"
  local name="$4"

  [ -f "$source" ] || return 0

  ln -sfn "$source" "$target"
  echo "$label: linked $name"
}

for target in "${TARGETS[@]}"; do
  IFS=: read -r label home instruction_name <<< "$target"
  dest="${home}/skills"

  if [ -d "$home" ]; then
    cleanup_stale_links "$dest" "$label"
    link_skills "$dest" "$label"
    link_instruction "$SHARED_INSTRUCTIONS" "$home/$instruction_name" "$label" "$instruction_name"
  else
    echo "$label: skipped, $home does not exist"
  fi
done
