# Concept: Definition

**Uninvokable concept.** Skills that need this behaviour must instruct the agent to
read this file on invoke. Do not surface this concept unless a skill references it.

## Purpose

Produce a **concrete, implementable definition** of a subject — a feature, project
phase, defect, subsystem, or other scoped work — so that later skills can build,
review, and ship against an agreed specification.

Definition answers: *what exactly are we doing, what is in/out, how will we know it
is done?* It is not exploration at roadmap scale, not literature research, not math
modelling, and not coding.

## What this is not

- Not a user-invokable workflow by itself
- Not high-level initiative scoping (see explore / roadmap skills)
- Not implementation or delivery
- Not a substitute for research or model side-paths when those are needed first

## When to apply

Use this concept whenever a skill must pin down circumstances such as:

| Subject kind | Definition focuses on |
|--------------|----------------------|
| **Feature / phase** | Behaviour, UX, boundaries, acceptance, work packages |
| **Project slice** | Same, scoped to one deliverable unit |
| **Bug / defect** | Repro, expected vs actual, acceptance for the fix (often lighter) |
| **Other** | Whatever divergence points would block correct delivery |

Skills specialise the subject, probes, artifact shape, and tracker duties.

## Relation to alignment

Definition is typically reached **through** [CONCEPT_ALIGNMENT](CONCEPT_ALIGNMENT.md):
question until divergence points that affect the definition are resolved, then
persist the agreed definition as an artifact.

Skills may combine both concepts: alignment for *how* to question; definition for
*what qualities* the resulting specification must have.

## Qualities of a good definition

A complete definition makes the following unambiguous enough to implement without
guesswork:

| Quality | Meaning |
|---------|---------|
| **Subject** | What is being defined (feature, bug, component, …) |
| **Scope** | Explicit in / out boundaries |
| **Behaviour** | Observable outcomes where multiple implementations would diverge |
| **Constraints** | Non-negotiables (compat, data, performance, security, conventions) |
| **Acceptance** | How success is verified |
| **Work breakdown** | Ordered packages or steps when more than one unit of work |
| **Open items** | Named unknowns — not silent assumptions |

Prefer decisions over option lists in the final artifact. Leave open items only when
the user accepts deferral.

## Extension contract

Skills that apply this concept **must** define:

| Extension | Purpose |
|-----------|---------|
| **Subject** | What kind of thing is being defined |
| **Probes** | Definition-oriented question areas (scope, behaviour, acceptance, …) |
| **Stop condition** | When the definition is implementable |
| **Definition artifact** | Format and filename (e.g. `PLAN.md`, `BUG.md`) |
| **Readiness prompt** | How to confirm the definition with the user |

Skills **may** define:

| Extension | Purpose |
|-----------|---------|
| **Opening** | Thin vs rich / key-driven entry |
| **Scope guard** | What not to do during definition (e.g. no code) |
| **Depth** | How thorough vs lightweight (features vs quick bugs) |
| **Work packages** | Whether and how to break into Sub-tasks |

## Typical probes

Skills should adapt this list to the subject:

- Scope boundaries (in / out)
- UX and behaviour where multiple valid implementations exist
- Data sources, ownership, and edge cases
- Compatibility with existing code or conventions
- Non-obvious constraints the user cares about
- Acceptance criteria and verification approach
- Prior context (roadmap Task, research, model, related issues)

## Depth guidance

| Situation | Depth |
|-----------|-------|
| Non-trivial feature / system change | Full definition: scope, decisions, acceptance, work packages |
| Clear defect with known repro | Lightweight: symptom, repro, expected/actual, acceptance |
| Already implementation-ready | Skip or confirm only gaps — do not re-define for ceremony |

## Anti-patterns

- Defining at roadmap/initiative scale when only a phase/Task is needed
- Leaving critical behaviour as "TBD" without listing it under open items
- Writing implementation details or code during definition
- Creating a parallel ticket when an existing pipeline Task is the subject
- Treating definition as optional for non-trivial features

## Authoring skills that use this concept

1. Instruct the agent to **read this file** (and usually `CONCEPT_ALIGNMENT`) on invoke.
2. Fill in the **extension contract**.
3. Link: `[CONCEPT_DEFINITION](../concepts/CONCEPT_DEFINITION.md)`.
