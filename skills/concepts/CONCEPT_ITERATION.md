# Concept: Iteration

**Uninvokable concept.** Skills that need this behaviour must instruct the agent to
read this file on invoke. Do not surface this concept unless a skill references it.

## Purpose

Continue **post-delivery** work with minimal friction when merged implementation needs
a follow-up fix. An iteration is a **new branch + new PR** cycle against the base
branch, driven by a short problem description and (when needed) brief clarifying
alignment — then delivery ready for review.

This concept defines *how* to iterate after ship. Skills define *how* to resolve prior
context, persist the delta, and hand off to review.

## What this is not

- Not a user-invokable workflow by itself
- Not **fix-forward** on an **open** PR before ship (that stays on the same branch/PR)
- Not a full defect intake that stops at a bug report (`/bug` → `/implement`)
- Not reopening or force-pushing a **merged** PR
- Not re-scoping the original feature — only the reported delta

## When to apply

| Situation | Use iteration |
|-----------|---------------|
| Prior Task shipped / PR merged; behaviour still wrong or incomplete | Yes |
| User wants least-resistance follow-up (mobile, integrations, same session) | Yes |
| Open PR has review blockers before merge | **No** — fix-forward / `/review-fix` |
| Brand-new unrelated defect with no prior shipped work | Prefer `/bug` |
| New feature or product definition | Prefer explore / define |

## Relation to other concepts

| Concept | Role in iteration |
|---------|-------------------|
| [CONCEPT_ALIGNMENT](CONCEPT_ALIGNMENT.md) | Optional, **brief** clarifying questions when the invoke leaves divergence |
| [CONCEPT_IMPLEMENTATION](CONCEPT_IMPLEMENTATION.md) | Execute the agreed delta on a **new** branch and open a **new** PR |
| [CONCEPT_REVIEW](CONCEPT_REVIEW.md) | After the iterate PR exists — usually via `/review-fix`, not inside this concept |

Iteration **composes** brief alignment + implementation into one post-ship loop.
Review remains a separate skill so the user can re-run `/iterate` → `/review-fix` as
often as needed.

## Extension contract

Skills that apply this concept **must** define:

| Extension | Purpose |
|-----------|---------|
| **Prior context** | How to resolve the shipped Task / PR / artifacts (key, session, ISSUES) |
| **Alignment depth** | When to skip vs ask clarifying questions; stop condition for the delta |
| **Iteration artifact** | Format and filename for the agreed fix delta (e.g. `ITERATE.md`) |
| **Branch + delivery** | Always new branch from base; new PR (never reuse a merged PR) |
| **Tracker** | New pipeline Task (linked to prior); status through In Review |
| **Handoff** | Default Next after the new PR (usually `/review-fix`) |

Skills **may** define:

| Extension | Purpose |
|-----------|---------|
| **Chain policy** | How a later `/iterate` relates to a previous iterate Task |
| **Spec for review** | How review discovers the delta (`ITERATE.md` + Task body) |

## Invariants

- **Post-merge only for this loop.** If the prior PR is still open, use fix-forward —
  do not open a parallel iterate PR for the same open work.
- **New branch from base.** Create from WORKSPACE base (usually `main`); do not commit
  onto the old merged head as if continuing that PR.
- **New PR every iteration.** Each iterate delivery is a distinct PR.
- **Delta, not reboot.** Spec is the reported problem + acceptance for the fix; keep
  prior `PLAN.md` / `BUG.md` as context, not a fresh product definition.
- **Brief alignment.** Prefer zero questions when the invoke is enough; at most a
  short clarifying loop. One question per message when aligning.
- **Session continuity.** Load prior Task, merged PR, and artifacts before guessing.
- **Chainable.** After this iterate PR ships, another iteration on the same lineage is
  valid and expected when problems persist.
- **No silent ship.** Iterate delivers a PR in **In Review**; it does not merge or
  mark Done (that remains `/ship`).

## Flow

### 1. Resolve prior context

Identify the shipped work this iteration continues: Task key, merged PR, and
`PLAN.md` / `BUG.md` / prior `ITERATE.md` when present.

### 2. Capture the delta

From the user invoke (description + any clarifying answers), pin:

- What is wrong or missing relative to the shipped work
- Acceptance for this fix
- Explicit out of scope (avoid reopening the whole original plan)

### 3. Persist + track

Write the **iteration artifact**. Create a **new** Task linked to the prior work.
Status starts ready to build.

### 4. Implement on a new branch

Apply [CONCEPT_IMPLEMENTATION](CONCEPT_IMPLEMENTATION.md): branch from base, fix the
delta, verify, open a **new** PR. Move the new Task to **In Review**.

### 5. Hand off

End with **Next** → review loop on the **new** Task/PR. User may `/ship` when clean,
then `/iterate` again if needed.

## Anti-patterns

- Reusing a merged PR or pushing to a deleted/merged head as "the" delivery
- Running a long define-style alignment for a one-line post-ship fix
- Creating an iterate Task while an open PR for the same work still needs fix-forward
- Expanding into unrelated features under the iterate label
- Marking the Task **Done** or merging from inside iterate
- Leaving **Next** only in chat

## Authoring skills that use this concept

1. Instruct the agent to **read this file first** on invoke.
2. Fill in the **extension contract**.
3. Link: `[CONCEPT_ITERATION](../concepts/CONCEPT_ITERATION.md)`.
4. Compose alignment and/or implementation concepts as the skill requires.
