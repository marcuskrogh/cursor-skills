---
name: bug
description: >-
  Fast bug-report alignment that replaces explore and define for defects.
  Produces BUG.md and a single tracker Task (optional Sub-tasks), then hands off
  to implement → review → ship. Use when fixing a bug without a full feature pipeline.
---

# Bug

Applies [CONCEPT_ALIGNMENT](../concepts/CONCEPT_ALIGNMENT.md) and
[CONCEPT_DEFINITION](../concepts/CONCEPT_DEFINITION.md) to a **defect**.
Lightweight alternative to **explore** + **define** for the
[bug fix workflow](../workflow/reference.md#bug-fix-workflow).

**On invoke:** read [../concepts/CONCEPT_ALIGNMENT.md](../concepts/CONCEPT_ALIGNMENT.md),
[../concepts/CONCEPT_DEFINITION.md](../concepts/CONCEPT_DEFINITION.md),
[../workflow/reference.md](../workflow/reference.md), and
[../tracker/SKILL.md](../tracker/SKILL.md).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Subject** | A bug, regression, or incorrect behaviour in the codebase |
| **Probes** | See [Probes](#probes) |
| **Stop condition** | Repro, expected vs actual, impact, and fix acceptance are clear enough to implement |
| **Alignment / definition artifact** | `BUG.md` (path from WORKSPACE; default repo root or `docs/`) |
| **Readiness prompt** | "Is this enough to implement the fix?" |
| **Depth** | Lightweight — prefer fewer questions than full feature define |

### Probes

- What breaks (symptom) — one concrete failure
- How to reproduce (minimal steps, environment if relevant)
- Expected vs actual behaviour
- Impact / severity (user-facing, data, security, flaky test, …)
- Suspected area (file, module, service) if the user knows — do not deep-dive code yet
- Acceptance for the fix (how we know it is fixed)
- Out of scope (related cleanups that must wait)
- Optional: link to parent Story / existing Task if this bug blocks a phase

### Opening

| Context | First move |
|---------|------------|
| **Thin** | "What is broken?" |
| **Rich** (stack trace, steps already pasted) | First question on the highest-impact gap (often expected vs actual, or acceptance) |

### Scope guard

- No feature definition or roadmap work — if it is clearly a feature, redirect to `/explore` or `/define`
- No implementation or file edits during alignment
- Keep the loop short — prefer fewer questions than define; stop when implementable

## Alignment artifact

```markdown
# Bug: [title]

## Summary
- …

## Repro
1. …

## Expected
- …

## Actual
- …

## Impact
- …

## Suspected area
- …

## Acceptance criteria
- …

## Out of scope
- …

## Work packages
1. …   # optional; omit if a single fix commit is enough

## Tracker
- Task: <KEY>
- Sub-tasks: … (if any)

## Next
`/implement <KEY>` — Fix per BUG.md
```

## Tracker (after approval)

1. Create a **Task** (type/label **bug** when the provider supports it — e.g. GitHub label `bug`, Jira Bug issue type if available, else Task with `[Bug]` prefix).
2. Description = summary + repro + expected/actual + acceptance; `attach_or_link` `BUG.md`.
3. Optional **Sub-tasks** only when work packages are truly separate (repro test vs fix vs docs). Prefer **no** Sub-tasks for small fixes.
4. Status **To Do**. `comment` with path + **Next**. Upsert ISSUES mirror.
5. If linked to a parent Story/Task, `link` and comment there.
6. Write `BUG.md`; report key/URL and **Next**. Session ends.

Do **not** create a Story for a lone bug unless the user asks.

### Tracker duties

| Action | Required |
|--------|----------|
| Create Task (+ optional Sub-tasks) | yes |
| Status | **To Do** |
| Comment + **Next** | yes |
| ISSUES mirror | yes when enabled |
| Close | no |

## Handoff

```markdown
## Next
`/implement <TASK-KEY>` — Fix per BUG.md
```

Then the shared delivery loop: **implement → review → ship** (same as features).

## Examples

User: `/bug` — chart shows NaN after midnight UTC.

Agent: What are the minimal steps to reproduce it?
