---
name: code-review
description: >-
  Two-axis GitHub PR review — Standards (repo coding standards) and Spec
  (issue/PRD fidelity). Resolves or creates a draft/open PR, runs both axes as
  parallel sub-agents, and posts findings as PR review comments (inline + summary)
  via gh. Use when the user wants a code review, PR review, or asks to review a
  branch or work-in-progress changes.
---

Two-axis review posted **on the GitHub pull request** — not in chat, not as repo files.

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue / PRD / spec?

Both axes run as **parallel sub-agents**, then this skill publishes their findings on the PR like an integrated reviewer: inline comments on changed lines where possible, plus a single review summary on the PR conversation.

Requires the `gh` CLI, authenticated for the repo (`gh auth status`). If `gh` is missing or unauthenticated, stop and tell the user.

## Process

### 1. Resolve the pull request

Every review happens on a **draft or open** GitHub PR. Resolve it in this order:

1. **PR the user named** — number, URL, or branch (e.g. `review PR 42`, `review https://github.com/org/repo/pull/42`).
2. **PR for the current branch** — `gh pr view --json number,url,state,isDraft,baseRefName,headRefOid,title,body`.
3. **Create a draft PR** — if the branch has commits pushed but no PR yet:
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

1. **PR description** (`gh pr view <number> --json body`) and linked issues (`Closes #45`, `Fixes org/repo#123`) — fetch issues with `gh issue view`.
2. Issue references in commit messages on the PR branch.
3. A path the user passed as an argument.
4. A PRD/spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
5. If nothing is found, ask the user where the spec is. If they say there isn't one, skip the Spec sub-agent.

If `docs/agents/issue-tracker.md` exists, use its workflow for non-GitHub trackers; otherwise default to `gh issue view`.

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
- Spec path or fetched contents from step 2.
- Brief: "Return findings as structured blocks (format above). Cover: (a) missing/partial requirements; (b) scope creep; (c) wrong implementations. Quote the spec line in each `body`. `kind: inline` when tied to a specific changed line; otherwise `kind: general`. Max 12 findings, under 400 words total."

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

#### 5c. Tell the user

Reply in chat with **only**:

- PR URL
- One line: review posted — `<N>` Standards / `<M>` Spec findings; event `<COMMENT|REQUEST_CHANGES|APPROVE>`

Do not paste the full review into chat.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately on the PR stops one axis from masking the other.
