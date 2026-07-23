---
name: explore
description: >-
  High-level alignment on a project or feature idea. Produces a roadmap and
  tracker Story/Tasks for later define on the main pipeline. Persists keys and
  Next in markdown. Use when exploring scope or prioritising work at project scale.
---

# Explore

Applies [CONCEPT_ALIGNMENT](../concepts/CONCEPT_ALIGNMENT.md) at **project or
feature scale**. Produces `ROADMAP.md` and tracker issues that feed **define**.

**On invoke:** read [../concepts/CONCEPT_ALIGNMENT.md](../concepts/CONCEPT_ALIGNMENT.md),
[../workflow/reference.md](../workflow/reference.md), and
[../tracker/SKILL.md](../tracker/SKILL.md) (loads `WORKSPACE.md` + provider backend).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Subject** | A project, product area, or feature idea at high level |
| **Probes** | See [Probes](#probes) |
| **Stop condition** | Goals, scope boundaries, major components, priorities, and open questions are clear |
| **Alignment artifact** | `ROADMAP.md` (path from WORKSPACE) |
| **Readiness prompt** | "Does this roadmap capture what you want to tackle next?" |

### Probes

- Goals and success criteria (outcomes, not implementation)
- Scope boundaries — what is in vs out for this exploration
- Major components, systems, or workstreams involved
- Dependencies, risks, and unknowns
- Priority order and sequencing rationale
- Confirm tracker from WORKSPACE (do not re-litigate unless missing)

### Opening

| Context | First move |
|---------|------------|
| **Thin** | "What project or feature idea do you want to explore?" |
| **Rich** | First question on the highest-impact unresolved divergence (scope, priority, or goal) |

### Scope guard

- No detailed component or system definition
- No mathematical modelling
- No code or implementation

## Alignment artifact

```markdown
# Roadmap: [title]

## Goals
- …

## Scope
### In / Out
- …

## Suggested phases
| Phase | Topic | Notes | Issue |
|-------|-------|-------|-------|
| 1 | … | … | <KEY> |

## Open questions
- …

## Tracker
- Provider: markdown | jira | github | linear
- Story: <KEY>
- Tasks: <KEY>, …

## Next
`/define <KEY>` — Define the first-priority phase
```

## Tracker (after approval)

1. Resolve provider ops via [../tracker/reference.md](../tracker/reference.md).
2. Create a **Story** (Goals + Scope) — status **To Do**.
3. For each phase, create a **Task** linked to the Story — status **To Do** (pipeline owner for define → ship).
4. `comment` on the Story with child keys + **Next**; upsert ISSUES mirror (Story + all Tasks).
5. Update `ROADMAP.md`; report keys/URLs and **Next**. Session ends.

### Tracker duties

| Action | Required |
|--------|----------|
| Create Story + Tasks | yes |
| Link Tasks → Story | yes |
| Status | **To Do** for all new issues |
| Comment + **Next** on Story | yes |
| ISSUES mirror upsert | yes when enabled |
| Close anything | no |

### Handoff

```markdown
## Next
`/define <TASK-KEY>` — Define phase: <topic>
```

## Examples

User: `/explore` — I want to add forecasting to our energy platform.

Agent: Is forecasting for internal operations, customer-facing products, or both?
