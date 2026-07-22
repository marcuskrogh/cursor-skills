---
name: review
description: >-
  Two-axis GitHub PR review (Standards + Spec) tied to a pipeline issue in In Review.
  Posts findings on the PR and the configured tracker; hands off to implement
  (fix-forward) or ship. Persists Next in markdown.
---

Two-axis review posted **on the GitHub pull request** and summarized on the **pipeline issue** (tracker from WORKSPACE) — not as repo files or long chat transcripts.

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the tracker issue and linked specification?

Both axes run as **parallel sub-agents**, then this skill publishes on the PR and updates the tracker (+ markdown mirror).

**On invoke:** read [../workflow/reference.md](../workflow/reference.md) and [../tracker/SKILL.md](../tracker/SKILL.md).

Requires authenticated `gh` and tracker auth per WORKSPACE. If either is missing, stop and tell the user.

## Process

### 0. Resolve the pipeline issue

A review is always tied to one tracker issue in **In Review** (or the provider equivalent).

1. User provides key or URL (e.g. `/review MD-2`, `/review SW-200`, `/review #42`).
2. If missing, ask: "Which issue is in review?"
3. `fetch` via the tracker backend.
4. Confirm status is **In Review** (or equivalent). If not, stop and tell the user to transition first.
5. Capture: key, URL, summary, description, sub-tasks, links, artifact paths (`PLAN.md`, `BUG.md`, `MODEL.md`).

The tracker issue is the **primary spec source** for the Spec axis.

### 1. Resolve the pull request

Every review happens on a **draft or open** GitHub PR. Resolve it in this order:

1. **PR linked from the issue** — description, comments, or remote links.
2. **PR the user named** — number, URL, or branch.
3. **PR for the current branch** — `gh pr view --json number,url,state,isDraft,baseRefName,headRefOid,title,body`.
4. **Create a draft PR** — if the branch has commits pushed but no PR yet:
   ```bash
   gh pr create --draft --title "<branch or user title>" --body "WIP — automated review in progress"
   ```

If the branch has no remote or unpushed commits, push first (`git push -u origin HEAD`) then create the draft PR. If push fails, stop and report why.

Confirm the PR is `OPEN` or `DRAFT` and the diff is non-empty (`gh pr diff <number> --name-only`). An empty diff fails here — not inside sub-agents.

Capture for sub-agents:

- PR number and URL
- Base branch (`baseRefName`) and head SHA (`headRefOid`)
- `gh pr diff <number>` output (or `git diff origin/<base>...HEAD` if `gh pr diff` is too large — prefer the PR diff)
- `gh pr view <number> --json commits --jq '.commits[].messageHeadline'`

### 2. Identify the spec source

Look for the originating spec, in this order:

1. **Tracker issue** from step 0 (description, sub-tasks, artifacts).
2. **PR description** and linked GitHub issues (`gh issue view`) when relevant.
3. Issue references in commit messages on the PR branch.
4. Spec files from WORKSPACE paths or repo (`PLAN.md`, `BUG.md`, `MODEL.md`, `DOCUMENTATION.md`).
5. Path the user passed as an argument.

If nothing is found beyond the issue summary, use the issue body as spec. If empty, ask once for the spec source.

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below — a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation — and, like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

Send a single message with two `Task` tool calls. Use `subagent_type: "generalPurpose"` for both.

Ask each sub-agent to return **structured findings only** — no summary prose, no files written. Every finding is one block:

```text
axis: Standards | Spec
kind: inline | general
path: <repo-relative path>   # required for inline
line: <line number>           # required for inline — RIGHT side of the PR diff
body: <comment markdown, prefixed with **Standards** or **Spec**>
```

**Standards sub-agent prompt** — include:

- PR number, diff, and commit list from step 1.
- Standards-source files from step 3, **plus the smell baseline pasted in full**.
- Brief: "Return findings as structured blocks (format above). Per file/hunk: (a) documented-standard violations — cite file + rule; (b) baseline smells — name the smell. `kind: inline` when you can point at a specific changed line; otherwise `kind: general`. Documented breaches can be hard; smells are always judgement calls; repo standards override the baseline. Skip tooling-enforced rules. Max 12 findings, under 400 words total."

