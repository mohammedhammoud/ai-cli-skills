#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${ROOT}/src"
SKILLS_ROOT="${SRC_ROOT}/skills"
SHARED_INSTRUCTIONS="${SRC_ROOT}/instructions.md"
TARGETS=(
  "codex:${HOME}/.codex:AGENTS.md"
  "copilot:${HOME}/.copilot:copilot-instructions.md"
)

say() {
  printf '%s\n' "$*"
}

ask_yes_no() {
  local prompt="${1}"
  local reply

  if [ ! -t 0 ]; then
    return 1
  fi

  printf '%s [Y/n] ' "$prompt"
  read -r reply || return 1
  case "${reply:-y}" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

cleanup_stale_links() {
  local dest="$1"
  local label="$2"
  local dest_name entry target current_target legacy_target src_target

  mkdir -p "$dest"

  for entry in "$dest"/*; do
    [ -L "$entry" ] || continue
    dest_name="$(basename "$entry")"
    current_target="$SKILLS_ROOT/$dest_name"
    legacy_target="$ROOT/skills/$dest_name"
    src_target="$SRC_ROOT/$dest_name"
    target="$(readlink "$entry")" || continue

    case "$target" in
      "$current_target" | "$legacy_target" | "$src_target") ;;
      *) continue ;;
    esac

    if [ ! -f "$current_target/SKILL.md" ]; then
      rm -f "$entry"
      say "$label: removed stale $dest_name"
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
    say "$label: linked $(basename "$skill")"
  done
}

link_instruction() {
  local target="$1"
  local label="$2"
  local name="$3"

  [ -f "$SHARED_INSTRUCTIONS" ] || return 0
  ln -sfn "$SHARED_INSTRUCTIONS" "$target"
  say "$label: linked $name"
}

install_rtk() {
  if command -v rtk >/dev/null 2>&1; then
    say "rtk: found"
    return 0
  fi

  say "rtk: missing"

  if ! ask_yes_no "Install rtk now?"; then
    say "rtk: skipped"
    return 1
  fi

  if command -v brew >/dev/null 2>&1; then
    brew install rtk
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh)"
    return 0
  fi

  say "rtk: cannot auto-install. See https://github.com/rtk-ai/rtk"
  return 1
}

init_rtk() {
  [ -x "$(command -v rtk)" ] || return 0

  if [ -d "${HOME}/.codex" ] && ask_yes_no "Run 'rtk init -g --codex'?"; then
    rtk init -g --codex
  fi

  if [ -d "${HOME}/.copilot" ] && ask_yes_no "Run 'rtk init -g' for Copilot?"; then
    rtk init -g
  fi
}

main() {
  local target label home instruction_name dest

  install_rtk || true
  init_rtk

  for target in "${TARGETS[@]}"; do
    IFS=: read -r label home instruction_name <<< "$target"
    dest="${home}/skills"

    if [ -d "$home" ]; then
      cleanup_stale_links "$dest" "$label"
      link_skills "$dest" "$label"
      link_instruction "$home/$instruction_name" "$label" "$instruction_name"
    else
      say "$label: skipped, $home does not exist"
    fi
  done
}

main "$@"
