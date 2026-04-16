#!/usr/bin/env bash
set -euo pipefail
trap 'log_error "error occurred on line $LINENO"' ERR

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${ROOT}/src"
SKILLS_ROOT="${SRC_ROOT}/skills"
INSTRUCTIONS_SOURCE="${SRC_ROOT}/instructions.md"

ALL_CLIS=(
  codex
  copilot
)

SELECTED_CLIS=()

if [ -t 1 ]; then
  C_RESET=$'\033[0m'
  C_DIM=$'\033[2m'
  C_BLUE=$'\033[34m'
  C_CYAN=$'\033[36m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
else
  C_RESET=""
  C_DIM=""
  C_BLUE=""
  C_CYAN=""
  C_GREEN=""
  C_YELLOW=""
  C_RED=""
fi

log() {
  local _level="$1"
  local icon="$2"
  local color="$3"
  shift 3

  printf '%s%s %s%-2s%s %s\n' \
    "${C_DIM}" "$(date +%H:%M:%S)" \
    "${color}" "${icon}" "${C_RESET}" "$*"
}

log_step()  { log STEP "▶" "${C_CYAN}" "$@"; }
log_info()  { log INFO "●" "${C_BLUE}" "$@"; }
log_ok()    { log DONE "✓" "${C_GREEN}" "$@"; }
log_warn()  { log WARN "▲" "${C_YELLOW}" "$@"; }
log_error() { log FAIL "✖" "${C_RED}" "$@" >&2; }

get_cli_config() {
  local cli="$1"

  case "$cli" in
    codex)
      CLI_HOME="${HOME}/.codex"
      CLI_SKILLS_DEST="${CLI_HOME}/skills"
      CLI_INSTRUCTION_DEST="${CLI_HOME}/AGENTS.md"
      ;;
    copilot)
      CLI_HOME="${HOME}/.copilot"
      CLI_SKILLS_DEST="${CLI_HOME}/skills"
      CLI_INSTRUCTION_DEST="${CLI_HOME}/copilot-instructions.md"
      ;;
    *)
      log_warn "$cli: unknown cli"
      return 1
      ;;
  esac
}

pick_clis() {
  local options=("${ALL_CLIS[@]}" "all")
  local choice

  if [ ! -t 0 ]; then
    SELECTED_CLIS=("${ALL_CLIS[@]}")
    return 0
  fi

  printf '\n%sSelect CLI to sync%s\n' "$C_CYAN" "$C_RESET"
  PS3="> "

  select choice in "${options[@]}"; do
    case "$choice" in
      codex)
        SELECTED_CLIS=("codex")
        break
        ;;
      copilot)
        SELECTED_CLIS=("copilot")
        break
        ;;
      all)
        SELECTED_CLIS=("${ALL_CLIS[@]}")
        break
        ;;
      *)
        log_warn "invalid choice"
        ;;
    esac
  done
}

cleanup_stale_links() {
  local dest="$1"
  local label="$2"
  local entry
  local dest_name
  local target
  local current_target
  local legacy_target
  local src_target

  mkdir -p "$dest"

  for entry in "$dest"/*; do
    [ -L "$entry" ] || continue

    dest_name="$(basename "$entry")"
    current_target="$SKILLS_ROOT/$dest_name"
    legacy_target="$ROOT/skills/$dest_name"
    src_target="$SRC_ROOT/$dest_name"
    target="$(readlink "$entry")" || continue

    case "$target" in
      "$current_target"|"$legacy_target"|"$src_target") ;;
      *) continue ;;
    esac

    if [ ! -f "$current_target/SKILL.md" ]; then
      rm -f "$entry"
      log_info "$label: removed stale skill link $dest_name"
    fi
  done
}

link_skills() {
  local dest="$1"
  local label="$2"
  local skill
  local skill_name

  mkdir -p "$dest"
  [ -d "$SKILLS_ROOT" ] || return 0

  for skill in "$SKILLS_ROOT"/*; do
    [ -f "$skill/SKILL.md" ] || continue
    skill_name="$(basename "$skill")"
    ln -sfn "$skill" "$dest/$skill_name"
    log_ok "$label: linked skill $skill_name"
  done
}

link_file() {
  local source="$1"
  local target="$2"
  local label="$3"
  local name="$4"

  if [ ! -e "$source" ]; then
    log_warn "$label: source not found, skipping $name"
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  ln -sfn "$source" "$target"
  log_ok "$label: linked $name -> $target"
}

install_rtk() {
  if command -v rtk >/dev/null 2>&1; then
    log_info "rtk: found"
    return 0
  fi

  log_warn "rtk: missing"

  if command -v brew >/dev/null 2>&1; then
    brew install rtk
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh)"
    return 0
  fi

  log_error "rtk: cannot auto-install. See https://github.com/rtk-ai/rtk"
  return 1
}

main() {
  local cli

  pick_clis
  install_rtk
  log_step "starting sync"

  for cli in "${SELECTED_CLIS[@]}"; do
    get_cli_config "$cli" || continue

    if [ ! -d "$CLI_HOME" ]; then
      log_warn "$cli: skipped, $CLI_HOME does not exist"
      continue
    fi

    log_step "$cli: syncing"
    cleanup_stale_links "$CLI_SKILLS_DEST" "$cli"
    link_skills "$CLI_SKILLS_DEST" "$cli"
    link_file "$INSTRUCTIONS_SOURCE" "$CLI_INSTRUCTION_DEST" "$cli" "$(basename "$CLI_INSTRUCTION_DEST")"
  done

  log_ok "sync complete"
}

main "$@"