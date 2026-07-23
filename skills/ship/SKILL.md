---
name: ship
description: >-
  Close out a pipeline Task after a successful review: merge the PR, close all
  open Sub-tasks, mark the Task Done, close the parent Story when every phase
  Task is Done, and sync the markdown mirror. Use when a clean review should finish.
---

# Ship

Final step after [review](../review/SKILL.md). Closes tracker work for the
**pipeline Task** (and related issues) per
[../workflow/reference.md](../workflow/reference.md) **Ship closeout**.

**On invoke:** read [../workflow/reference.md](../workflow/reference.md) and
[../tracker/SKILL.md](../tracker/SKILL.md).

## Prerequisites

Authenticated `gh` plus tracker auth for the WORKSPACE provider.

## Process

### 0. Resolve issue

1. User key/URL or ask once.
2. `fetch` Task + children (Sub-tasks) + parent Story if linked.
3. Prefer status **In Review**. If already **Done**, report and stop (still verify Sub-tasks/Story if user asks to repair closeout).

### 1. Resolve PR

Same order as review. If latest review is unresolved `REQUEST_CHANGES` without user override:

```markdown
## Next
`/implement <KEY>` — Address review findings (fix-forward)
```

Do **not** close tracker issues in that case.

### 2. Merge (or confirm)

| PR state | Action |
|----------|--------|
| Open/draft | Ready if needed; merge per WORKSPACE strategy (`gh pr merge`). On failure, **stop** — close nothing. |
| Merged | Continue closeout. |

### 3. Tracker closeout (mandatory order)

Follow [Ship closeout](../workflow/reference.md#ship-closeout). Condensed:

1. **Sub-tasks** — every child not yet **Done** → `transition` **Done**. Comment on the Task listing closed Sub-task keys.
2. **Task** → **Done**. Comment:

```markdown
## Shipped
PR: <url>
Merge: <sha or url>
Closed sub-tasks: <keys>
## Next
Done — phase closed.
```

3. **Story** (if linked):
   - Comment: phase Task `<KEY>` Done + PR URL.
   - `fetch` sibling Tasks; if **all** are **Done** → Story → **Done** + "Initiative complete".
   - Else leave Story open; comment suggested **Next** for the next open Task.
4. **Markdown continuity** — upsert ISSUES mirror for Task, Sub-tasks, Story; mark phase Done in `ROADMAP.md`; if provider is markdown, sync `issues/INDEX.md`.

### 4. Tell the user

- Task key/URL — **Done**
- Sub-tasks closed (count/keys)
- Story status (still open vs **Done**)
- PR URL
- If Story still open: **Next** hint for the following phase Task
- Optional: if the user reports the merge is still wrong → **Next** `/iterate <KEY> <description>`

No skill handoff when the Task is Done; optional Next only points at the next phase
or `/iterate` when post-ship follow-up is needed.
