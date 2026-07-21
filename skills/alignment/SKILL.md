---
name: alignment
description: >-
  Base design specification: adaptive one-question alignment between agent and user until
  fundamental agreement is reached. Not for user invocation — composed only by derived skills.
disable-model-invocation: true
---

# Alignment

**Base design specification.** Users invoke derived skills, not this file.

## Purpose

Reach **fundamental agreement** between agent and user through relentless, adaptive questioning — one question at a time — until divergence points are resolved.

This file defines *how* to align. Derived skills define *what* is being aligned on and *what artifact* alignment produces.

## What this is not

- Not a user-invokable workflow
- Not a questionnaire, intake form, or batched Q&A
- Not a lecture, overview, or announced question plan before the first question
- Not implementation, coding, or delivery — those belong to other base designs (e.g. `implementation`)

## Extension contract

Derived skills **must** define:

| Extension | Purpose |
|-----------|---------|
| **Subject** | What agent and user are aligning on |
| **Probes** | Domain areas to cover via targeted questions |
| **Stop condition** | When alignment is complete (default: no obvious divergence points remain) |
| **Alignment artifact** | Format and filename of the agreed summary (if persisted) |
| **Readiness prompt** | How to close alignment after presenting the artifact |

Derived skills **may** define:

| Extension | Purpose |
|-----------|---------|
| **Opening** | Thin vs rich context handling for the domain |
| **Final clarification** | Last question(s) before the artifact |
| **Format override** | Question presentation (e.g. `Q1:` labels, LaTeX-only blocks) |
| **Scope guard** | Topics excluded during alignment (e.g. no code) |

**Invariants** below always apply. Format overrides change presentation only — never one-question-per-message or adaptive sequencing.

## Invariants

- **One question per message.** No lists of questions, questionnaires, planned batches, or previews of upcoming questions.
- **Start with the subject.** First message is a question — no preamble, scope lecture, or "here is what I will ask."
- **Adaptive.** After each answer, update what is agreed vs unknown; ask the next highest-value question.
- **Concrete and direct.** Short questions; brief acknowledgments only when needed. No filler or small talk.
- **Relentless on divergence.** Prioritize ambiguities, tradeoffs, and assumptions that would change the outcome. Do not nitpick settled points; do not re-ask clear answers.

## Divergence points

A **divergence point** is any choice where multiple valid paths exist and a wrong assumption would waste rework or produce the wrong artifact.

Prefer questions that collapse divergence points. Derived skills list domain probes; this rule governs selection order.

## Flow

### 1. Opening

| Context | First move |
|---------|------------|
| **Thin** — topic named, little detail | One broad opener (derived skill supplies wording) |
| **Rich** — user already describes the subject | Use context; skip broad opener; ask first question on an unresolved divergence point |

### 2. Alignment loop

1. Ask one short question about the current unknown.
2. Wait for the answer.
3. Revise the mental model of agreed vs unknown.
4. Repeat until the derived skill's **stop condition** is met.

### 3. Closing

1. Ask any **final clarification** (one question per message).
2. Present the **alignment artifact** per the derived skill.
3. Ask the **readiness prompt**.
4. If the user names a gap → resume the loop on that gap.
5. If the user approves → alignment ends.

## Format overrides

Derived skills may override *presentation* while keeping invariants:

| Override | Example |
|----------|---------|
| Question labels | `Q1:`, `Q2:`, … |
| Single-block output | Entire message is one LaTeX `$$ … $$` block |
| Extended artifact | Summary is the only long-form output in alignment |

State overrides in the derived skill. See `model` for a full format override example.

## Anti-patterns

- Multiple questions in one message
- Announcing a question plan
- Long preamble before the first question
- Skipping divergence points to finish faster
- Re-asking settled points
- Violating scope guards defined by the derived skill
- Human-like small talk ("Great question!", "Love that idea!")

## Authoring derived skills

1. Instruct the agent to **read this file first** on invoke.
2. Fill in the **extension contract**.
3. Link: `[alignment](../alignment/SKILL.md)`.
