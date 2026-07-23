---
name: define
description: >-
  Define a component, system, or pipeline Task before coding. Enriches an explore
  Task (or creates a Task) with PLAN.md and Sub-tasks. Persists keys and Next in
  markdown. Use when agreeing on a definition before implementation.
---

# Define

Applies [CONCEPT_ALIGNMENT](../concepts/CONCEPT_ALIGNMENT.md) and
[CONCEPT_DEFINITION](../concepts/CONCEPT_DEFINITION.md) to a **specific topic**.
Produces `PLAN.md` and Sub-tasks on the **pipeline Task**.

**On invoke:** read [../concepts/CONCEPT_ALIGNMENT.md](../concepts/CONCEPT_ALIGNMENT.md),
[../concepts/CONCEPT_DEFINITION.md](../concepts/CONCEPT_DEFINITION.md),
[../workflow/reference.md](../workflow/reference.md), and
[../tracker/SKILL.md](../tracker/SKILL.md).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Subject** | Component, system, feature, or explore Task |
| **Probes** | See [Probes](#probes) |
| **Stop condition** | No obvious divergence points remain for scope, behavior, constraints, and acceptance |
| **Alignment / definition artifact** | `PLAN.md` (path from WORKSPACE) |
| **Readiness prompt** | "Does this plan look complete?" |

### Probes

Use definition probes from CONCEPT_DEFINITION, specialised for a pipeline phase:

- Scope boundaries (in / out)
- UX and behavior where multiple valid implementations exist
- Data sources, ownership, and edge cases
- Compatibility with existing code or conventions
- Non-obvious constraints the user cares about
- Acceptance criteria and verification approach
- Pipeline Task key from a prior **explore** session (preferred)

### Opening

| Context | First move |
|---------|------------|
| **Thin** | "What do you want to define?" (or resolve Task key) |
| **Rich** / Task key given | Load Task (+ Story, `ROADMAP.md`); first divergence question |

### Scope guard

- No code, file edits, or implementation during definition
- No sub-agent delegation — alignment / definition only

## Entry (pipeline)

When the user passes an explore **Task** key:

1. `fetch` the Task and parent Story via tracker.
2. Load `ROADMAP.md`, and `RESEARCH.md` / `MODEL.md` if present.
3. Use Task summary/description as the subject.

## Alignment artifact

```markdown
# Implementation plan: [title]

## Summary
- …

## Scope / Decisions / Constraints
- …

## Acceptance criteria
- …

## Work packages
1. …
2. …

## Open items
- …

## Tracker
- Provider: …
- Story: <KEY> (if linked)
- Task: <KEY>
- Sub-tasks: …

## Next
`/implement <KEY>` — Build per this plan
```

## Tracker (after approval)

Follow one-issue continuity and the [tracker sync matrix](../workflow/reference.md#tracker-sync-matrix-mandatory).

### Explore Task provided (preferred)

1. **Update that Task** — do not create a parallel definition issue. Status stays **To Do**.
2. Create **Sub-tasks** per work package — status **To Do**; link parent = Task.
3. Write `PLAN.md`; `attach_or_link` path on the Task.
4. `comment` Task + Story with plan path, sub-task keys, **Next**.
5. Upsert ISSUES mirror for Task + Sub-tasks.

### Standalone

Create a new **Task** + Sub-tasks (**To Do**), then same artifact/mirror/comment steps.

### Tracker duties

| Action | Required |
|--------|----------|
| Enrich Task / create Sub-tasks | yes |
| Task status | remain **To Do** |
| Comments + **Next** | Task + Story |
| ISSUES mirror | yes when enabled |
| Close Task | no (ship only) |

## Handoff

```markdown
## Next
`/implement <TASK-KEY>` — Build per PLAN.md
```
