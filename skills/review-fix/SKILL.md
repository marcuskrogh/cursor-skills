---
name: review-fix
description: >-
  Derived review loop: run Standards+Spec review, automatically fix-forward hard
  findings via implement, and re-review until clean (or max iterations). Hands off
  to ship when clean. Use instead of manually alternating /review and /implement.
---

# Review-fix

Automates the **review ↔ implement (fix-forward)** loop on one pipeline Task and PR.

Composes [review](../review/SKILL.md) and [implement](../implement/SKILL.md) fix-forward
mode. Does **not** replace first-time **implement** (build) or **ship**.

**On invoke:** read [../workflow/reference.md](../workflow/reference.md),
[../review/SKILL.md](../review/SKILL.md), [../implement/SKILL.md](../implement/SKILL.md),
and [../tracker/SKILL.md](../tracker/SKILL.md).

## When to use

- After `/implement <KEY>` when you want review + fixes without manual ping-pong
- Instead of `/review` → `/implement` → `/review` …

Use plain `/review` when you only want findings posted, with no auto-fix.

## Inputs

1. Issue key/URL (`/review-fix MD-5`) — same resolution as review
2. Optional: `max_iterations` (default **3**) — hard stops after this many review passes that still have blockers
3. Optional: user override to stop early

Requires authenticated `gh` + tracker auth. Task should be **In Review** (or become so after the first review publish / existing PR).

## Loop

```text
iteration = 1
loop:
  1. Run full /review process for <KEY> (publish on PR + tracker comment)
  2. If no blocking findings → break CLEAN
  3. If iteration >= max_iterations → break STOPPED
  4. If finding count did not improve vs previous iteration → break STALLED
  5. Run /implement fix-forward for <KEY> (address open review threads only)
  6. Ensure Task → In Review; upsert ISSUES mirror
  7. iteration += 1
  8. continue
```

### Blocking findings

Treat as blockers (same as review handoff):

- Review event `REQUEST_CHANGES`, or
- Any finding that should block merge (hard documented-standard breach or missing spec requirement)

Soft `COMMENT`-only findings → treat as **CLEAN** for loop exit (same as `/review` → `/ship`).

### Fix-forward constraints

When calling implement inside the loop:

- Same Task + same PR branch
- Packages = open PR review threads / requested changes only
- No new scope beyond review + existing `PLAN.md` / `BUG.md`
- After fixes: push, Task → **In Review**, comment with iteration number

## Exits

| Exit | Condition | Next |
|------|-----------|------|
| **CLEAN** | No blockers | `/ship <KEY>` |
| **STOPPED** | Hit `max_iterations` with blockers left | Report remaining findings; Next `/implement <KEY>` or `/review <KEY>` (manual) or raise max |
| **STALLED** | Finding count not decreasing | Stop; ask user how to proceed — do not spin |

### Tracker / markdown each iteration

- After each review: Task comment + ISSUES (**In Review**, **Next** = continuing loop or ship)
- After each fix-forward: Task comment (threads addressed) + ISSUES
- On CLEAN: **Next** `/ship <KEY>` on Task + mirror

## Tell the user

When finished, only:

- Issue key/URL, PR URL
- Iterations run
- Exit reason (CLEAN / STOPPED / STALLED)
- Finding counts per iteration (one line each)
- **Next** handoff line

Do not paste full review bodies into chat (same as review).

## Examples

User: `/review-fix MD-5`

Agent: [review → 4 blockers → fix-forward → review → clean]  
Next: `/ship MD-5`

User: `/review-fix MD-5` max 2

Agent: [two dirty passes → STOPPED]  
Next: `/implement MD-5` — remaining findings, or re-run with higher max
