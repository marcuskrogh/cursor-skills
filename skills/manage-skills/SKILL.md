---
name: manage-skills
description: >-
  Maintains the agent skills repository and install workflow. Use when creating
  a new skill, syncing skills locally, updating an existing project install to
  latest main (or a pinned ref), installing via skills.sh or the optional
  Claude plugin, or asking how skills are distributed across Agent Skills harnesses.
disable-model-invocation: true
---

# Manage Skills

This repository is the **single source of truth** for these agent skills. Author under `skills/`, then distribute via skills.sh (primary), local sync, project startup sync, or the optional Claude Code plugin.

## Where skills live

| Location | Role |
|----------|------|
| `skills/` in this repo | **Edit here** — git source of truth (Agent Skills layout) |
| `skills/concepts/` | **Uninvokable concepts** (`CONCEPT_*.md`) — not skills; synced as sibling `concepts/` |
| `~/.agents/skills/` | Shared / standard global mirror — sync only |
| `~/.claude/skills/`, `~/.codex/skills/`, `~/.copilot/skills/`, `~/.cursor/skills/` | Per-harness global mirrors — sync only |
| Project `.agents/skills/` | Per-project install (skills.sh default for most harnesses) |
| `.claude-plugin/` | Optional Claude Code marketplace manifests |

## Concepts vs skills

| | Skills | Concepts |
|-|--------|----------|
| Path | `skills/<name>/SKILL.md` | `skills/concepts/CONCEPT_<NAME>.md` |
| In agent skill list | Yes (name + description) | **No** |
| Invokable | Yes (unless `disable-model-invocation`) | Never |
| Loaded when | Skill is invoked / composed | An invoked skill instructs the agent to read the concept file |

Shared composed skills (`jira`, `tracker`, `workflow`) must stay **siblings** of the skills that link to them. Concepts must stay at `../concepts/CONCEPT_*.md` relative to each skill so installs that copy `concepts/` alongside skill folders keep links intact.

Do not nest shared material under a category folder that skills.sh would flatten away on install — except the dedicated `concepts/` bundle, which sync scripts always copy.

## Install paths

**Universal (recommended):**

```bash
npx skills add marcuskrogh/skills
```

**Optional Claude Code plugin:**

```bash
claude plugin marketplace add marcuskrogh/skills
claude plugin install marcus-skills@marcuskrogh
```

**Project startup sync (CI / cloud / VM):**

```powershell
.\scripts\setup-project-sync.ps1 -ProjectPath C:\path\to\repo
```

Add `-WireCursorCloud` only when the project runs on Cursor Cloud and needs `.cursor/environment.json`.

## Updating an existing install to latest main

Consuming repos should treat updates as an explicit re-sync to a git ref (usually `main`). Pick the path that matches how skills were installed:

| How skills were installed | Update to latest `main` |
|---------------------------|-------------------------|
| **skills.sh** (project or global) | `npx skills update -y` — or force refresh: `npx skills add marcuskrogh/skills -y` |
| **Startup sync** (`.agents/sync-skills.sh`) | `SKILLS_REF=main bash .agents/sync-skills.sh` (default ref is already `main`) |
| **Copied / committed** via `install-to-project.ps1` | Re-run the install script from an up-to-date clone of this repo, then commit `.agents/skills/` |
| **Claude plugin** | Plugin tracks this repo; update/reinstall the plugin after we ship on `main` |

After startup sync or `install-to-project`, check `.agents/skills/.skills-version` for `repo`, `ref`, and `sha`.

If the project already has an older `.agents/sync-skills.sh`, refresh it from this repo first (re-run `setup-project-sync.ps1` or copy `templates/project-sync/sync-skills.sh`), then sync — older scripts only `git pull` and may not advance cleanly or write a version stamp.

**Pin a version** (startup sync only):

```bash
SKILLS_REF=v1.2.0 bash .agents/sync-skills.sh   # tag
SKILLS_REF=<full-sha> bash .agents/sync-skills.sh  # commit
```

Re-run with `SKILLS_REF=main` to leave the pin and track latest again.

## After every skill change (authors)

```powershell
cd D:\code\skills
.\scripts\validate-skills.ps1
.\scripts\sync-local.ps1 -Prune
```

`-Prune` removes skill folders from local mirrors that no longer exist in the repo (always keeps `concepts/`).

## First-time setup (this machine)

```powershell
cd D:\code\skills
.\scripts\setup.ps1
```

Validates skills, syncs to local agent homes, installs git hooks so `git pull` re-syncs.

## Creating a new skill

1. Add `skills/<name>/SKILL.md` (`name` must match folder name).
2. If the skill draws on a shared idea, prefer a `skills/concepts/CONCEPT_*.md` and instruct **On invoke: read …**.
3. Add reference `.md` files alongside as needed.
4. Add `"./skills/<name>"` to `.claude-plugin/plugin.json` → `skills`.
5. `.\scripts\validate-skills.ps1`
6. `.\scripts\sync-local.ps1 -Prune`
7. `git add` / `git commit` / `git push`

## Creating a new concept

1. Add `skills/concepts/CONCEPT_<NAME>.md` (uppercase name, `CONCEPT_` prefix).
2. Do **not** add a `SKILL.md` under `concepts/` and do **not** list concepts in `plugin.json` skills.
3. Reference the concept only from skills that need it (progressive disclosure).
4. Validate + sync as above.

## Rules

- **All skill work in this repo** under `skills/` — not in `~/.*/skills/` mirrors.
- **Keep `plugin.json` in sync** when adding or removing skills (not concepts).
- **Prefer skills.sh** for end-user installs; keep harness-specific adapters optional and explicit.
- **Sync after edits** so local mirrors match the repo (skills + `concepts/`).
- **Document updates** — consumers advance with `npx skills update`, re-add, or `SKILLS_REF=main` sync; stamp lives in `.skills-version`.
- **Do not revive base skills** (`alignment`, `implementation`) as invokable entries — use concepts instead.
