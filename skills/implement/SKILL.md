---
name: implement
description: >-
  Managed sub-agent implementation against a Jira Task (and Sub-tasks) from design.
  Moves the ticket In Progress then In Review when the PR is ready; supports
  fix-forward after review. Use when building work defined by a pipeline ticket.
---

# Implement

Applies [implementation](../implementation/SKILL.md) to the **current repository**, tracked in **Jira**, on the main pipeline Task.

**On invoke:** read [../implementation/SKILL.md](../implementation/SKILL.md), [../workflow/reference.md](../workflow/reference.md), and [../jira/reference.md](../jira/reference.md).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Spec source** | Jira Task + Sub-tasks + `PLAN.md` / linked specs |
| **Branch naming** | `<jira-key-lowercase>-<short-description>` |
| **Delivery** | PR (default) or branch-only |
| **Verification** | Tests, lint, plan checklist, sub-task completion |

## Modes

| Mode | When | Behavior |
|------|------|----------|
| **Build** (default) | Task is To Do / In Progress; plan + packages define work | Full implementation loop |
| **Fix-forward** | After **review** with blocking findings; same Task + open PR | Address review threads only; no new scope |

Detect fix-forward when: user says so, or ticket is **In Review** / recently reviewed and the invoke mentions review findings / "address review".

## Jira ticket (required)

Obtain the pipeline **Task** (or Story) key:

1. User provides key (e.g. `SW-200`) in the invoke message
2. User points to a ticket URL
3. **Ask** — one question: "Which Jira ticket should this implementation track?"

Fetch the ticket and **Sub-tasks** per [../jira/reference.md](../jira/reference.md). Prefer tickets that already have a **design** plan (`PLAN.md` in description/attachment or repo).

Do not invent requirements beyond the ticket and linked specs.

### Specification priority

1. Fix-forward: open PR review comments / requested changes
2. Jira sub-task descriptions (work packages)
3. Parent ticket description
4. Repo files referenced in ticket (`PLAN.md`, `MODEL.md`, …)
5. User paste in the current message

## Jira status (manager agent)

| When | Action |
|------|--------|
| Session start (build) | Transition parent to **In Progress** |
| Session start (fix-forward) | **In Progress** if needed to reflect active work; keep PR open |
| Each sub-task started | Transition sub-task to **In Progress** (if separate states exist) |
| Sub-task done | Transition sub-task to **Done**; comment with brief summary |
| PR opened / ready for review | Transition parent to **In Review** |
| User asks to finish without PR | Comment status; leave **In Progress** unless user specifies otherwise |

Comment on the parent ticket when: session starts, each major package completes, PR is opened or updated (include PR URL), and always include **Next**.

## Pre-work

1. Resolve Jira ticket and sub-tasks (and PR + review threads if fix-forward)
2. Transition parent to **In Progress** as needed
3. Ask (one question): **open a PR** or **stop at a feature branch**? Default PR. Skip if fix-forward (PR already exists).
4. Create branch: `<jira-key-lowercase>-<short-description>` (build only; fix-forward uses the existing PR branch)

## Work package types

| Type | Subagent |
|------|----------|
| Structure exploration | `explore` |
| Research | `generalPurpose` |
| Implementation | `generalPurpose` |
| Testing | `generalPurpose` |
| Review | `bugbot`, `security-review` |
| Fix-forward | `generalPurpose` (one package per review thread or grouped finding) |

Map packages to Jira sub-tasks by summary or description. Update sub-task status as each package completes.

## PR template

- Summary (from ticket + what was built)
- `Jira: <url>`
- Spec references (`PLAN.md`, …)
- Test plan
- List of completed sub-tasks (or review threads addressed)

After PR creation or update: transition parent to **In Review**; Jira comment with PR link and **Next**.

## Handoff

```markdown
## Next
`/review <TASK-KEY>` — Standards + Spec review on the PR
```

## Flow

1. Resolve Jira ticket + spec (plan or review findings)
2. **In Progress** on parent
3. Delivery clarification (PR vs branch) — build mode
4. Create or reuse branch
5. Delegate work packages ↔ sub-tasks / review threads; update Jira as you go
6. Verify → PR → **In Review** on parent → **Next** `/review`

## Examples

User: `/implement` SW-200

Agent: [Fetches SW-200 and sub-tasks, loads PLAN.md, transitions to In Progress, asks PR vs branch]

User: `/implement` SW-200 — address the review findings

Agent: [Fix-forward: loads PR review threads, packages fixes, pushes, returns to In Review]
