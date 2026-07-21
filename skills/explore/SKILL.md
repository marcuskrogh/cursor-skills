---
name: explore
description: >-
  High-level alignment on a project or feature idea. Produces a roadmap and a Jira Story
  with linked Tasks for later design or implementation work. Use when the user wants to
  explore scope, prioritise work, or clarify goals at project scale.
---

# Explore

Applies [alignment](../alignment/SKILL.md) at **project or feature scale**. Produces `ROADMAP.md` and Jira issues.

**On invoke:** read [../alignment/SKILL.md](../alignment/SKILL.md) and [../jira/reference.md](../jira/reference.md).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Subject** | A project, product area, or feature idea at high level |
| **Probes** | See [Probes](#probes) |
| **Stop condition** | Goals, scope boundaries, major components, priorities, and open questions are clear |
| **Alignment artifact** | `ROADMAP.md` |
| **Readiness prompt** | "Does this roadmap capture what you want to tackle next?" |

### Probes

- Goals and success criteria (outcomes, not implementation)
- Scope boundaries — what is in vs out for this exploration
- Major components, systems, or workstreams involved
- Dependencies, risks, and unknowns
- Priority order and sequencing rationale
- Jira project key (if not in `JIRA_PROJECT_KEY`)

### Opening

| Context | First move |
|---------|------------|
| **Thin** | "What project or feature idea do you want to explore?" |
| **Rich** | First question on the highest-impact unresolved divergence (scope, priority, or goal) |

### Scope guard

- No detailed component or system design
- No mathematical modelling
- No code or implementation

## Alignment artifact

Write `ROADMAP.md` when the user approves (unless chat-only):

```markdown
# Roadmap: [title]

## Goals
- …

## Scope
### In / Out
- …

## Suggested phases
| Phase | Topic | Notes |
|-------|-------|-------|

## Open questions
- …

## Jira
- Story: PROJ-123
- Tasks: PROJ-124, …
```

## Jira (after approval)

1. Confirm Jira credentials and project per [../jira/reference.md](../jira/reference.md).
2. Create a **Story** summarising the exploration (title from roadmap, description from Goals + Scope).
3. For each **suggested phase**, create a **Task** (or Story child) with:
   - Summary: phase topic
   - Description: notes, acceptance hints, open questions for that phase
   - Link to parent Story (`parent` or **Relates** link)
4. Comment on the Story listing all child keys.
5. Update `ROADMAP.md` **Jira** section with keys and links.
6. Report Story URL and task list to the user. Session ends.

Tasks are intentionally coarse — for later **design** or **implement** sessions, not fully specified here.

## Examples

User: `/explore` — I want to add forecasting to our energy platform.

Agent: Is forecasting for internal operations, customer-facing products, or both?
