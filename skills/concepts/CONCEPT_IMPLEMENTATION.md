# Concept: Implementation

**Uninvokable concept.** Skills that need this behaviour must instruct the agent to
read this file on invoke. Do not surface this concept unless a skill references it.

## Purpose

Execute an agreed **specification** in a codebase via a **management agent** that
plans, delegates, evaluates, and tracks alignment with the spec — without
implementing large work directly.

## What this is not

- Not a user-invokable workflow by itself
- Not solo implementation in the management thread
- Not alignment — the spec must already exist (from a prior alignment session,
  artifact file, or user-provided plan)

## Extension contract

Skills that apply this concept **must** define:

| Extension | Purpose |
|-----------|---------|
| **Spec source** | How the management agent obtains the specification (chat artifact, file path, user paste) |
| **Branch naming** | How to name the feature branch |
| **Delivery** | PR vs branch-only vs other completion criteria |
| **Verification** | Final checks before delivery (tests, lint, spec checklist) |

Skills **may** define:

| Extension | Purpose |
|-----------|---------|
| **Pre-work** | Steps before first delegation (e.g. commit spec file, ask issue ID) |
| **Work package types** | Domain-specific package categories |
| **Subagent mapping** | Which subagent type per package kind |
| **PR template** | Required PR body sections |

## Invariants

- **Management role.** The invoking agent owns the plan and delegates — it does not
  absorb large implementation work unless a package is trivial or delegation fails
  after retry.
- **Spec fidelity.** Every work package and evaluation cross-references the
  specification. Deviations require plan revision or user alignment.
- **Isolated packages.** Each delegation is self-contained with objective, inputs,
  constraints, deliverables, and branch context.
- **Iterative plan.** Re-evaluate the plan after each sub-agent report; revise
  remaining packages when findings change assumptions.
- **Branch discipline.** Create a feature branch before the first delegation;
  sub-agents commit to that branch.
- **No silent gaps.** If a sub-agent report is insufficient, re-delegate with named
  gaps — do not silently fix large gaps in the management thread.

## Flow

### 1. Obtain specification

Load the spec from the skill's **spec source**. If missing or ambiguous, ask the
user — do not invent requirements.

### 2. Pre-work

Run any **pre-work** defined by the skill (e.g. issue ID, write spec file to repo).

### 3. Create branch

Create the feature branch per **branch naming** before any delegation.

### 4. Draft plan

Break the spec into ordered **work packages** — discrete, delegable units with
acceptance criteria. Respect dependencies.

### 5. Implementation loop

```
1. Select next work package
2. Delegate to a sub-agent with:
   - objective and acceptance criteria
   - spec excerpts and prior package findings
   - branch name; files/areas to touch or avoid
3. Receive sub-agent report
4. Evaluate against package criteria and overall spec
5. Update plan if needed; mark done or re-delegate
6. Repeat until all packages complete
```

### 6. Verify and deliver

Run **verification**. Deliver per the skill (**PR**, branch status, status report).

## Work package delegation

Each delegation must include:

- **Objective** — what this package must achieve
- **Inputs** — spec sections, prior findings, decisions
- **Constraints** — scope, style, dependencies from the spec
- **Deliverables** — code, tests, findings, or reports to return
- **Branch** — feature branch; sub-agents commit here

## Evaluating sub-agent results

1. Check deliverables against package acceptance criteria.
2. Cross-reference with the spec and overall plan.
3. If insufficient → re-delegate with specific gaps.
4. If plan assumptions were wrong → revise remaining packages before continuing.

## Anti-patterns

- Implementing large chunks directly instead of delegating
- Delegating without acceptance criteria or branch context
- Skipping plan re-evaluation after surprising findings
- Starting on `main` without a feature branch
- Ending without the agreed **delivery** outcome
- Proceeding without a usable specification

## Authoring skills that use this concept

1. Instruct the agent to **read this file first** on invoke.
2. Fill in the **extension contract**.
3. Link: `[CONCEPT_IMPLEMENTATION](../concepts/CONCEPT_IMPLEMENTATION.md)`.
