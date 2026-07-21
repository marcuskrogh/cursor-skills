---
name: implement
description: >-
  Managed sub-agent implementation in a GitHub repo against a Jira Task or Story and its
  Sub-tasks. Transitions the parent ticket to In Progress, then In Review when the PR is
  ready. Use when implementing work defined by a Jira ticket and linked specification.
---

# Implement

Applies [implementation](../implementation/SKILL.md) to the **current repository**, tracked in **Jira**.

**On invoke:** read [../implementation/SKILL.md](../implementation/SKILL.md) and [../jira/reference.md](../jira/reference.md).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Spec source** | Jira ticket description + sub-tasks + repo spec files |
| **Branch naming** | `<jira-key-lowercase>-<short-description>` |
| **Delivery** | PR (default) or branch-only |
| **Verification** | Tests, lint, spec checklist, sub-task completion |

## Jira ticket (required)

Obtain the parent **Task**, **Story**, or **Request** key before work:

1. User provides key (e.g. `SW-200`) in the invoke message
2. User points to a ticket URL
3. **Ask** — one question: "Which Jira ticket should this implementation track?"

Fetch the ticket and its **Sub-tasks** per [../jira/reference.md](../jira/reference.md). Use sub-tasks as work packages when present; otherwise derive packages from the ticket description and repo spec files (`PLAN.md`, `MODEL.md`, `DOCUMENTATION.md`).

Do not invent requirements beyond the ticket and linked specs.

### Specification priority

1. Jira sub-task descriptions (work packages)
2. Parent ticket description
3. Repo files referenced in ticket or repo (`PLAN.md`, `MODEL.md`, …)
4. User paste in the current message

## Jira status (manager agent)

| When | Action |
|------|--------|
| Session start | Transition parent ticket to **In Progress** |
| Each sub-task started | Transition sub-task to **In Progress** (if separate states exist) |
| Sub-task done | Transition sub-task to **Done**; comment with brief summary |
| PR opened (or review ready) | Transition parent to **In Review** |
| User asks to finish without PR | Comment status; leave parent **In Progress** unless user specifies otherwise |

Comment on the parent ticket when: session starts, each major package completes, PR is opened (include PR URL).

## Pre-work

1. Resolve Jira ticket and sub-tasks
2. Transition parent to **In Progress**
3. Ask (one question): **open a PR** or **stop at a feature branch**? Default PR.
4. Create branch: `<jira-key-lowercase>-<short-description>`

## Work package types

| Type | Subagent |
|------|----------|
| Structure exploration | `explore` |
| Research | `generalPurpose` |
| Implementation | `generalPurpose` |
| Testing | `generalPurpose` |
| Review | `bugbot`, `security-review` |

Map packages to Jira sub-tasks by summary or description. Update sub-task status as each package completes.

## PR template

- Summary (from ticket + what was built)
- `Jira: <url>`
- Spec references (`PLAN.md`, `MODEL.md`, …)
- Test plan
- List of completed sub-tasks

After PR creation: transition parent to **In Review**; Jira comment with PR link.

## Flow

1. Resolve Jira ticket + spec
2. **In Progress** on parent
3. Delivery clarification (PR vs branch)
4. Create branch
5. Delegate work packages ↔ sub-tasks; update Jira as you go
6. Verify → PR → **In Review** on parent

## Examples

User: `/implement` SW-200

Agent: [Fetches SW-200 and sub-tasks, transitions to In Progress, asks PR vs branch]
