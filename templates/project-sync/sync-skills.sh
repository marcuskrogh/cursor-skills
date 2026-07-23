#!/usr/bin/env bash
# Fetch skills from the skills repo into the Agent Skills project path.
# Target: .agents/skills/  (shared by Cursor, Copilot, Codex, and other harnesses)
# Always syncs skills/*/ (with SKILL.md) and skills/concepts/.
set -euo pipefail

SKILLS_REPO="${SKILLS_REPO:-${CURSOR_SKILLS_REPO:-https://github.com/marcuskrogh/skills.git}}"
CACHE_DIR="${SKILLS_CACHE:-${CURSOR_SKILLS_CACHE:-/tmp/agent-skills}}"
SOURCE_REL="skills"
TARGET_DIR=".agents/skills"

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

mkdir -p "$TARGET_DIR"

copy_tree() {
  local src="$1"
  local dest="$2"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$src" "$dest"
  else
    cp -a "$src" "$dest"
  fi
}

find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

for skill_path in "$SOURCE_DIR"/*; do
  [ -d "$skill_path" ] || continue
  name="$(basename "$skill_path")"
  if [ "$name" = "concepts" ]; then
    copy_tree "$skill_path" "$TARGET_DIR/"
    continue
  fi
  [ -f "$skill_path/SKILL.md" ] || continue
  copy_tree "$skill_path" "$TARGET_DIR/"
done

if [ ! -d "$TARGET_DIR/concepts" ]; then
  echo "Warning: concepts/ missing after sync (skills may fail to load CONCEPT_*.md)" >&2
fi

echo "Synced skills + concepts to $TARGET_DIR"
