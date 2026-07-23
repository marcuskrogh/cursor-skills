---
name: implement
description: >-
  Managed sub-agent implementation against a pipeline Task and Sub-tasks from
  define. Moves the issue In Progress then In Review; supports fix-forward after
  review. Persists Next in markdown and the configured tracker.
---

# Implement

Applies [CONCEPT_IMPLEMENTATION](../concepts/CONCEPT_IMPLEMENTATION.md) to the
**current repository** on the main pipeline Task.

**On invoke:** read [../concepts/CONCEPT_IMPLEMENTATION.md](../concepts/CONCEPT_IMPLEMENTATION.md),
[../workflow/reference.md](../workflow/reference.md), and
[../tracker/SKILL.md](../tracker/SKILL.md).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Spec source** | Tracker Task + Sub-tasks + `PLAN.md` or `BUG.md` / linked specs |
| **Branch naming** | From WORKSPACE (default `<key-lowercase>-<short-description>`) |
| **Delivery** | PR (default from WORKSPACE) or branch-only |
| **Verification** | Tests, lint, plan checklist, sub-task completion |

## Modes

| Mode | When | Behavior |
|------|------|----------|
| **Build** (default) | Task To Do / In Progress | Full implementation loop |
| **Fix-forward** | After **review** with blockers; same Task + open PR | Address review threads only |

Post-merge follow-ups on already-shipped work use **`/iterate`** (new Task + new PR),
not fix-forward.

## Issue (required)

1. User provides key / URL
2. Or ask once: "Which issue should this implementation track?"

`fetch` Task + Sub-tasks. Prefer Tasks that already have a definition plan.

### Specification priority

1. Fix-forward: open PR review comments
2. Sub-task descriptions
3. Task description
4. `PLAN.md` or `BUG.md` / linked specs
5. User paste

## Status (tracker — mandatory)

| When | Action |
|------|--------|
| Start (build) | Task → **In Progress**; comment session start |
| Each Sub-task started | that Sub-task → **In Progress** |
| Sub-task package done | that Sub-task → **Done** + comment |
| PR ready | Task → **In Review** + comment with PR URL + **Next** `/review-fix` |
| Start (fix-forward) | Task → **In Progress** if needed; keep PR |
| Fix-forward complete | Task → **In Review** + comment + **Next** `/review-fix` (or `/review`) |

Upsert ISSUES mirror on **every** transition/handoff. Do **not** mark the parent Task **Done** (that is **ship**).

### Tracker duties

| Action | Required |
|--------|----------|
| Task In Progress → In Review | yes |
| Sub-tasks In Progress → Done as completed | yes |
| PR link on Task | yes |
| Close parent Task | **no** |

## Pre-work

1. Resolve issue + packages (or review threads)
2. Status → In Progress
3. Ask PR vs branch once (skip if fix-forward / WORKSPACE default is enough and user already chose)
4. Create or reuse branch per WORKSPACE pattern

## Work packages

| Type | Subagent |
|------|----------|
| Structure exploration | `explore` |
| Research / Implementation / Testing | `generalPurpose` |
| Fix-forward | `generalPurpose` per review thread or grouped finding |

## PR template

- Summary
- Tracker: `<url or key>`
- Spec references (`PLAN.md` or `BUG.md`, …)
- Test plan
- Completed sub-tasks / review threads

## Handoff

```markdown
## Next
`/review-fix <TASK-KEY>` — Review and auto-fix until clean
```

(Use `/review <TASK-KEY>` for a one-shot review without auto-fix.)

## Flow

1. Resolve issue + spec
2. In Progress
3. Branch + packages
4. Verify → PR → In Review → **Next** `/review-fix`
