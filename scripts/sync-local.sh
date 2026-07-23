#!/usr/bin/env bash
# Sync skills from this repo to local agent skill directories.
# Usage: ./scripts/sync-local.sh [--prune] [--link]
#
# Default targets are common Agent Skills home dirs. Override by editing TARGET_DIRS
# or use: npx skills add marcuskrogh/skills
#
# Always syncs skills/*/ (with SKILL.md) and skills/concepts/ as sibling folders.

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
CONCEPTS_SOURCE="$SOURCE_DIR/concepts"

TARGET_DIRS=(
  "${HOME}/.agents/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.codex/skills"
  "${HOME}/.copilot/skills"
  "${HOME}/.cursor/skills"
)

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

if [[ ! -d "$CONCEPTS_SOURCE" ]]; then
  echo "Concepts directory not found: $CONCEPTS_SOURCE" >&2
  exit 1
fi

mapfile -t SKILL_PATHS < <(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d ! -name concepts -exec test -f "{}/SKILL.md" \; -print | sort)
if [[ ${#SKILL_PATHS[@]} -eq 0 ]]; then
  echo "No skills with SKILL.md found under $SOURCE_DIR" >&2
  exit 1
fi

sync_item() {
  local source_path="$1"
  local dest="$2"
  local label="$3"

  if $LINK; then
    rm -rf "$dest"
    ln -s "$source_path" "$dest"
    echo "Linked ($label)"
  else
    rm -rf "$dest"
    cp -R "$source_path" "$dest"
    echo "Copied ($label)"
  fi
}

for TARGET_DIR in "${TARGET_DIRS[@]}"; do
  mkdir -p "$TARGET_DIR"
  SYNCED=()

  for skill_path in "${SKILL_PATHS[@]}"; do
    skill_name="$(basename "$skill_path")"
    dest="$TARGET_DIR/$skill_name"
    sync_item "$skill_path" "$dest" "$TARGET_DIR: $skill_name"
    SYNCED+=("$skill_name")
  done

  sync_item "$CONCEPTS_SOURCE" "$TARGET_DIR/concepts" "$TARGET_DIR: concepts"
  SYNCED+=("concepts")

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

  echo "Synced ${#SYNCED[@]} item(s) to $TARGET_DIR"
done

echo ""
echo "Tip: for project installs, prefer: npx skills add marcuskrogh/skills"
