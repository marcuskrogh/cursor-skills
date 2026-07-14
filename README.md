# cursor-skills

Personal Cursor Agent Skills — one git repo, available everywhere.

## The problem

| Location | Local IDE | Cloud agents | Cursor App |
|----------|-----------|--------------|------------|
| `~/.cursor/skills/` | Yes | No | No |
| `.cursor/skills/` in a repo | Yes (that repo) | Yes | Yes (if repo linked) |
| GitHub remote install | Yes | Yes | Yes |

Skills edited only in `~/.cursor/skills/` stay on one machine. This repo fixes that.

## Quick start (this machine)

```powershell
.\scripts\setup-cursor.ps1
```

This validates skills, syncs to `~/.cursor/skills/`, and installs git hooks so `git pull` keeps your local IDE in sync.

## Quick start (manual)

```powershell
.\scripts\sync-local.ps1 -Prune
.\scripts\validate-skills.ps1
```

## Architecture

```
cursor-skills/                 ← git source of truth
└── .cursor/skills/
    ├── grill-me/
    ├── grill-me-and-develop/
    ├── maths-grill-and-develop/
    ├── arxiv-research/
    ├── code-review/
    └── manage-skills/         ← meta-skill for this workflow

~/.cursor/skills/              ← local mirror (sync script)
<project>/.cursor/skills/      ← per-repo copy or submodule (cloud)
GitHub remote rule             ← Cursor App / other machines
```

## Making skills global

### 1. Local IDE (all projects on this machine)

```powershell
.\scripts\sync-local.ps1 -Prune
```

Use `-Link` instead of copy if you have Windows Developer Mode enabled and want live edits.

### 2. Cloud agents

Cloud agents clone the project repo — they never see `~/.cursor/skills/`.

**Per project:** install skills into the project and commit:

```powershell
.\scripts\install-to-project.ps1 -ProjectPath C:\path\to\your-repo -All
```

**Shared across projects:** push this repo to GitHub and add it as a remote rule (see below), or use a git submodule.

### 3. Cursor App and other machines

1. Push this repo to GitHub (public or private).
2. In Cursor: **Customize → Rules → Add Rule → Remote Rule (Github)**.
3. Enter your repo URL.

Skills load without manual sync on that device.

### 4. New skill workflow

1. Add `.cursor/skills/<name>/SKILL.md`.
2. `.\scripts\validate-skills.ps1`
3. `.\scripts\sync-local.ps1 -Prune`
4. `git add` / `git commit` / `git push`

Use `/manage-skills` in Agent chat for the full checklist.

## Scripts

| Script | Purpose |
|--------|---------|
| `setup-cursor.ps1` | **Start here** — validate, sync local, install git hooks |
| `sync-local.ps1` / `sync-local.sh` | Copy or link skills to `~/.cursor/skills/` |
| `install-to-project.ps1` | Copy skills or add submodule to a project |
| `validate-skills.ps1` | Check frontmatter and naming |
| `arxiv_research.py` | arXiv search/lookup/snowball helper (stdlib, MCP-free) |
| `setup-github.ps1` | First-time push to GitHub |

## Current skills

- **grill-me** — Adaptive requirements grilling + managed sub-agent development
- **grill-me-and-develop** — Sequential Q&A grilling, Jira-linked branch, PR workflow
- **maths-grill-and-develop** — One LaTeX question at a time, no lectures/code; `DOCUMENTATION.md` contract
- **arxiv-research** — Topic investigation via the official arXiv Atom API; structured research brief
- **code-review** — Two-axis GitHub PR review (Standards + Spec); posts inline + summary comments via `gh`
- **manage-skills** — This repo's maintenance workflow

## Remote install (Cursor App + other machines)

Repo: [github.com/marcuskrogh/cursor-skills](https://github.com/marcuskrogh/cursor-skills)

1. Open **Customize** in the Cursor sidebar.
2. Go to **Rules** → **Add Rule** → **Remote Rule (Github)**.
3. Enter: `https://github.com/marcuskrogh/cursor-skills`

Skills load on that device without running the sync script.

## First-time GitHub push

If you need to push a fresh clone:

```powershell
.\scripts\setup-github.ps1
```
