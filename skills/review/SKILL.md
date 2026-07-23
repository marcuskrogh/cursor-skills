---
name: review
description: >-
  Thorough multi-axis GitHub PR review (Spec, Correctness, Integration, Standards)
  with vertical and horizontal investigation. Tied to a pipeline issue in In Review;
  posts findings on the PR and tracker; hands off to review-fix or ship.
---

# Review

Applies [CONCEPT_REVIEW](../concepts/CONCEPT_REVIEW.md) as a deep review posted
**on the GitHub pull request** and summarized on the **pipeline issue** (tracker
from WORKSPACE) — not as repo files or long chat transcripts.

**On invoke:** read [../concepts/CONCEPT_REVIEW.md](../concepts/CONCEPT_REVIEW.md),
[../workflow/reference.md](../workflow/reference.md), [checklist.md](checklist.md),
and [../tracker/SKILL.md](../tracker/SKILL.md).

Requires authenticated `gh` and tracker auth per WORKSPACE. If either is missing,
stop and tell the user.

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Change source** | GitHub PR linked to the pipeline Task (or current branch) |
| **Spec source** | Tracker issue + `PLAN.md` / `BUG.md` / `ITERATE.md` / `MODEL.md` |
| **Publish target** | GitHub PR review via `gh api` + tracker comment |
| **Checklist** | [checklist.md](checklist.md) — paste into each sub-agent brief |

## Axes (this skill)

Four axes run as **parallel sub-agents**. Each axis investigates both **vertically**
and **horizontally** per CONCEPT_REVIEW:

| Axis | Focus |
|------|--------|
| **Spec** | Does the change fulfill `PLAN.md` / `BUG.md` / `ITERATE.md` / the tracker issue — no missing or wrong behaviour? |
| **Correctness** | Will it work under real inputs and failures — logic, edges, errors, races, tests? |
| **Integration** | Does it fit the rest of the system — callers, contracts, auth, data flow, config? |
| **Standards** | Repo conventions + smell baseline (judgement calls; repo docs win). |

## Process

### 0. Resolve the pipeline issue

1. User provides key or URL (e.g. `/review MD-2`).
2. If missing, ask: "Which issue is in review?"
3. `fetch` via the tracker backend.
4. Confirm status is **In Review** (or equivalent). If not, stop and tell the user to transition first.
5. Capture: key, URL, summary, description, sub-tasks, links, artifact paths (`PLAN.md`, `BUG.md`, `ITERATE.md`, `MODEL.md`).

The tracker issue (+ linked PLAN/BUG/ITERATE) is the **primary spec source**.

### 1. Resolve the pull request

Order: issue-linked PR → user-named PR → current branch PR → create draft PR if commits exist.

Confirm non-empty diff. Capture:

- PR number, URL, base branch, head SHA
- Full `gh pr diff` (or `git diff origin/<base>...HEAD` if too large)
- Commit list: `gh pr view <n> --json commits`

### 2. Build investigation context (mandatory — do not skip)

Sub-agents must not review hunks in isolation. The manager prepares:

1. **Changed paths** — `gh pr diff <n> --name-only`.
2. **Full file snapshots** for each changed source file at `HEAD` (cap: skip generated/vendor/minified; for huge files, provide ±100 lines around each hunk plus signatures/imports).
3. **Neighbor map** — for each changed symbol/module, list likely callers/callees/tests (ripgrep for symbol names, same-package imports, `*_test.*` / `__tests__` / neighbouring files). Include those file excerpts when they clarify contracts.
4. **Spec pack** — issue body, sub-tasks, `PLAN.md` / `BUG.md` / `ITERATE.md` / `MODEL.md` as applicable.
5. **Standards pack** — `CODING_STANDARDS.md`, `CONTRIBUTING.md`, linters config names if present.
6. **Evidence from tooling** (when cheap and available in-repo): run the project's usual lint/typecheck/test for the touched area (or full suite if that is the norm). Capture failing command output as **Correctness** inputs — do not invent CI results.

Pass this context into every sub-agent brief.

### 3. Identify axes sources

**Spec:** tracker issue → PR body → commit refs → PLAN/BUG/ITERATE/MODEL → user path.

