---
name: design
description: >-
  Alignment on a user-specified component, system, or codebase area. Produces PLAN.md
  and a Jira Task or Story with Sub-tasks per work package. Use when agreeing on
  requirements and design before coding; may extend an existing explore Story.
---

# Design

Applies [alignment](../alignment/SKILL.md) to a **specific topic**. Produces `PLAN.md` and Jira issues with implementation sub-tasks.

**On invoke:** read [../alignment/SKILL.md](../alignment/SKILL.md) and [../jira/reference.md](../jira/reference.md).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Subject** | User-described component, system, object, feature, or codebase area |
| **Probes** | See [Probes](#probes) |
| **Stop condition** | No obvious divergence points remain for scope, behavior, constraints, and acceptance |
| **Alignment artifact** | `PLAN.md` |
| **Readiness prompt** | "Does this plan look complete?" |

### Probes

- Scope boundaries (in / out)
- UX and behavior where multiple valid implementations exist
- Data sources, ownership, and edge cases
- Compatibility with existing code or conventions
- Non-obvious constraints the user cares about
- Acceptance criteria and verification approach
- Parent Jira key from a prior **explore** session (optional)
- Jira project key (if not in `JIRA_PROJECT_KEY`)

### Opening

| Context | First move |
|---------|------------|
| **Thin** | "What do you want to design?" |
| **Rich** | First specific question on an unresolved divergence point |

### Scope guard

- No code, file edits, or implementation during alignment
- No sub-agent delegation — alignment only

## Alignment artifact

```markdown
# Implementation plan: [title]

## Summary
- …

## Scope / Decisions / Constraints
- …

## Acceptance criteria
- …

## Work packages
1. …
2. …

## Open items
- …

## Jira
- Parent: PROJ-123 (optional)
- Design ticket: PROJ-200
- Sub-tasks: PROJ-201, …
```

## Jira (after approval)

1. Confirm credentials per [../jira/reference.md](../jira/reference.md).
2. If user gave a parent Story/Task from **explore**, fetch it and **Relates** or note parent in description.
3. Create a **Task** (or **Story** if the project uses stories for features) for this design:
   - Summary: design topic
   - Description: plan summary, acceptance criteria, link to parent explore ticket if any
4. For each **work package** in the plan, create a **Sub-task** under the design ticket:
   - Summary: package name
   - Description: scope, inputs, expected deliverables, acceptance criteria
5. Write `PLAN.md` to the repo if persisting (include Jira keys).
6. Comment on parent explore ticket (if any) with the new design ticket key.
7. Report design ticket URL and sub-task list. Session ends.

## Examples

User: `/design` the price forecast chart — parent explore ticket SW-40.

Agent: Should the forecast replace the existing chart or appear alongside it?
