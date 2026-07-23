# Main workflow reference

Agent reference for the primary delivery pipeline. **Not a user-invoked skill.**

## Prerequisites

1. Read `docs/agents/WORKSPACE.md` (see [../setup/format.md](../setup/format.md)).
2. If missing → ask the user to run `/setup` (or accept defaults and write WORKSPACE.md first).
3. Resolve the issue tracker via [../tracker/SKILL.md](../tracker/SKILL.md).

## Pipeline

### Feature workflow

```text
setup (once per repo)
   ↓
explore  →  define  →  implement  →  review-fix  →  ship
   │           │            │              │               │
 ROADMAP.md  PLAN.md     branch+PR    review↔fix loop   merge+Done
 Story+Tasks  same Task   same Task      same Task        same Task
               ↑
        research / model   (optional side paths on the same Task)
```

(`/review` remains available for a one-shot review without auto-fix.)

### Bug fix workflow

```text
setup (once per repo)
   ↓
bug  →  implement  →  review-fix  →  ship
 │          │              │               │
BUG.md   branch+PR    review↔fix loop   merge+Done
 Task     same Task      same Task        same Task
```

**`/bug` replaces explore + define** for defects: one short alignment → `BUG.md` + one
Task → same delivery loop. Use **explore/define** when the change is a feature or
needs product/definition decisions; use **bug** when behaviour is wrong and the fix is
the work.

### Side paths (same Task + shared markdown)

| Skill | Artifact | When | Continuity updates |
|-------|----------|------|--------------------|
| **research** | `RESEARCH.md` | Literature before define/model | Task link, ROADMAP/PLAN notes, ISSUES mirror, **Next** |
| **model** | `MODEL.md` | Math spec before/with define | Task link (prefer enrich, no parallel Task), ROADMAP/PLAN/RESEARCH links, ISSUES mirror, **Next** |
| **summarise** | *(read-only)* | Anytime (feature or bug Task) | Reports About / Stage / **Next** from the above |

Typical feature inserts:

```text
… → /research <Task> → /model <Task> → /define <Task> → …
… → /research <Task> → /define <Task> → …
… → /model <Task> → /implement <Task> → …   (if PLAN already exists)
```

Bug path (no inserts required):

```text
/bug → /implement <Task> → /review-fix <Task> → /ship <Task>
```

### Review-fix loop

Prefer **`/review-fix`** after implement to avoid manual review↔implement iteration:

```text
review → (blockers?) → implement fix-forward → review → … → clean → /ship
```

Plain **`/review`** only posts findings and hands off; you then run `/implement` yourself.
## Markdown continuity

**Decisions and handoffs always live in markdown**, even when the tracker is Jira,
GitHub, or Linear:

| File | Role |
|------|------|
| `docs/agents/WORKSPACE.md` | Tracker + path + delivery decisions (`/setup`) |
| `ROADMAP.md` | Initiative + phases + keys + **Next** (features) |
| `PLAN.md` | Definition / plan + keys + **Next** (features) |
| `BUG.md` | Bug report + acceptance + **Next** (bug fixes) |
| `RESEARCH.md` | Literature brief + Task link + **Next** |
| `MODEL.md` | Math spec + Task link + **Next** |
| `docs/agents/ISSUES.md` | Mirror table (when enabled in WORKSPACE) |
| Provider issue (remote or `docs/agents/issues/*.md`) | Work-item system of record for that provider |

Never leave **Next** only in chat. Side-path skills must update the same Task’s
continuity files — not a disconnected second ticket — when a pipeline key is given.

## One issue continuity

**One Task owns work from ready-to-build through ship** (provider-native key).

| Stage | Ticket action |
|-------|----------------|
| **explore** | Create **Story** + one **Task** per roadmap phase. Tasks are define-ready placeholders. |
| **bug** | Create one **Task** (+ optional Sub-tasks) from `BUG.md`. No Story unless requested. |
| **define** | Take an explore **Task**. Enrich *that* issue (description, `PLAN.md`, Sub-tasks). Do **not** create a parallel definition ticket when an explore Task is the subject. |
| **implement** | Work the **same Task** (and its Sub-tasks). Spec from `PLAN.md` or `BUG.md`. Branch + PR; move to **In Review**. |
| **review** | One-shot Standards + Spec review; may hand off to fix-forward manually. |
| **review-fix** | Review → fix-forward → re-review until clean (or max iterations); then ship. |
| **ship** | Merge PR; close all open **Sub-tasks** → **Done**; Task → **Done**; Story → **Done** only when every child Task is Done; sync ISSUES + ROADMAP. |

