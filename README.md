# Agent Skills

Reusable agent skills for alignment, design, modelling, implementation, review, and ship.

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
├── explore/                    ← project/feature alignment → ROADMAP.md
├── design/                     ← topic alignment → PLAN.md (enriches pipeline Task)
├── model/                      ← mathematical alignment → MODEL.md
├── implement/                  ← managed implementation from a Jira ticket
├── review/                ← Standards + Spec review
├── ship/                       ← merge + Done closeout
├── arxiv-research/             ← literature review via arXiv
├── alignment/                  ← base (composed, not user-invoked)
├── implementation/             ← base (composed, not user-invoked)
├── jira/                       ← shared Jira reference
├── workflow/                   ← main pipeline contract (composed)
└── manage-skills/              ← meta: maintain this repo

.claude-plugin/                 ← optional Claude Code marketplace manifests
scripts/                        ← validate / sync / project bootstrap
templates/project-sync/         ← startup sync script template
```

## Main pipeline

```text
explore → design → implement → review → ship
```

One Jira **Task** owns a phase from design through ship. See `skills/workflow/reference.md`.

| Skill | Invoke | Purpose |
|-------|--------|---------|
| **explore** | user | High-level alignment → `ROADMAP.md` + Jira Story/Tasks |
| **design** | user | Topic alignment → `PLAN.md` + Sub-tasks on the pipeline Task |
| **implement** | user | Build from a Jira ticket via managed sub-agents |
| **review** | user | Two-axis PR review (Standards + Spec) + Jira comment |
| **ship** | user | Merge PR, mark Task Done, close the phase |

## Other skills

| Skill | Invoke | Purpose |
|-------|--------|---------|
| **model** | user | Mathematical alignment → `MODEL.md` + Jira Task |
| **arxiv-research** | user | arXiv literature review brief |
| **manage-skills** | user | Maintain and sync this repository |
| **alignment** | composed | Base questioning loop |
| **implementation** | composed | Base manager/sub-agent loop |
| **jira** | composed | Shared Jira REST reference |
| **workflow** | composed | Main pipeline continuity + handoffs |

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

## Requirements for Jira-backed skills

`explore`, `design`, `model`, `implement`, `review`, and `ship` expect:

| Variable | Purpose |
|----------|---------|
| `JIRA_BASE_URL` | e.g. `https://your-org.atlassian.net` |
| `JIRA_EMAIL` | API user email |
| `JIRA_API_TOKEN` | Atlassian API token |
| `JIRA_PROJECT_KEY` | Default project key |

`review` and `ship` also need an authenticated `gh` CLI.
