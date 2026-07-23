#!/usr/bin/env bash
# Fetch skills from the skills repo into the Agent Skills project path.
# Target: .agents/skills/  (shared by Cursor, Copilot, Codex, and other harnesses)
# Always syncs skills/*/ (with SKILL.md) and skills/concepts/.
#
# Versioning:
#   SKILLS_REF   — branch, tag, or commit (default: main). Re-run to update.
#   SKILLS_REPO  — git URL (default: https://github.com/marcuskrogh/skills.git)
#   SKILLS_CACHE — clone cache dir (default: /tmp/agent-skills)
#
# After sync, writes .agents/skills/.skills-version with repo/ref/sha so you can
# see which version is installed and re-sync to a newer ref deliberately.
set -euo pipefail

SKILLS_REPO="${SKILLS_REPO:-${CURSOR_SKILLS_REPO:-https://github.com/marcuskrogh/skills.git}}"
SKILLS_REF="${SKILLS_REF:-${CURSOR_SKILLS_REF:-main}}"
CACHE_DIR="${SKILLS_CACHE:-${CURSOR_SKILLS_CACHE:-/tmp/agent-skills}}"
SOURCE_REL="skills"
TARGET_DIR=".agents/skills"

ensure_cache_at_ref() {
  local repo="$1"
  local ref="$2"
  local cache="$3"

  if [ -d "$cache/.git" ]; then
    git -C "$cache" remote set-url origin "$repo"
  else
    rm -rf "$cache"
    mkdir -p "$(dirname "$cache")"
    git clone --depth 1 "$repo" "$cache"
  fi

  # Fetch the requested ref (branch, tag, or SHA) and hard-reset so an old
  # cache always advances cleanly to that version.
  if ! git -C "$cache" fetch --depth 1 origin "$ref"; then
    # Tags / some SHAs need an unshallow-ish retry with explicit refspec
    git -C "$cache" fetch --depth 1 origin "+${ref}:refs/fetch-skills" \
      || git -C "$cache" fetch --depth 1 --tags origin "$ref"
  fi

  if git -C "$cache" rev-parse --verify --quiet FETCH_HEAD >/dev/null; then
    git -C "$cache" checkout -f --detach FETCH_HEAD
  elif git -C "$cache" rev-parse --verify --quiet "refs/fetch-skills" >/dev/null; then
    git -C "$cache" checkout -f --detach "refs/fetch-skills"
  elif git -C "$cache" rev-parse --verify --quiet "$ref" >/dev/null; then
    git -C "$cache" checkout -f --detach "$ref"
  else
    echo "Could not resolve skills ref: $ref (repo: $repo)" >&2
    exit 1
  fi
}

ensure_cache_at_ref "$SKILLS_REPO" "$SKILLS_REF" "$CACHE_DIR"

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

SHA="$(git -C "$CACHE_DIR" rev-parse HEAD)"
SHORT_SHA="$(git -C "$CACHE_DIR" rev-parse --short HEAD)"
STAMP_FILE="$TARGET_DIR/.skills-version"
cat > "$STAMP_FILE" <<EOF
repo=$SKILLS_REPO
ref=$SKILLS_REF
sha=$SHA
synced_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "Synced skills + concepts to $TARGET_DIR"
echo "Version: $SKILLS_REF @ $SHORT_SHA ($SKILLS_REPO)"
