#!/usr/bin/env bash
# Sync skills from this repo to local agent skill directories.
# Usage: ./scripts/sync-local.sh [--prune] [--link]
#
# Default targets: ~/.cursor, ~/.agents, ~/.claude, ~/.codex, ~/.copilot skills dirs.

set -euo pipefail

PRUNE=false
LINK=false

for arg in "$@"; do
  case "$arg" in
    --prune) PRUNE=true ;;
    --link) LINK=true ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/skills"

TARGET_DIRS=(
  "${HOME}/.cursor/skills"
  "${HOME}/.agents/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.codex/skills"
  "${HOME}/.copilot/skills"
)

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

mapfile -t SKILL_PATHS < <(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d -exec test -f "{}/SKILL.md" \; -print | sort)
if [[ ${#SKILL_PATHS[@]} -eq 0 ]]; then
  echo "No skills with SKILL.md found under $SOURCE_DIR" >&2
  exit 1
fi

for TARGET_DIR in "${TARGET_DIRS[@]}"; do
  mkdir -p "$TARGET_DIR"
  SYNCED=()

  for skill_path in "${SKILL_PATHS[@]}"; do
    skill_name="$(basename "$skill_path")"
    dest="$TARGET_DIR/$skill_name"

    if $LINK; then
      rm -rf "$dest"
      ln -s "$skill_path" "$dest"
      echo "Linked ($TARGET_DIR): $skill_name"
    else
      rm -rf "$dest"
      cp -R "$skill_path" "$dest"
      echo "Copied ($TARGET_DIR): $skill_name"
    fi

    SYNCED+=("$skill_name")
  done

  if $PRUNE; then
    for existing in "$TARGET_DIR"/*; do
      [[ -d "$existing" ]] || continue
      name="$(basename "$existing")"
      found=false
      for synced in "${SYNCED[@]}"; do
        if [[ "$synced" == "$name" ]]; then
          found=true
          break
        fi
      done
      if ! $found; then
        echo "Pruning ($TARGET_DIR): $name"
        rm -rf "$existing"
      fi
    done
  fi

  echo "Synced ${#SYNCED[@]} skill(s) to $TARGET_DIR"
done

echo ""
echo "Tip: for project installs across agents, prefer: npx skills add marcuskrogh/cursor-skills"