### Standalone entry

| Entry | Behavior |
|-------|----------|
| `/bug` | Create Task from bug alignment; Next `/implement`. |
| `/define` with no prior explore Task | Create a new Task (+ Sub-tasks) as the pipeline owner. |
| `/implement` with an issue that already has PLAN or BUG | Allowed. |
| Skip **define** on features | Only when already implementation-ready. Prefer define for non-trivial features. |

### Linking

- Explore Tasks → parent Story via provider parent/relates.
- Bug Tasks are usually standalone; may **Relates** to a Story/Task if they block a phase.
- Define/implement/review/ship comments stay on the **same Task**.
- Comment on the parent Story at define completion and at ship (phase Done).

## Artifacts

| Artifact | Owner skill | Role |
|----------|-------------|------|
| `WORKSPACE.md` | setup | Tracker and path decisions |
| `ROADMAP.md` | explore | Project/feature scope and phase list |
| `BUG.md` | bug | Defect report + acceptance for implement/review |
| `RESEARCH.md` | research | Literature brief for a phase/Task |
| `MODEL.md` | model | Mathematical specification |
| `PLAN.md` | define | Spec for implement + Spec-axis review |
| Branch + PR | implement | Delivery vehicle |
| PR review | review / review-fix | Standards + Spec findings (+ auto fix-forward in review-fix) |
| Merge + Done | ship | Closeout |
| *(status reply)* | summarise | About / stage / Next |

Use paths from `WORKSPACE.md`. Record path + commit SHA on the Task when writing artifacts.

## Handoff protocol

Every pipeline skill **ends** by telling the user the next invoke:

```markdown
## Next
`/<skill> <ISSUE-KEY>` — <one-line why>
```

| After | Next (default) |
|-------|----------------|
| setup | `/explore` or `/bug` (depending on intent) |
| explore | `/define <first-priority-Task>` (or `/research` / `/model` if needed first) |
| bug | `/implement <Task>` |
| research | `/model <Task>` or `/define <Task>` |
| model | `/define <Task>` or `/implement <Task>` if plan exists |
| define | `/implement <Task>` |
| implement | `/review-fix <Task>` (preferred) or `/review <Task>` |
| review (blocking findings / `REQUEST_CHANGES`) | `/implement <Task>` (fix-forward) — or use `/review-fix` to automate |
| review (no blockers) | `/ship <Task>` |
| review-fix (CLEAN) | `/ship <Task>` |
| review-fix (STOPPED / STALLED) | `/implement <Task>` or `/review <Task>` (manual) or re-run with higher max |
| ship | Done — no next skill (or next phase / next bug) |
| summarise | *(reports Next; does not advance)* |

Also write **Next** into: the issue comment (or markdown Comments section), the
alignment artifact, and the ISSUES mirror when enabled.

### Entry context

| Skill | Load |
|-------|------|
| bug | Existing related Task/Story if linked; codebase pointers from user only |
| research / model | Task (+ Story), `ROADMAP.md`, sibling artifacts (`RESEARCH.md` / `MODEL.md` / `PLAN.md`) |
| define | Task (+ parent Story), `ROADMAP.md`, `RESEARCH.md` / `MODEL.md` if present |
| implement | Task + Sub-tasks, `PLAN.md` or `BUG.md` / `MODEL.md` / linked specs |
| review / review-fix | Task + PR + `PLAN.md` or `BUG.md` / specs |
| ship | Task + PR + latest review outcome |
| summarise | Task + all of the above for stage inference |

## Status chain

```text
To Do / Backlog  →  In Progress  →  In Review  →  Done
     explore/define      implement        implement     ship
     research/model                       review
     bug
```

## Tracker sync matrix (mandatory)

Every pipeline skill **must** update the configured tracker (and markdown mirror when
enabled). Chat-only status is not enough.

