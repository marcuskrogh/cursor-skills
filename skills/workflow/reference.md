# Main workflow reference

Agent reference for the primary delivery pipeline. **Not a user-invoked skill.**

## Pipeline

```text
explore  →  design  →  implement  →  review  →  ship
   │           │            │              │            │
 ROADMAP.md  PLAN.md     branch+PR      PR review     merge+Done
 Story+Tasks  same Task   same Task      same Task     same Task
```

`model` and `arxiv-research` are optional side paths — they may feed a Task before
`implement`, but they are not required on this pipeline.

## One ticket continuity

**One Jira Task owns a phase from design through ship.**

| Stage | Ticket action |
|-------|----------------|
| **explore** | Create **Story** + one **Task** per roadmap phase. Tasks are design-ready placeholders. |
| **design** | Take an explore **Task**. Enrich *that* ticket (description, `PLAN.md`, Sub-tasks). Do **not** create a parallel design ticket when an explore Task is the subject. |
| **implement** | Work the **same Task** (and its Sub-tasks). Branch + PR; move to **In Review**. |
| **review** | Review the PR for that Task while it is **In Review**. |
| **ship** | Merge (or confirm merge), transition Task to **Done**, close the loop on the Story. |

### Standalone entry

| Entry | Behavior |
|-------|----------|
| `/design` with no prior explore Task | Create a new Task (+ Sub-tasks) as the pipeline owner. |
| `/implement` with a ticket that already has a plan | Allowed — design may have been done offline. |
| Skip **design** | Only when the Task is already implementation-ready (acceptance + packages clear). Prefer design for non-trivial phases. |

### Linking

- Explore Tasks → parent Story via `parent` or **Relates**.
- Design/implement/review/ship comments stay on the **same Task**.
- Comment on the parent Story at design start (plan ready) and at ship (phase Done).

## Artifacts

| Artifact | Owner skill | Role |
|----------|-------------|------|
| `ROADMAP.md` | explore | Project/feature scope and phase list |
| `PLAN.md` | design | Spec for implement + Spec-axis review |
| Branch + PR | implement | Delivery vehicle |
| PR review | review | Standards + Spec findings |
| Merge + Done | ship | Closeout |

Prefer repo path conventions already used by the project (`docs/`, repo root, etc.).
Record the path and commit SHA on the Jira Task when writing artifacts.

## Handoff protocol

Every pipeline skill **ends** by telling the user the next invoke, using this shape:

```markdown
## Next
`/<skill> <TICKET-KEY>` — <one-line why>
```

| After | Next (default) |
|-------|----------------|
| explore | `/design <first-priority-Task>` |
| design | `/implement <Task>` |
| implement | `/review <Task>` |
| review (blocking findings / `REQUEST_CHANGES`) | `/implement <Task>` (fix-forward) |
| review (no blockers) | `/ship <Task>` |
| ship | Done — no next skill |

Also write the **Next** line into the Jira comment for that session so the handoff
survives across chats.

### Entry context

Before the first substantive action, load prior pipeline context when a ticket key is given:

| Skill | Load |
|-------|------|
| design | Task (+ parent Story), `ROADMAP.md` if present |
| implement | Task + Sub-tasks, `PLAN.md` / linked specs |
| review | Task + PR + `PLAN.md` / specs |
| ship | Task + PR + latest review outcome |

## Status chain

```text
To Do / Backlog  →  In Progress  →  In Review  →  Done
     explore/design      implement        implement     ship
                                         review
```

| Skill | Status duty |
|-------|-------------|
| explore / design | Leave new/enriched Tasks in **To Do** (or project default). |
| implement | **In Progress** at start; **In Review** when PR is ready. |
| implement (fix-forward) | May return briefly to **In Progress**, then **In Review** again. |
| review | Requires **In Review**; does not transition to Done. |
| ship | **Done** on the Task after successful closeout. |

## Fix-forward

When **review** leaves blocking findings:

1. Next skill is **implement** on the same Task (not a new ticket).
2. Implement treats open PR review threads as the work packages.
3. Do not invent new scope beyond the review + existing plan.
4. Re-open or keep the PR; return Task to **In Review** when ready.
5. User runs **review** again, then **ship**.

## Anti-patterns

- Creating a second Task in design when an explore Task was provided
- Ending a pipeline skill without a **Next** handoff
- Marking **Done** from implement or review (that is **ship**)
- Implementing without a usable plan on non-trivial work
- Skipping ticket keys in handoff lines ("Next: /implement" with no key)
