# cursor-skills

Personal agent skills for real engineering workflows — alignment, design, modelling, implementation, and review.

Works with **Cursor**, **Claude Code**, **Codex**, **GitHub Copilot**, and any harness that speaks the [Agent Skills](https://agentskills.io) standard.

[![skills.sh](https://skills.sh/b/marcuskrogh/cursor-skills)](https://skills.sh/marcuskrogh/cursor-skills)

## Quickstart (recommended)

Install via [skills.sh](https://skills.sh) — pick skills and which coding agents to target:

```bash
npx skills add marcuskrogh/cursor-skills
```

This copies skills into each agent's project (or global) skill directory. Relative links between skills stay intact because they install as siblings.

## Install as a Claude Code plugin

Prefer a managed, auto-updating bundle instead of editable copies?

Inside Claude Code:

```
/plugin marketplace add marcuskrogh/cursor-skills
/plugin install marcus-skills@marcuskrogh
```

Or from your shell:

```bash
claude plugin marketplace add marcuskrogh/cursor-skills
claude plugin install marcus-skills@marcuskrogh
```

Two install philosophies:

- **[skills.sh](https://skills.sh/marcuskrogh/cursor-skills)** — editable copies in your project; hack on them.
- **Claude plugin** — read-only bundle that updates when this repo ships new versions.

## Author / local machine (this repo)

If you clone this repo to author skills:

```powershell
.\scripts\setup-cursor.ps1
```

Validates skills, syncs into local global dirs (`~/.cursor/skills`, `~/.agents/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/.copilot/skills`), and installs git hooks so `git pull` re-syncs.

## Cloud agents (Cursor)

Bootstrap a project so cloud VMs pull skills at startup:

```powershell
.\scripts\setup-cloud-agent.ps1 -ProjectPath C:\path\to\repo
```

Writes `.cursor/sync-cursor-skills.sh` + `.cursor/environment.json`, and gitignores synced skill dirs. Skills land in both `.agents/skills/` and `.cursor/skills/`.

## Architecture

```
cursor-skills/                      ← git source of truth
├── skills/                         ← Agent Skills standard (edit here)
│   ├── explore/                    ← project/feature alignment → ROADMAP.md
│   ├── design/                     ← topic alignment → PLAN.md
│   ├── model/                      ← mathematical alignment → MODEL.md
│   ├── implement/                  ← managed implementation from a Jira ticket
│   ├── code-review/                ← Standards + Spec review
│   ├── arxiv-research/             ← literature review via arXiv
│   ├── alignment/                  ← base (composed, not user-invoked)
│   ├── implementation/             ← base (composed, not user-invoked)
│   ├── jira/                       ← shared Jira reference
│   └── manage-skills/              ← meta: maintain this repo
├── .claude-plugin/                 ← Claude Code marketplace + plugin manifests
├── scripts/                        ← validate / sync / cloud bootstrap
└── templates/cloud-agent/          ← cloud VM sync script
```

## Skills

| Skill | Invoke | Purpose |
|-------|--------|---------|
| **explore** | user | High-level alignment → `ROADMAP.md` + Jira Story/Tasks |
| **design** | user | Topic alignment → `PLAN.md` + Jira Task/Sub-tasks |
| **model** | user | Mathematical alignment → `MODEL.md` + Jira Task |
| **implement** | user | Build from a Jira ticket via managed sub-agents |
| **code-review** | user | Two-axis PR review (Standards + Spec) + Jira comment |
| **arxiv-research** | user | arXiv literature review brief |
| **manage-skills** | user | Maintain and sync this repository |
| **alignment** | composed | Base questioning loop |
| **implementation** | composed | Base manager/sub-agent loop |
| **jira** | composed | Shared Jira REST reference |

## Workflow for skill changes

1. Edit `skills/<name>/` **in this repo**.
2. `.\scripts\validate-skills.ps1`
3. `.\scripts\sync-local.ps1 -Prune` (or rely on the post-merge hook after `git pull`)
4. `git commit` / `git push`

Use `/manage-skills` for the full checklist.

## Scripts

| Script | Purpose |
|--------|---------|
| `setup-cursor.ps1` | Local author setup — validate, sync globals, git hooks |
| `sync-local.ps1` / `sync-local.sh` | Mirror `skills/` into local global agent dirs |
| `install-to-project.ps1` | Copy skills into a project's `.agents/skills` / `.cursor/skills` |
| `validate-skills.ps1` | Frontmatter, naming, plugin.json coverage |
| `setup-cloud-agent.ps1` | Wire cloud VM skill sync into a project |
| `setup-github.ps1` | First-time push to GitHub |

## Requirements for Jira-backed skills

`explore`, `design`, `model`, `implement`, and `code-review` expect:

| Variable | Purpose |
|----------|---------|
| `JIRA_BASE_URL` | e.g. `https://your-org.atlassian.net` |
| `JIRA_EMAIL` | API user email |
| `JIRA_API_TOKEN` | Atlassian API token |
| `JIRA_PROJECT_KEY` | Default project key |

`code-review` also needs an authenticated `gh` CLI.
