---
name: manage-skills
description: >-
  Maintains the agent skills repository and install workflow. Use when creating
  a new skill, syncing skills locally, installing via skills.sh or the optional
  Claude plugin, or asking how skills are distributed across Agent Skills harnesses.
disable-model-invocation: true
---

# Manage Skills

This repository is the **single source of truth** for these agent skills. Author under `skills/`, then distribute via skills.sh (primary), local sync, project startup sync, or the optional Claude Code plugin.

## Where skills live

| Location | Role |
|----------|------|
| `skills/` in this repo | **Edit here** — git source of truth (Agent Skills layout) |
| `~/.agents/skills/` | Shared / standard global mirror — sync only |
| `~/.claude/skills/`, `~/.codex/skills/`, `~/.copilot/skills/`, `~/.cursor/skills/` | Per-harness global mirrors — sync only |
| Project `.agents/skills/` | Per-project install (skills.sh default for most harnesses) |
| `.claude-plugin/` | Optional Claude Code marketplace manifests |

## Install paths

**Universal (recommended):**

```bash
npx skills add marcuskrogh/cursor-skills
```

**Optional Claude Code plugin:**

```bash
claude plugin marketplace add marcuskrogh/cursor-skills
claude plugin install marcus-skills@marcuskrogh
```

**Project startup sync (CI / cloud / VM):**

```powershell
.\scripts\setup-project-sync.ps1 -ProjectPath C:\path\to\repo
```

Add `-WireCursorCloud` only when the project runs on Cursor Cloud and needs `.cursor/environment.json`.

## After every skill change (authors)

```powershell
cd D:\code\cursor-skills
.\scripts\validate-skills.ps1
.\scripts\sync-local.ps1 -Prune
```

`-Prune` removes skill folders from local mirrors that no longer exist in the repo.

## First-time setup (this machine)

```powershell
cd D:\code\cursor-skills
.\scripts\setup.ps1
```

Validates skills, syncs to local agent homes, installs git hooks so `git pull` re-syncs.

## Creating a new skill

1. Add `skills/<name>/SKILL.md` (`name` must match folder name).
2. Add reference `.md` files alongside as needed.
3. Add `"./skills/<name>"` to `.claude-plugin/plugin.json` → `skills`.
4. `.\scripts\validate-skills.ps1`
5. `.\scripts\sync-local.ps1 -Prune`
6. `git add` / `git commit` / `git push`

## Composed skills and relative links

Shared skills (`alignment`, `implementation`, `jira`) must stay **siblings** of the skills that link to them (e.g. `../alignment/SKILL.md`). Do not nest them under a category folder that skills.sh would flatten away on install.

## Rules

- **All skill work in this repo** under `skills/` — not in `~/.*/skills/` mirrors.
- **Keep `plugin.json` in sync** when adding or removing skills.
- **Prefer skills.sh** for end-user installs; keep harness-specific adapters optional and explicit.
- **Sync after edits** so local mirrors match the repo.
