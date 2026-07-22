---
name: ship
description: >-
  Close out a Jira Task after a successful review: confirm the PR is ready,
  merge (or record merge), transition the ticket to Done, and hand off nothing.
  Use when a ticket in In Review has a clean review and should be finished.
---

# Ship

Final step of the main pipeline after [review](../review/SKILL.md).
Closes the **same Jira Task** that flowed through design → implement → review.

**On invoke:** read [../workflow/reference.md](../workflow/reference.md) and
[../jira/reference.md](../jira/reference.md).

## Prerequisites

Requires authenticated `gh` and Jira credentials. If either is missing, stop and tell the user.

## Process

### 0. Resolve the Jira ticket

1. User provides key or URL (e.g. `/ship SW-200`).
2. If missing, ask: "Which Jira ticket should be shipped?"
3. Fetch the ticket per [../jira/reference.md](../jira/reference.md).
4. Prefer status **In Review**. If still **In Progress**, confirm the PR is merge-ready before continuing. If already **Done**, report and stop.

### 1. Resolve the pull request

Same order as review: Jira link → user-named PR → current branch PR.

Confirm:

- PR exists and is `OPEN` or already `MERGED`
- Latest review is not an unresolved `REQUEST_CHANGES` (unless the user explicitly overrides)

If `REQUEST_CHANGES` is still the latest review event and the user did not override, stop and point them to:

```markdown
## Next
`/implement <KEY>` — Address review findings (fix-forward)
```

### 2. Merge (or confirm)

| PR state | Action |
|----------|--------|
| `OPEN` / `DRAFT` | Convert draft to ready if needed; merge with `gh pr merge <n> --merge` (or `--squash` if the repo standard is squash). If merge is blocked (checks, permissions), report blockers and stop — do **not** mark Done. |
| Already `MERGED` | Skip merge; continue closeout. |

Do not delete the branch unless the repo/user normally does so (`gh pr merge` flags or follow-up `git push origin --delete`).

### 3. Jira closeout

1. Transition the Task to **Done**.
2. Comment on the Task:

```markdown
## Shipped
PR: <url>
Merge: <sha or merge commit url>
Summary: <one line>

## Next
Done — phase closed.
```

3. If the Task links to an explore **Story**, comment on the Story that this phase Task is Done (include Task key + PR URL).
4. Optionally update `ROADMAP.md` phase notes with Done + PR link when the file exists and the change is trivial.

### 4. Tell the user

Reply with only:

- Jira Task URL
- PR URL
- One line: shipped — Task **Done**

No further skill handoff.

## Examples

User: `/ship SW-200`

Agent: [Confirms review clean, merges PR, Done on SW-200, comments on parent Story]
