# WORKSPACE.md format

Canonical workspace setup artifact for pipeline skills. Default path:
`docs/agents/WORKSPACE.md`.

If this file is missing, pipeline skills **stop** and ask the user to run `/setup`
(unless the user explicitly says to proceed with defaults — then use the
**Defaults** section below and still write the file before creating issues).

## Template

```markdown
# Workspace

Agreed agent workspace setup for this repository.

## Issue tracker

| Field | Value |
|-------|-------|
| Provider | markdown \| jira \| github \| linear |
| Mirror to markdown | true \| false |
| Mirror path | docs/agents/ISSUES.md |

### Provider settings

<!-- Include only the block for the chosen provider -->

#### markdown
| Field | Value |
|-------|-------|
| Issues dir | docs/agents/issues |
| Key prefix | MD |
| Index | docs/agents/issues/INDEX.md |

#### jira
| Field | Value |
|-------|-------|
| Site | https://example.atlassian.net |
| Project key | PROJ |
| Auth | env (JIRA_EMAIL + JIRA_API_TOKEN) |
| Override file | docs/agents/jira.md (optional) |

#### github
| Field | Value |
|-------|-------|
| Repo | owner/name (default: current `gh` repo) |
| Labels | story, task, subtask (create if missing) |

#### linear
| Field | Value |
|-------|-------|
| Team key | ENG |
| API | Linear MCP or LINEAR_API_KEY |
| Project | optional project name/id |

## Artifacts

| Artifact | Path |
|----------|------|
| Agents dir | docs/agents |
| Workspace | docs/agents/WORKSPACE.md |
| Continuity mirror | docs/agents/ISSUES.md |
| Roadmap | ROADMAP.md |
| Plan | PLAN.md |
| Bug | BUG.md |
| Model | MODEL.md |
| Research | RESEARCH.md |

Plans and models may use a subdirectory (e.g. `docs/plans/<slug>.md`) if agreed;
record the convention here.

## Delivery

| Field | Value |
|-------|-------|
| Base branch | main |
| Branch pattern | `<key-lowercase>-<short-description>` |
| Open PR by default | true |
| Merge strategy | merge \| squash \| rebase |
| Require `gh` for review/ship | true |

## Pipeline

| Field | Value |
|-------|-------|
| Skills | explore → (research/model) → define → implement → review-fix → ship; **or** bug → implement → review-fix → ship (+ summarise; `/review` = one-shot) |
| One-issue continuity | true |
| Tracker backend | resolved via provider above (`skills/tracker` when installed) |

## Notes

- …
```

## Defaults (only if user opts out of full setup)

| Field | Default |
|-------|---------|
| Provider | `markdown` |
| Issues dir | `docs/agents/issues` |
| Key prefix | `MD` |
| Mirror | `true` |
| Mirror path | `docs/agents/ISSUES.md` |
| Roadmap / Plan / Model | repo root `ROADMAP.md`, `PLAN.md`, `MODEL.md` |
| Base branch | `main` |
| Open PR | `true` |
| Merge | `squash` if repo uses squash; else `merge` |

## Continuity rule

Regardless of remote tracker, when **Mirror to markdown** is true (recommended):

1. Create/update rows in the mirror file whenever issues are created, transitioned, or handed off.
2. Always write keys + **Next** into `ROADMAP.md` / `PLAN.md` / issue bodies.
3. Remote tracker remains authoritative for status **except** for `markdown` provider, where issue files are authoritative.
