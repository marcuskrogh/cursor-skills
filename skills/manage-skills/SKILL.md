---
name: manage-skills
description: >-
  Maintains the skills repository and multi-platform install workflow. Use when
  creating a new skill, syncing skills locally, installing via skills.sh or the
  Claude plugin, or asking how to make skills available in Cursor, Claude, Codex,
  or Copilot.
disable-model-invocation: true
---

# Manage Skills

This repository (`cursor-skills`) is the **single source of truth** for all agent skills. Author here under `skills/`, then distribute via skills.sh, Claude Code plugin, or local sync.

## Where skills live

| Location | Role |
|----------|------|
| `cursor-skills/skills/` | **Edit here** — git source of truth (Agent Skills layout) |
| `~/.cursor/skills/` | Cursor global mirror — sync only, never edit |
| `~/.agents/skills/` | Agent Skills / shared global mirror — sync only |
| `~/.claude/skills/` | Claude Code global mirror — sync only |
| `~/.codex/skills/` | Codex global mirror — sync only |
| `~/.copilot/skills/` | GitHub Copilot global mirror — sync only |
| Project `.agents/skills/` | Per-project install (skills.sh default for Cursor/Copilot/Codex) |
| Claude plugin | Managed read-only bundle via `.claude-plugin/` |

## Install paths (users of these skills)

**Universal (recommended):**

```bash
npx skills add marcuskrogh/cursor-skills
```

**Claude Code plugin:**

```bash
claude plugin marketplace add marcuskrogh/cursor-skills
claude plugin install marcus-skills@marcuskrogh
```

**Cloud agent bootstrap (a project):**

```powershell
.\scripts\setup-cloud-agent.ps1 -ProjectPath C:\path\to\repo
```

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
.\scripts\setup-cursor.ps1
```

Validates skills, syncs to local global agent dirs, installs git hooks so `git pull` re-syncs.

## Creating a new skill

1. Add `skills/<name>/SKILL.md` in **this repo** (`name` must match folder name).
2. Add reference `.md` files alongside as needed.
3. Add `"./skills/<name>"` to `.claude-plugin/plugin.json` → `skills`.
4. `.\scripts\validate-skills.ps1`
5. `.\scripts\sync-local.ps1 -Prune`
6. `git add` / `git commit` / `git push`

## Composed skills and relative links

Shared skills (`alignment`, `implementation`, `jira`) must stay **siblings** of the skills that link to them (e.g. `../alignment/SKILL.md`). Do not nest them under a category folder that skills.sh would flatten away on install.

## Mobile Remote Control (multi-repo)

Remote Control from the Cursor mobile app is scoped to the **workspace open on desktop**. Use the generated multi-root workspace:

`D:\code\marcu-projects.code-workspace`

```powershell
cd D:\code\cursor-skills
.\scripts\open-remote-workspace.ps1
```

**Add another repo:** edit `templates/multi-repo/projects.manifest.json`, then run `.\scripts\update-projects-workspace.ps1`.

## Rules

- **All skill work in this repo** under `skills/` — not in `~/.*/skills/` mirrors.
- **Never write to `~/.cursor/skills-cursor/`** — Cursor built-ins only.
- **Keep `plugin.json` in sync** when adding or removing skills.
- **Sync after edits** so local IDE mirrors match the repo.
