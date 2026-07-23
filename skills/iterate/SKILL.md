---
name: iterate
description: >-
  Post-ship follow-up: brief clarifying alignment on a reported issue with already
  merged work, new branch from base, implement the fix, open a new PR, then hand
  off to review-fix. Use when a shipped Task/PR needs another fix cycle; invoke
  again if problems persist after the next ship.
---

# Iterate

Applies [CONCEPT_ITERATION](../concepts/CONCEPT_ITERATION.md), with brief
[CONCEPT_ALIGNMENT](../concepts/CONCEPT_ALIGNMENT.md) when needed and
[CONCEPT_IMPLEMENTATION](../concepts/CONCEPT_IMPLEMENTATION.md) for the fix.

Least-resistance loop after **ship**: describe what is still wrong → (optional short
clarify) → new branch + fix + new PR → **`/review-fix`**. If issues remain after the
next ship, run **`/iterate`** again the same way.

**On invoke:** read [../concepts/CONCEPT_ITERATION.md](../concepts/CONCEPT_ITERATION.md),
[../concepts/CONCEPT_ALIGNMENT.md](../concepts/CONCEPT_ALIGNMENT.md),
[../concepts/CONCEPT_IMPLEMENTATION.md](../concepts/CONCEPT_IMPLEMENTATION.md),
[../workflow/reference.md](../workflow/reference.md),
[../implement/SKILL.md](../implement/SKILL.md), and
[../tracker/SKILL.md](../tracker/SKILL.md).

## When to use

| Use `/iterate` | Do not use `/iterate` |
|----------------|------------------------|
| Prior work **merged** / Task **Done**; still broken or incomplete | Open PR needs review fixes → `/review-fix` or `/implement` fix-forward |
| Same session or prior Task/PR known; want one invoke through new PR | Brand-new unrelated bug with no shipped lineage → prefer `/bug` |
| Mobile / low-friction follow-up on integrations | New feature scope → `/explore` / `/define` |

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Prior context** | See [Resolve prior work](#0-resolve-prior-work) |
| **Alignment depth** | Skip if invoke is enough; else ≤ few clarifying questions; stop when fix is implementable |
| **Iteration artifact** | `ITERATE.md` (path from WORKSPACE; default repo root or `docs/`) |
| **Branch + delivery** | New branch from WORKSPACE base; **new** PR; never reuse a merged PR |
| **Tracker** | **New** Task linked to prior; → In Progress → In Review |
| **Handoff** | `/review-fix <NEW-KEY>` |

### Alignment (when needed)

| Extension | This skill |
|-----------|------------|
| **Subject** | The post-ship delta — what failed in the merged implementation |
| **Probes** | Symptom vs expected; acceptance for this fix; out of scope; any environment/constraint that changes the fix |
| **Stop condition** | Enough to implement the delta without guessing |
| **Alignment / definition artifact** | `ITERATE.md` |
| **Readiness prompt** | "Implement this fix now?" (default **yes** when invoke was rich — only ask if a real divergence remains) |

### Implementation

| Extension | This skill |
|-----------|------------|
| **Spec source** | `ITERATE.md` + new Task (+ prior `PLAN.md` / `BUG.md` / prior `ITERATE.md` as context) |
| **Branch naming** | From WORKSPACE using the **new** Task key |
| **Delivery** | Open PR (WORKSPACE default) |
| **Verification** | Tests/lint for touched area; acceptance in `ITERATE.md` |

## Inputs

```text
/iterate <description>
/iterate <PRIOR-KEY> <description>
/iterate <PRIOR-KEY>
```

1. **Description** — what is wrong or missing after the merge (preferred in the same message).
2. **Prior key** — shipped Task (or prior iterate Task). Optional if inferable.
3. Optional clarifying answers in the same message (treat as already-aligned).

## Process

### 0. Resolve prior work

1. Prefer explicit `<PRIOR-KEY>` from the invoke.
2. Else: session context (just-shipped Task/PR), then latest **Done** row in
   `docs/agents/ISSUES.md` that matches the conversation, then ask once.
3. `fetch` prior Task; load linked `PLAN.md` / `BUG.md` / `ITERATE.md` and the
   **merged** PR URL when present.
4. If the prior PR is still **open** (not merged): **stop**. Tell the user to use
   `/review-fix <KEY>` (or `/implement` fix-forward) on the existing PR — do not
   open a parallel iterate PR.

### 1. Brief alignment

| Invoke richness | Action |
|-----------------|--------|
| **Rich** — clear problem + enough acceptance | Skip questions; draft `ITERATE.md` |
| **Thin** — only "still broken" / vague | One clarifying question at a time (alignment invariants) until implementable |

Do **not** run a full define/bug questionnaire. Prefer one or two high-value questions
max. Scope guard: no unrelated feature design; no coding until the artifact is agreed
(implicitly, when rich).

### 2. Write `ITERATE.md` + create Task

```markdown
# Iterate: [title]

## Prior work
- Task: <PRIOR-KEY>
- PR: <merged url or n/a>
- Spec context: PLAN.md | BUG.md | prior ITERATE.md | …

## Problem
- …

## Clarifications
- …   # omit section if none

## Acceptance criteria
- …

## Out of scope
- …

## Work packages
1. …   # optional; omit for a single fix

## Tracker
- Task: <NEW-KEY>
- Relates: <PRIOR-KEY>

## Next
`/review-fix <NEW-KEY>` — Review and auto-fix until clean
```

Tracker duties:

1. Create a **new** Task (label/type **bug** or prefix `[Iterate]` when useful).
2. Description = problem + acceptance; `attach_or_link` `ITERATE.md`; **Relates**
   (or equivalent) to `<PRIOR-KEY>`.
3. Optional Sub-tasks only if work packages are truly separate.
4. Status **To Do**, then immediately continue to implement (same invoke).
5. Comment on prior Task: iterate follow-up `<NEW-KEY>` + link.
6. Upsert ISSUES mirror.

### 3. Implement (same invoke)

Follow [implement](../implement/SKILL.md) **Build** mode on `<NEW-KEY>`, with these
overrides:

1. Spec = `ITERATE.md` (prior PLAN/BUG are context only).
2. Ensure local base is current (`git fetch`; branch from WORKSPACE base).
3. **New** branch named per WORKSPACE + `<NEW-KEY>`.
4. Task → **In Progress**; implement via managed sub-agents when non-trivial.
5. Verify → open **new** PR → Task → **In Review**.
6. PR body: Summary, Tracker, Prior Task/PR, `ITERATE.md`, Test plan.
7. Upsert ISSUES; comment with PR URL + **Next**.

Do **not** mark Done or merge.

### 4. Tell the user

- New Task key/URL, prior Task key
- PR URL
- Path to `ITERATE.md`
- **Next** handoff

```markdown
## Next
`/review-fix <NEW-KEY>` — Review and auto-fix until clean
```

## Chaining

After `/review-fix` → `/ship` on the iterate Task:

- If problems persist → `/iterate <NEW-KEY-or-PRIOR> <description>` again
  (creates yet another Task + branch + PR).
- Relates chain: each iterate Task links to the immediate prior Task (or original).

## Examples

User: `/iterate MD-5 battery sensor still reports unknown after restart`

Agent: [drafts ITERATE.md, Task MD-12, branch, fix, PR]  
Next: `/review-fix MD-12`

User: `/iterate` — still wrong on HA 2024.7

Agent: What is the observed vs expected behaviour after the last merge?

User: `/iterate MD-12` after ship — edge case when unit is °F

Agent: [new Task MD-13 + PR from main]  
Next: `/review-fix MD-13`
