---
name: summarise
description: >-
  Summarises a pipeline Task (or Story): what it is about, where it sits in the
  feature or bug workflow, which artifacts exist, and what to run next. Use when
  asking status, where am I, or what next.
---

# Summarise

Read-only status skill for feature and bug pipelines. Does **not** change issues or
artifacts except optionally refreshing the mirror **Next** column if it is stale.

**On invoke:** read [../workflow/reference.md](../workflow/reference.md) and
[../tracker/SKILL.md](../tracker/SKILL.md).

## Resolve the subject

1. User provides issue key/URL (`/summarise MD-2`, `/summarise PROJ-200`, `/summarise #42`).
2. Else use the single **active** row in `docs/agents/ISSUES.md` (In Progress / In Review).
3. Else ask once: "Which issue should I summarise?"

`fetch` the issue via the tracker backend. Load linked markdown when present:

| File | Use |
|------|-----|
| `docs/agents/WORKSPACE.md` | Provider + paths |
| `docs/agents/ISSUES.md` | Mirror status / Next |
| `ROADMAP.md` | Phase context / parent Story |
| `PLAN.md` | Feature design readiness |
| `BUG.md` | Bug-fix readiness |
| `MODEL.md` | Model spec |
| `RESEARCH.md` | Research brief |
| PR (if linked) | Implement / review / ship stage |

## Infer workflow stage

Detect **track**: feature if `PLAN.md` / ROADMAP phase; **bug** if `BUG.md` (or bug label/type) without a feature plan.

Pick the furthest stage that matches evidence:

| Stage | Evidence |
|-------|----------|
| **setup** | No WORKSPACE (tell user to `/setup`) |
| **explore** | Story only / feature Task with no PLAN |
| **bug** | `BUG.md` linked; not yet In Progress |
| **research** | `RESEARCH.md` linked; design not done |
| **model** | `MODEL.md` linked; design not done |
| **design** | Feature Task enriched but plan incomplete; or PLAN exists, not started |
| **implement** | Status In Progress, or branch/PR WIP |
| **review** | Status In Review; PR open (one-shot) |
| **review-fix** | Actively looping review↔fix, or preferred post-implement stage |
| **fix-forward** | In Review/In Progress + open `REQUEST_CHANGES` / unreplied review threads |
| **ship-ready** | In Review + latest review clean (no blockers) |
| **done** | Status Done / PR merged |

## Reply shape (chat only)

```markdown
# <KEY>: <title>

**Track:** feature | bug

**About:** <2–4 sentences from issue + PLAN/BUG/ROADMAP>

**Stage:** <stage> — <one line why>

**Artifacts:**
- ROADMAP / PLAN / BUG / MODEL / RESEARCH / PR — present or missing

**Status:** <To Do | In Progress | In Review | Done>

## Next
`/<skill> <KEY>` — <one-line why>
```

If Done: **Next** is the following phase Task from ROADMAP, another bug, or "No further work on this Task."

## Rules

- Do not implement, transition, or open PRs.
- Prefer persisted **Next** from issue / mirror / PLAN / BUG when still valid; recompute if status moved past it.
- If WORKSPACE is missing, say so and **Next** = `/setup`.
