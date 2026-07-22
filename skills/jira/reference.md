# Jira integration reference

Agent reference for skills that create or update Jira issues. **Not a user-invoked skill.**

If the target repository contains `docs/agents/jira.md`, follow that file instead of this reference.

## Prerequisites

Stop and ask the user to configure if missing:

| Variable | Purpose |
|----------|---------|
| `JIRA_BASE_URL` | e.g. `https://your-org.atlassian.net` |
| `JIRA_EMAIL` | API user email |
| `JIRA_API_TOKEN` | Atlassian API token |
| `JIRA_PROJECT_KEY` | Default project (e.g. `SW`) — ask if unset |

Auth for REST calls: `-u "$JIRA_EMAIL:$JIRA_API_TOKEN"`

Use `curl` or `gh`-style shell; do not commit credentials.

## Issue types (default mapping)

| Skill | Primary issue | Children |
|-------|---------------|----------|
| `explore` | **Story** | **Task** per roadmap phase (linked or child) |
| `design` | **Task** or **Story** | **Sub-task** per work package |
| `model` | **Task** | — |
| `implement` | Existing **Task** / **Story** / parent | **Sub-task** per work package (if not already present) |
| `code-review` | Existing ticket in **In Review** | — |

Adjust issue type names to match the Jira project schema if creation fails.

## Status workflow

Skills use these logical states (match to project transitions by name):

| State | Used by |
|-------|---------|
| **To Do** / **Backlog** | New tickets from explore, design, model |
| **In Progress** | `implement` at session start |
| **In Review** | `implement` when PR is ready; required for `code-review` |
| **Done** | Out of scope unless user asks |

Discover transitions:

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/3/issue/PROJ-123/transitions" | jq .
```

Transition:

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$JIRA_BASE_URL/rest/api/3/issue/PROJ-123/transitions" \
  -d '{"transition":{"id":"<id>"}}'
```

If exact status names differ, pick the closest transition and note it in the ticket comment.

## Create issue

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$JIRA_BASE_URL/rest/api/3/issue" \
  -d '{
    "fields": {
      "project": {"key": "PROJ"},
      "summary": "Title",
      "description": {
        "type": "doc",
        "version": 1,
        "content": [{
          "type": "paragraph",
          "content": [{"type": "text", "text": "Markdown summary here"}]
        }]
      },
      "issuetype": {"name": "Story"}
    }
  }'
```

Response includes `key` (e.g. `PROJ-42`) and `id`.

### Sub-task (parent required)

```bash
"issuetype": {"name": "Sub-task"},
"parent": {"key": "PROJ-42"}
```

### Link to parent / related

Use `parent` for subtasks. For relates-to links:

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$JIRA_BASE_URL/rest/api/3/issueLink" \
  -d '{
    "type": {"name": "Relates"},
    "inwardIssue": {"key": "PROJ-42"},
    "outwardIssue": {"key": "PROJ-43"}
  }'
```

## Comment

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$JIRA_BASE_URL/rest/api/3/issue/PROJ-123/comment" \
  -d '{
    "body": {
      "type": "doc",
      "version": 1,
      "content": [{
        "type": "paragraph",
        "content": [{"type": "text", "text": "Comment text"}]
      }]
    }
  }'
```

## Attachment

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -X POST "$JIRA_BASE_URL/rest/api/3/issue/PROJ-123/attachments" \
  -H "X-Atlassian-Token: no-check" \
  -F "file=@MODEL.md"
```

## Fetch issue

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/3/issue/PROJ-123?fields=summary,description,status,issuetype,parent,subtasks,issuelinks"
```

## Branch naming

`<issue-key-lowercase>-<short-description>` — e.g. `sw-42-forecast-chart`.

## PR ↔ Jira

- Put `PROJ-123` in PR title or body; Jira may auto-link.
- In PR description: `Jira: https://your-org.atlassian.net/browse/PROJ-123`
- On implement completion, comment on Jira with PR URL.

## Ticket description template

```markdown
## Summary
…

## Artifact
- Repo: `path/to/PLAN.md` (commit SHA if applicable)
- Attached: MODEL.md

## Acceptance criteria
- …
```

## Error handling

- Creation fails on issue type → list project issue types and retry.
- Transition fails → list available transitions, ask user if ambiguous.
- Missing credentials → stop with setup instructions; do not skip Jira steps silently.
