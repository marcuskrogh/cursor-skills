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
- Not a free-floating redesign proposal — Architecture findings must be tied to the
  change set and nearby structure, with concrete refactorings

## Axes

Every applicable axis must investigate both **vertically** (deep within a change)
and **horizontally** (across related code and contracts):

| Axis | Focus |
|------|--------|
| **Spec** | Does the change fulfill the agreed spec — no missing or wrong behaviour? |
| **Correctness** | Will it work under real inputs and failures — logic, edges, errors, races, tests? |
| **Integration** | Does it fit the rest of the system — callers, contracts, auth, data flow, config? |
| **Architecture** | Does the change fit and improve the system's structure — layers, boundaries, coupling, dependency direction, and concrete refactorings? |
| **Standards** | Repo conventions + smell baseline (judgement calls; repo docs win). |

A change can look fine on one cut and fail on another:

- Spec-correct but crashes on empty input → **Correctness**
- Locally correct but breaks callers / auth → **Integration**
- Works and integrates but puts logic in the wrong layer or deepens a god module → **Architecture**
- Works and integrates but ignores repo standards / local smells → **Standards**
- Clean code that solves the wrong problem → **Spec**

**Architecture vs Integration vs Standards**

| Cut | Question |
|-----|----------|
| **Integration** | Will this break contracts, callers, auth, or runtime data flow? |
| **Architecture** | Is the *structure* sound — right boundaries, dependency direction, cohesion — and what refactorings would improve it? |
| **Standards** | Does local style match repo docs and the smell baseline (naming, duplication, envy, …)? |

Architecture findings must be **grounded in the change and nearby structure** — not a free-floating redesign of the whole codebase. Prefer concrete refactorings (extract module, invert dependency, split package, introduce a port/adapter, collapse a leaky abstraction) with evidence from the neighbor map and architecture pack.

**Severity guidance for Architecture:** default structural improvement opportunities to `note`; use `should-fix` when the PR introduces a clear architectural regression (wrong layer, new cycle, boundary leak that forces shotgun surgery); reserve `blocker` for hard documented constraints (ADR / architecture doc violations).

**Vertical** catches bugs and design faults inside a path; **horizontal** catches
breaks and structural drift across the system. Both are required on every axis
that applies.

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
| `blocker` | Wrong/missing required behaviour, likely prod bug, security hole, hard standard breach, or hard documented architecture/ADR breach | Must fix before ship |
| `should-fix` | Clear defect, gap, or architectural regression that should not ship | Treat as blocking for fix loops |
| `note` | Improvement, smell, optional cleanup, structural refactoring opportunity | Soft; does not block ship alone |

## Investigation context (mandatory)

Do not review hunks in isolation. Before axis work, prepare:

1. **Changed paths**
2. **Full file snapshots** (or ±context around hunks for huge/generated files)
3. **Neighbor map** — likely callers/callees/tests for changed symbols
4. **Spec pack** — issue body, acceptance, plan/bug/model as applicable
5. **Architecture pack** — ADRs, architecture/docs folders, README architecture sections, package/module map of touched areas, dependency or layering rules if present
6. **Standards pack** — repo docs + smell baseline
7. **Tooling evidence** when cheap and available in-repo

Pass this context into every investigator brief. Architecture investigators need the
architecture pack and a slightly wider structural view (package tree / module
boundaries around changed paths), not only the hunks.

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
- Architecture as vague "consider refactoring" without naming the structure problem,
  evidence, and a concrete refactoring
- Mixing Integration (runtime fit) with Architecture (structural fit) or Standards
  (local smells) into one undifferentiated pile

## Authoring skills that use this concept

1. Instruct the agent to **read this file** on invoke.
2. Fill in the **extension contract**.
3. Link: `[CONCEPT_REVIEW](../concepts/CONCEPT_REVIEW.md)`.