| Skill | Create / update issues | Status transitions | Comments / links | Close |
|-------|------------------------|--------------------|------------------|-------|
| **explore** | Create Story + Task per phase; link children → Story | Leave Story/Tasks **To Do** | Story comment: child keys + **Next**; upsert ISSUES | — |
| **bug** | Create Task (+ optional Sub-tasks); link BUG.md | Leave **To Do** | Task comment: BUG.md + **Next**; ISSUES | — |
| **research** | Enrich pipeline Task (artifact link); no new Task if key given | Leave Task status unchanged (usually **To Do**) | Task comment: RESEARCH.md + summary + **Next**; ROADMAP/PLAN/ISSUES | — |
| **model** | Enrich pipeline Task (preferred); else create Task | Leave **To Do** unless already further along | Task comment: MODEL.md + **Next**; ROADMAP/PLAN/RESEARCH/ISSUES | — |
| **define** | Enrich Task; create Sub-tasks per work package | Task stays **To Do** (ready to implement) | Task + Story comments: PLAN.md, sub-task keys, **Next**; ISSUES | — |
| **implement** | May add missing Sub-tasks if plan/bug requires | Task → **In Progress** at start; each Sub-task → **In Progress** then **Done** when finished; Task → **In Review** when PR ready | Comments on Task (session start, packages, PR URL + **Next** `/review-fix`); ISSUES | Sub-tasks **Done** as packages complete — not the parent Task |
| **implement** (fix-forward) | — | Task → **In Progress** if needed, then **In Review** again | Comment: threads addressed + **Next** `/review` or continue inside `/review-fix`; ISSUES | — |
| **review** | — | Must already be **In Review**; do **not** change to Done | Task comment: review summary + **Next**; ISSUES | — |
| **review-fix** | — | Alternates review publish + fix-forward status as above each iteration | Comment each iteration; ISSUES | — (ship closes) |
| **ship** | — | See [Ship closeout](#ship-closeout) | Task + Story comments; ROADMAP + ISSUES | **Yes** — close Task, remaining Sub-tasks, and Story when complete |
| **summarise** | — | Read-only (may fix stale mirror **Next** text only) | — | — |

### Rules

1. **Always** `comment` (or markdown Comments) with **Next** when a skill finishes.
2. **Always** upsert `docs/agents/ISSUES.md` when mirror is enabled — same status as the tracker.
3. Provider backends implement `transition` / close natively (Jira Done, GitHub `gh issue close`, Linear Done, markdown Status field).
4. Never mark the **pipeline Task** **Done** before **ship**.
5. Never leave Sub-tasks open after **ship**.

## Ship closeout

After a successful merge (or confirmed already-merged PR), **ship** closes tracker work in this order:

1. **Sub-tasks** — `transition` every still-open child of the Task → **Done** (comment each or one batch comment on the parent listing them).
2. **Task** — `transition` → **Done**; comment with PR URL, merge SHA, list of closed Sub-tasks, **Next: Done**.
3. **Story** (if linked):
   - Comment that this phase Task is Done (key + PR).
   - If **all** child Tasks of the Story are **Done**, `transition` Story → **Done** and comment "Initiative complete".
   - Otherwise leave Story open; set Story **Next** hint to `/define <next-open-Task>` or `/summarise <Story>`.
4. **Markdown** — upsert ISSUES mirror (Task/Sub-tasks/Story statuses); update `ROADMAP.md` phase row to Done + PR link; sync markdown `INDEX.md` if provider is markdown.
5. **Stop** if merge failed — do not close anything.

## Fix-forward

When **review** leaves blocking findings and you are **not** using **review-fix**:

1. Next skill is **implement** on the same Task (not a new issue).
2. Implement treats open PR review threads as the work packages.
3. Do not invent new scope beyond the review + existing plan/bug.
4. Re-open or keep the PR; return Task to **In Review** when ready (tracker + mirror).
5. User runs **review** again, then **ship**.

Prefer **`/review-fix <KEY>`** to run steps 1–5 automatically until clean (see that skill for max-iteration / stall guards).

## Anti-patterns

- Creating issues before `WORKSPACE.md` exists (run `/setup` first)
- Hardcoding Jira (or any single provider) when WORKSPACE selects another
- Creating a second Task in define when an explore Task was provided
- Ending a pipeline skill without tracker comment + **Next** (+ mirror)
- Marking **Done** from implement or review (that is **ship**)
- Shipping while Sub-tasks remain open
- Closing the Story while sibling phase Tasks are still open
- Leaving continuity only in chat or only in a remote tracker with mirror enabled but skipped