**Standards:** repo docs + smell baseline in [checklist.md](checklist.md#standards-smell-baseline). Repo docs override smells; skip tooling-enforced nits.

**Correctness / Integration:** checklists in [checklist.md](checklist.md).

### 4. Spawn four sub-agents in parallel

One message, four `Task` calls (`subagent_type: "generalPurpose"`).

Each returns **structured findings only**:

```text
axis: Spec | Correctness | Integration | Standards
severity: blocker | should-fix | note
kind: inline | general
path: <repo-relative>     # inline
line: <RIGHT-side line>   # inline
vertical_or_horizontal: vertical | horizontal
body: <markdown: problem → evidence → suggested fix; prefix with **Axis**>
```

Use CONCEPT_REVIEW severity meanings. **Budgets:** max **20** findings per axis,
**≤800 words** per axis. Prefer fewer high-severity findings over many notes. Every
finding needs **evidence** and a **concrete fix hint**.

#### Spec sub-agent

Include: context pack + Spec checklist from [checklist.md](checklist.md#spec).

Brief: Trace **each** acceptance criterion / work package / bug repro expectation through the diff and neighbors. Vertical: is this requirement fully implemented inside the changed paths? Horizontal: are related UI/API/docs/migrations/flags updated? Flag missing, partial, wrong, or scope-creep behaviour. Quote the spec line in `body`.

#### Correctness sub-agent

Include: context pack + Correctness checklist + any tooling failures.

Brief: Vertical deep-dive into changed functions/paths — logic bugs, edges, error handling, null/empty, off-by-one, resource lifecycle, concurrency, idempotency. Horizontal: do tests cover new behaviour and failure paths; do existing tests still match contracts? Prefer `blocker`/`should-fix` for real failure modes.

#### Integration sub-agent

Include: context pack + Integration checklist + neighbor map.

Brief: Horizontal first — call graph, API/schema compatibility, authz (vertical *and* horizontal privilege), shared state, config/env, feature flags, data migrations, event contracts, error propagation across boundaries. Vertical: at each boundary crossed by the change, validate assumptions. Read neighbor files; do not stop at the hunk.

#### Standards sub-agent

Include: standards pack + smell baseline.

Brief: Documented standard breaches (can be `blocker`/`should-fix`) and baseline smells (`note` unless severe). Name the smell. Repo overrides baseline. Skip tooling-enforced style.

If the spec pack is empty, skip Spec but still run the other three; ask the user once if everything is empty of intent.

### 5. Publish on the PR

Do **not** write review output into the repo or paste the full review in chat.

#### 5a. Build the review

1. Merge findings; keep axes separate — do not drop an axis because another is clean.
2. Deduplicate near-identical findings (keep the higher severity / better evidence).
3. Inline comments for `kind: inline` at RIGHT-side lines on `headRefOid`.
4. Review body:

```markdown
## Summary
- Blockers: <n> | Should-fix: <n> | Notes: <n>
- Vertical themes: <one line>
- Horizontal themes: <one line>
- Worst: <one line or "none">

## Spec
…

## Correctness
…

## Integration
…

## Standards
…
```

Under each axis: general findings (or "None."), then counts by severity.

5. Review event:
   - `REQUEST_CHANGES` — any `blocker` or `should-fix`
   - `COMMENT` — only `note`s, or no findings
   - `APPROVE` — zero findings on all axes (rare)

#### 5b. Submit via gh

One PR review via `gh api` (same pattern as before: `commit_id`, `event`, `body`, `comments[]`). Build JSON in the shell; never commit it. Unanchorable inlines → PR conversation comment with axis prefix.

#### 5c. Tracker + mirror

Comment on the pipeline issue:

```markdown
## Code review posted
PR: <url>
Review event: …
Blockers: <n> | Should-fix: <n> | Notes: <n>
Spec / Correctness / Integration / Standards: <counts>
Worst: …

## Next
<handoff>
```

Keep Task **In Review**. Upsert ISSUES mirror. Do not mark Done or close Sub-tasks.

#### 5d. Tell the user

Only: issue key/URL, PR URL, one-line counts + event, **Next**. No full review dump.

## Handoff

| Outcome | Next |
|---------|------|
| Any `blocker` or `should-fix` | `/review-fix <KEY>` (preferred) or `/implement <KEY>` fix-forward |
| Only `note`s or zero findings | `/ship <KEY>` |

```markdown
## Next
`/review-fix <KEY>` — Auto-fix blockers and re-review
```

or

```markdown
## Next
`/ship <KEY>` — Merge PR and close the Task
```
