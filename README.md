# Agent Skills

Reusable agent skills for workspace setup, alignment, design, modelling, implementation, review, and ship.

Built on the [Agent Skills](https://agentskills.io) standard. Install once via [skills.sh](https://skills.sh); works with any compatible harness (Cursor, Claude Code, Codex, GitHub Copilot, and others).

[![skills.sh](https://skills.sh/b/marcuskrogh/skills)](https://skills.sh/marcuskrogh/skills)

## Quickstart

```bash
npx skills add marcuskrogh/skills
```

Pick the skills you want and which agents to install them for. Skills land in each agent's standard skill directory (project or global). Relative links between skills stay intact because they install as siblings under `.agents/skills/` (or the equivalent home for that agent).

## Optional: Claude Code plugin

If you use Claude Code and prefer a managed bundle instead of editable copies:

```bash
claude plugin marketplace add marcuskrogh/skills
claude plugin install marcus-skills@marcuskrogh
```

Or inside Claude Code: `/plugin marketplace add marcuskrogh/skills` then `/plugin install marcus-skills@marcuskrogh`.

| Path | Philosophy |
|------|------------|
| **skills.sh** | Editable copies in your project — fork and adapt |
| **Claude plugin** | Read-only bundle that updates when this repo ships |

## Author setup (this repo)

```powershell
.\scripts\setup.ps1
```

Validates skills, mirrors them into common local agent homes (`.agents`, `.claude`, `.codex`, `.copilot`, `.cursor`), and installs git hooks so `git pull` re-syncs.

## Project sync (CI / cloud / VM)

For environments that should pull skills at startup instead of committing them:

```powershell
.\scripts\setup-project-sync.ps1 -ProjectPath C:\path\to\repo
```

Writes `.agents/sync-skills.sh` and gitignores `.agents/skills/`.

If the environment is **Cursor Cloud**, also pass `-WireCursorCloud` to add `.cursor/environment.json` that runs the same sync.

## Architecture

```
skills/                         ← source of truth (Agent Skills layout)
├── setup/                      ← workspace alignment → docs/agents/WORKSPACE.md
├── explore/                    ← project/feature alignment → ROADMAP.md
├── bug/                        ← defect alignment → BUG.md (skips explore/design)
├── research/                   ← literature brief → RESEARCH.md
├── model/                      ← mathematical alignment → MODEL.md
├── design/                     ← topic alignment → PLAN.md (enriches pipeline Task)
├── implement/                  ← managed implementation from a pipeline Task
├── review/                     ← one-shot Standards + Spec review
├── review-fix/                ← review ↔ fix-forward until clean
├── ship/                       ← merge + Done closeout
├── summarise/                  ← status: about / stage / Next
├── alignment/                  ← base (composed, not user-invoked)
├── implementation/             ← base (composed, not user-invoked)
├── tracker/                    ← pluggable issue tracker (markdown/jira/github/linear)
├── jira/                       ← Jira REST details (tracker backend)
├── workflow/                   ← pipeline contract (composed)
└── manage-skills/              ← meta: maintain this repo

.claude-plugin/                 ← optional Claude Code marketplace manifests
scripts/                        ← validate / sync / project bootstrap (incl. arxiv_research.py)
templates/project-sync/         ← startup sync script template
```

## Pipelines

**Feature**

```text
setup → explore → (research / model) → design → implement → review-fix → ship
```

**Bug fix** (`/bug` replaces explore + design)

```text
setup → bug → implement → review-fix → ship
```

`/review` remains a one-shot review; `/review-fix` loops review ↔ fix until clean. `/summarise` works anytime.

Run `/setup` first in each consuming repo. Continuity (keys, status, **Next**, artifact links) is mirrored to markdown when enabled. See `skills/workflow/reference.md`.

| Skill | Invoke | Purpose |
|-------|--------|---------|
| **setup** | user | Workspace alignment → `WORKSPACE.md` (tracker + paths) |
| **explore** | user | High-level alignment → `ROADMAP.md` + Story/Tasks |
| **bug** | user | Defect alignment → `BUG.md` + Task (then implement) |
| **research** | user | Literature brief → `RESEARCH.md` (updates Task continuity) |
| **model** | user | Math alignment → `MODEL.md` (updates Task continuity) |
| **design** | user | Topic alignment → `PLAN.md` + Sub-tasks on the pipeline Task |
| **implement** | user | Build from a pipeline Task via managed sub-agents |
| **review** | user | One-shot Standards + Spec PR review |
| **review-fix** | user | Review ↔ auto fix-forward until clean → ship |
| **ship** | user | Merge PR, mark Task Done, close the phase |
| **summarise** | user | About / workflow stage / what to run Next |

## Other skills

| Skill | Invoke | Purpose |
|-------|--------|---------|
| **manage-skills** | user | Maintain and sync this repository |
| **alignment** | composed | Base questioning loop |
| **implementation** | composed | Base manager/sub-agent loop |
| **tracker** | composed | Issue tracker contract + backends |
| **jira** | composed | Jira REST details for the jira backend |
| **workflow** | composed | Pipeline continuity + handoffs |

## Workflow for skill changes

1. Edit `skills/<name>/` in this repo.
2. `.\scripts\validate-skills.ps1`
3. `.\scripts\sync-local.ps1 -Prune` (or rely on the post-merge hook after `git pull`)
4. `git commit` / `git push`

Use `/manage-skills` for the full checklist.

## Scripts

| Script | Purpose |
|--------|---------|
| `setup.ps1` | Author setup — validate, sync local homes, git hooks |
| `sync-local.ps1` / `sync-local.sh` | Mirror `skills/` into local agent homes |
| `install-to-project.ps1` | Copy skills into a project's `.agents/skills` |
| `validate-skills.ps1` | Frontmatter, naming, plugin.json coverage |
| `setup-project-sync.ps1` | Wire startup sync into a project (optional `-WireCursorCloud`) |
| `setup-github.ps1` | First-time push to GitHub |

## Tracker credentials

Configured by `/setup` in `docs/agents/WORKSPACE.md`. Provider-specific:

| Provider | Needs |
|----------|-------|
| **markdown** | None (issues under `docs/agents/issues/`) |
| **jira** | `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`, project key |
| **github** | Authenticated `gh` CLI |
| **linear** | Linear MCP or `LINEAR_API_KEY` + team key |

`review` and `ship` also need an authenticated `gh` CLI for PRs.
