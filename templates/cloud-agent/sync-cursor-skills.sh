#!/usr/bin/env bash
# Fetch skills from marcuskrogh/cursor-skills into project skill dirs (cloud VM startup).
# Installs to .agents/skills/ (Agent Skills / Cursor / Copilot / Codex) and
# .cursor/skills/ (legacy Cursor cloud path).
set -euo pipefail

SKILLS_REPO="${CURSOR_SKILLS_REPO:-https://github.com/marcuskrogh/cursor-skills.git}"
CACHE_DIR="${CURSOR_SKILLS_CACHE:-/tmp/cursor-skills}"
SOURCE_REL="skills"

if [ -d "$CACHE_DIR/.git" ]; then
  git -C "$CACHE_DIR" pull --ff-only
else
  git clone --depth 1 "$SKILLS_REPO" "$CACHE_DIR"
fi

SOURCE_DIR=""
if [ -d "$CACHE_DIR/$SOURCE_REL" ]; then
  SOURCE_DIR="$CACHE_DIR/$SOURCE_REL"
elif [ -d "$CACHE_DIR/.cursor/skills" ]; then
  # Back-compat with older repo layout
  SOURCE_DIR="$CACHE_DIR/.cursor/skills"
else
  echo "Skills source not found in $CACHE_DIR/$SOURCE_REL" >&2
  exit 1
fi

sync_into() {
  local target_dir="$1"
  mkdir -p "$target_dir"

  if command -v rsync >/dev/null 2>&1; then
    # Copy only skill packages (directories containing SKILL.md)
    find "$target_dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    for skill_path in "$SOURCE_DIR"/*; do
      [ -d "$skill_path" ] || continue
      [ -f "$skill_path/SKILL.md" ] || continue
      rsync -a "$skill_path" "$target_dir/"
    done
  else
    find "$target_dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    for skill_path in "$SOURCE_DIR"/*; do
      [ -d "$skill_path" ] || continue
      [ -f "$skill_path/SKILL.md" ] || continue
      cp -a "$skill_path" "$target_dir/"
    done
  fi

  echo "Synced skills to $target_dir"
}

sync_into ".agents/skills"
sync_into ".cursor/skills"