**Spec sub-agent prompt** — include:

- PR number, diff, and commit list from step 1.
- Tracker issue contents from step 0 and spec files from step 2.
- Brief: "Return findings as structured blocks (format above). The tracker issue is the authoritative spec. Cover: (a) missing/partial requirements; (b) scope creep; (c) wrong implementations. Quote the ticket or spec line in each `body`. `kind: inline` when tied to a specific changed line; otherwise `kind: general`. Max 12 findings, under 400 words total."

If the spec is missing, skip the Spec sub-agent.

### 5. Publish on the PR

Post everything on GitHub. **Do not** write review output to the repo, `.scratch/`, or long chat transcripts.

#### 5a. Build the review

1. Merge findings from both sub-agents. Keep axes separate — do not rerank across axes.
2. **Inline comments** — one per `kind: inline` finding (`path`, `line`, `body`). Line numbers must be on the **new-file (RIGHT) side** of the PR diff at `headRefOid`.
3. **Review body** — markdown with exactly these sections:

```markdown
## Standards
<general Standards findings, or "No general Standards findings.">
<count> Standards finding(s); worst: <one line or "none">

## Spec
<general Spec findings, or "No spec available." / "No general Spec findings.">
<count> Spec finding(s); worst: <one line or "none">
```

4. Choose review event:
   - `COMMENT` — default; review is feedback only.
   - `REQUEST_CHANGES` — only if a **hard** documented-standard violation or clearly missing spec requirement should block merge.
   - `APPROVE` — only if both axes have zero findings (unusual for this skill).

#### 5b. Submit via gh

Submit **one** pull request review with inline comments and the summary body:

```bash
OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
HEAD_SHA=$(gh pr view <number> --json headRefOid -q .headRefOid)

gh api "repos/${OWNER_REPO}/pulls/<number>/reviews" \
  --method POST \
  --input - <<'EOF'
{
  "commit_id": "<HEAD_SHA>",
  "event": "COMMENT",
  "body": "<review body markdown>",
  "comments": [
    { "path": "src/example.ts", "line": 42, "body": "**Standards**: ..." }
  ]
}
EOF
```

Build the JSON inline (heredoc or `jq -n`) in the shell — do not commit it to the repo. If a line number cannot be resolved, downgrade that finding to `general` in the review body instead of dropping it.

If the API rejects an inline comment (stale line, unchanged line), post that finding as a **PR conversation comment** instead:

```bash
gh pr comment <number> --body "**Standards** (could not anchor inline): ..."
```

#### 5c. Post on the tracker (+ mirror)

After the GitHub review is submitted, update the tracker (mandatory):

1. Confirm Task is still **In Review** (do not transition).
2. `comment` on the pipeline issue:

```markdown
## Code review posted
PR: <url>
Review event: COMMENT | REQUEST_CHANGES | APPROVE
Standards: <N> finding(s) — worst: …
Spec: <M> finding(s) — worst: …

[Link to PR review or copy general findings summary]

## Next
<handoff line — see Handoff below>
```

3. Upsert the markdown mirror (status **In Review**, updated **Next**).

Do **not** transition to **Done** — that is [ship](../ship/SKILL.md). Do **not** close Sub-tasks here.

#### 5d. Tell the user

Reply in chat with **only**:

- Issue key / URL
- PR URL
- One line: review posted — `<N>` Standards / `<M>` Spec findings; event `<COMMENT|REQUEST_CHANGES|APPROVE>`
- **Next** handoff line

Do not paste the full review into chat.

## Handoff

| Outcome | Next |
|---------|------|
| `REQUEST_CHANGES`, or any finding that should block merge | `/implement <KEY>` — fix-forward — **or** `/review-fix <KEY>` to auto-loop |
| `COMMENT` / `APPROVE` with no blocking findings | `/ship <KEY>` — Merge and mark Done |

Prefer telling the user about `/review-fix` when blockers exist and they have not already declined automation.

```markdown
## Next
`/implement <KEY>` — Address review findings (fix-forward)
```

or

```markdown
## Next
`/ship <KEY>` — Merge PR and close the Task
```

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately on the PR stops one axis from masking the other.
