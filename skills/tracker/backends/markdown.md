# Backend: markdown

Local markdown issue tracker. **System of record** when provider is `markdown`.

## Layout

From `WORKSPACE.md` (defaults shown):

```text
docs/agents/issues/
  INDEX.md
  MD-1.md          # Story or Task
  MD-2.md
```

Key format: `<KeyPrefix>-<n>` (default `MD-1`, `MD-2`, …). Allocate the next integer by scanning the issues dir / INDEX.

## Issue file template

```markdown
# MD-2: Forecast chart

| Field | Value |
|-------|-------|
| Type | Task |
| Status | To Do |
| Parent | MD-1 |
| Children | MD-3, MD-4 |
| Artifact | PLAN.md |
| PR | |
| Created | 2026-07-22 |

## Summary
…

## Acceptance
…

## Comments

### 2026-07-22
Design approved. Next: `/implement MD-2`
```

## INDEX.md

```markdown
# Issues

| Key | Type | Title | Status | Parent | Next |
|-----|------|-------|--------|--------|------|
| MD-1 | Story | Forecasting | To Do | | `/define MD-2` |
| MD-2 | Task | Forecast chart | To Do | MD-1 | `/define MD-2` |
```

Keep INDEX in sync on every create/transition/handoff. The continuity mirror
(`docs/agents/ISSUES.md`) may duplicate this; if both paths are the same file,
maintain one table only.

## Operations

| Op | How |
|----|-----|
| `fetch` | Read `issues/<KEY>.md` + INDEX row |
| `create` | Write new file; add INDEX row; return key |
| `update` | Edit fields / sections in the issue file |
| `comment` | Append under `## Comments` with date heading |
| `transition` | Set Status field; update INDEX |
| `link` | Set Parent / Children fields on both issues |
| `attach_or_link` | Set Artifact field to repo-relative path (+ SHA in Comments) |

## Types

Use logical types in the Type field: `Story`, `Task`, `Sub-task`.
Sub-tasks are normal issue files with `Type: Sub-task` and `Parent: <Task>`.

## Statuses

Use exact logical names: `To Do`, `In Progress`, `In Review`, `Done`.

## No remote auth

Markdown backend needs no credentials. Commit issue file updates with the
session's other artifact commits unless the user asks to leave them unstaged.
