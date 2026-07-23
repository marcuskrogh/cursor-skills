---
name: model
description: >-
  Mathematical alignment with LaTeX-only questions. Produces MODEL.md, links it to
  a pipeline Task when given, and updates shared continuity markdown
  (ROADMAP/PLAN/ISSUES). Use for dynamical models, OCP, estimators, or applied math.
---

# Model

Applies [CONCEPT_ALIGNMENT](../concepts/CONCEPT_ALIGNMENT.md) to **applied
mathematical** topics. Optional side path on the main pipeline — usually after
**research** or **explore**, before or alongside **define**, and before **implement**.

**On invoke:** read [../concepts/CONCEPT_ALIGNMENT.md](../concepts/CONCEPT_ALIGNMENT.md),
[format.md](format.md), [reference.md](reference.md),
[../workflow/reference.md](../workflow/reference.md), and
[../tracker/SKILL.md](../tracker/SKILL.md).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Subject** | User-described mathematical object (model, OCP, estimator, etc.) |
| **Probes** | See [Probes](#probes) |
| **Stop condition** | Mathematical foundations are unambiguous |
| **Alignment artifact** | `MODEL.md` (path from WORKSPACE) |
| **Readiness prompt** | LaTeX block: "Ready to finalise the model specification?" (see [format.md](format.md)) |
| **Format override** | LaTeX-only questions per [format.md](format.md) |
| **Scope guard** | No code unless mathematically essential to clarify the model |

### Probes

- Model class, state/input/output structure, constraints, objectives
- Numerical schemes, estimation/control choices, discretisation
- Pipeline Task key from **explore** / **define** (preferred)
- Related `RESEARCH.md` if present
- Target path for `MODEL.md` (default from WORKSPACE)

### Opening

| Context | First move |
|---------|------------|
| **Thin** | One LaTeX block: what mathematical object or problem class? |
| **Rich** / Task key | Load Task + `RESEARCH.md` / `ROADMAP.md` if present; first unresolved divergence in LaTeX |

## Alignment artifact

```markdown
# Model: [title]

## Problem statement / Notation / Formulation
…

## Assumptions / Algorithmic choices / Numerical considerations
…

## Open items
…

## Tracker
- Task: <KEY>
- Research: RESEARCH.md (if any)

## Next
`/<skill> <KEY>` — <why>
```

Use the **definition hierarchy** from [format.md](format.md).

## Tracker and continuity (after approval)

1. Write `MODEL.md` at the agreed path; commit when appropriate (include issue key).
2. **Pipeline Task provided (preferred):** enrich *that* Task — `attach_or_link` `MODEL.md`, `comment` summary + **Next**. Do **not** create a parallel Task. Leave status unchanged (usually **To Do**).
3. **Standalone:** create a **Task** (**To Do**), link parent Story if any, then same attach/comment.
4. Update shared markdown:
   - `ROADMAP.md` phase notes / artifact column → `MODEL.md`
   - `PLAN.md` if it exists → Inputs / Constraints link to `MODEL.md`
   - `RESEARCH.md` Tracker section if it exists → link `MODEL.md`
   - Upsert `docs/agents/ISSUES.md` mirror
5. Report path, key, and **Next**. Do **not** close the Task.

## Handoff

| Context | Next |
|---------|------|
| Behaviour/UX still open | `/define <KEY>` |
| Plan already complete | `/implement <KEY>` |
| Need literature first | `/research <KEY>` |

```markdown
## Next
`/define <KEY>` — Define implementation around this model
```

## Examples

User: `/model` MD-2 — MPC for the CSTR, research in RESEARCH.md.

Agent: [Single LaTeX block — ODE vs SDE vs spatial PDE?]
