# Issue tracker contract

Logical operations used by pipeline skills. **Not a user-invoked skill.**

Provider and paths come from `docs/agents/WORKSPACE.md` ([../setup/format.md](../setup/format.md)).
Backend files implement these operations.

## Logical issue types

| Logical type | Role in pipeline |
|--------------|------------------|
| **Story** | Explore parent — holds phases |
| **Task** | Pipeline owner from design → ship (one Task per phase) |
| **Sub-task** | Work package under a Task |

Map these names to provider-native types in the backend file.

## Logical statuses

```text
To Do → In Progress → In Review → Done
```

Backends map to native columns/states. If a name is missing, pick the closest and note it in the issue comment / markdown mirror.

## Operations

Every backend must support:

| Op | Purpose |
|----|---------|
| `fetch(key)` | Load summary, description, status, type, parent, children, links |
| `create(type, fields)` | Create Story / Task / Sub-task; return key + url |
| `update(key, fields)` | Update description / title / links to artifacts |
| `comment(key, markdown)` | Add a comment (or append a Comments section in markdown) |
| `transition(key, status)` | Move to a logical status |
| `link(parent, child, kind)` | Parent/child or relates |
| `attach_or_link(key, path)` | Attach file or record repo path + SHA in description |

## Keys in handoffs

Handoffs always use the provider's issue key:

```markdown
## Next
`/design <KEY>` — …
```

Examples: `MD-2`, `PROJ-124`, `#42`, `ENG-123`.

## Markdown continuity (all providers)

When `WORKSPACE.md` has **Mirror to markdown: true**:

1. Upsert a row in the mirror file (`docs/agents/ISSUES.md` by default):

```markdown
| Key | Type | Title | Status | Parent | Artifact | Next |
|-----|------|-------|--------|--------|----------|------|
| MD-2 | Task | Forecast chart | In Progress | MD-1 | PLAN.md | `/review MD-2` |
```

2. Append a short dated log line under `## Log` when status or Next changes.
3. Do this in addition to remote API updates — never instead of them (except provider `markdown`, where files are the system of record).

## Loading workspace

At the start of explore / bug / research / model / design / implement / review / review-fix / ship / summarise:

1. Locate `docs/agents/WORKSPACE.md` (or ask once if missing → `/setup`).
2. Read **Provider** and provider settings.
3. Load this contract + the provider backend.
4. Prefer artifact paths from WORKSPACE over hardcoded roots.

## Close semantics

`transition(key, Done)` must fully close the issue in the provider:

| Provider | Done means |
|----------|------------|
| markdown | Status field = `Done` (+ INDEX) |
| jira | Workflow transition to Done |
| github | `gh issue close` (completed) + drop in-progress/in-review labels |
| linear | State = Done |

Ship is responsible for Done on Sub-tasks, Task, and Story-when-complete — see
[../workflow/reference.md](../workflow/reference.md#ship-closeout).

## Credentials

Never commit secrets. Use env vars or host auth (e.g. `gh auth`, Linear MCP).
If required auth is missing, stop with setup instructions for that backend.
