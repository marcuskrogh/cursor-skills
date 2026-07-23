# Concept: Review

**Uninvokable concept.** Skills that need this behaviour must instruct the agent to
read this file on invoke. Do not surface this concept unless a skill references it.

## Purpose

Evaluate a change set against an agreed specification and the surrounding system
using **multiple axes** and **two investigation directions**, producing actionable
findings with evidence — not a vague opinion dump.

Skills specialise where findings are posted (e.g. GitHub PR), how the change set is
resolved, and tracker handoffs.

## What this is not

- Not a user-invokable workflow by itself
- Not implementation or fix-forward (those use implementation concepts/skills)
- Not a substitute for a missing specification — call out empty intent
- Not a full paste of findings into chat when a durable review surface exists

## Axes

Every applicable axis must investigate both **vertically** (deep within a change)
and **horizontally** (across related code and contracts):

| Axis | Focus |
|------|--------|
| **Spec** | Does the change fulfill the agreed spec — no missing or wrong behaviour? |
| **Correctness** | Will it work under real inputs and failures — logic, edges, errors, races, tests? |
| **Integration** | Does it fit the rest of the system — callers, contracts, auth, data flow, config? |
| **Standards** | Repo conventions + smell baseline (judgement calls; repo docs win). |

A change can look fine on one cut and fail on another:

- Spec-correct but crashes on empty input → **Correctness**
- Locally correct but breaks callers / auth → **Integration**
- Works and integrates but ignores repo standards → **Standards**
- Clean code that solves the wrong problem → **Spec**

**Vertical** catches bugs inside a path; **horizontal** catches breaks across the
system. Both are required on every axis that applies.

## Extension contract

Skills that apply this concept **must** define:

| Extension | Purpose |
|-----------|---------|
| **Change source** | How to obtain the diff / commits under review |
| **Spec source** | Where acceptance criteria live (issue, PLAN, BUG, …) |
| **Publish target** | Where findings are posted (PR review, chat, …) |
| **Checklist** | Axis checklists to paste into investigator briefs |

Skills **may** define:

| Extension | Purpose |
|-----------|---------|
| **Parallelism** | Sub-agent mapping (e.g. one agent per axis) |
| **Severity model** | blocker / should-fix / note and ship impact |
| **Tooling evidence** | Whether to run lint/type/test and feed failures in |
| **Handoff** | Next skill when blocking vs clean |

## Severity (default model)

| Level | Meaning | Ship impact |
|-------|---------|-------------|
| `blocker` | Wrong/missing required behaviour, likely prod bug, security hole, or hard standard breach | Must fix before ship |
| `should-fix` | Clear defect or gap that should not ship | Treat as blocking for fix loops |
| `note` | Improvement, smell, optional cleanup | Soft; does not block ship alone |

## Investigation context (mandatory)

Do not review hunks in isolation. Before axis work, prepare:

1. **Changed paths**
2. **Full file snapshots** (or ±context around hunks for huge/generated files)
3. **Neighbor map** — likely callers/callees/tests for changed symbols
4. **Spec pack** — issue body, acceptance, plan/bug/model as applicable
5. **Standards pack** — repo docs + smell baseline
6. **Tooling evidence** when cheap and available in-repo

Pass this context into every investigator brief.

## Finding shape

Each finding should be structured enough for fix-forward:

- Axis name
- Severity
- Inline vs general
- Path / line when inline
- Vertical or horizontal
- Body: problem → evidence → suggested fix

**Budgets (defaults):** prefer fewer high-severity findings; cap volume per axis;
require evidence and a concrete fix hint.

## Process (conceptual)

1. Resolve the subject under review and confirm it is ready for review.
2. Resolve the change set; confirm a non-empty diff.
3. Build investigation context.
4. Run all applicable axes (prefer parallel investigators).
5. Merge, deduplicate, keep axes separate in the published review.
6. Publish to the skill's target; summarise counts to the user — not the full dump.
7. Hand off: fix loop if blocking; ship path if clean / notes-only.

## Anti-patterns

- Reviewing hunks without neighbors or spec
- Collapsing all axes into one undifferentiated list
- Many notes, few evidenced blockers
- Inventing CI results
- Dumping the full review into chat when a PR (or other durable surface) is the publish target
- Approving when blockers or should-fix remain

## Authoring skills that use this concept

1. Instruct the agent to **read this file** on invoke.
2. Fill in the **extension contract**.
3. Link: `[CONCEPT_REVIEW](../concepts/CONCEPT_REVIEW.md)`.
