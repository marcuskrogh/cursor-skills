---
name: setup
description: >-
  Workspace alignment for a repository: choose issue tracker (markdown, Jira,
  GitHub, or Linear), artifact paths, and delivery conventions. Writes
  docs/agents/WORKSPACE.md so pipeline skills persist continuity in markdown.
  Use when onboarding a repo, changing tracker, or before first explore/define.
---

# Setup

Applies [CONCEPT_ALIGNMENT](../concepts/CONCEPT_ALIGNMENT.md) to **workspace
configuration** for this repository. Produces `docs/agents/WORKSPACE.md` (path
overridable) that all pipeline skills read first.

**On invoke:** read [../concepts/CONCEPT_ALIGNMENT.md](../concepts/CONCEPT_ALIGNMENT.md),
[format.md](format.md), and [../tracker/reference.md](../tracker/reference.md).

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Subject** | How this repo runs the agent pipeline (tracker, paths, delivery) |
| **Probes** | See [Probes](#probes) |
| **Stop condition** | Tracker provider, artifact paths, and delivery defaults are unambiguous |
| **Alignment artifact** | `docs/agents/WORKSPACE.md` (see [format.md](format.md)) |
| **Readiness prompt** | "Does this workspace setup look right to commit?" |

### Probes

- Issue tracker provider: **markdown** | **jira** | **github** | **linear**
- Provider-specific settings (project key, issues dir, Linear team, GitHub repo)
- Whether to **always mirror** issue keys/status/Next into markdown (`docs/agents/ISSUES.md`)
- Artifact roots: agents dir, roadmap path, plan path pattern, model path
- Default base branch, branch naming, PR default (open vs branch-only), merge strategy
- Whether pipeline skills may invent a default setup if `WORKSPACE.md` is missing (recommend: no — run setup)

### Opening

| Context | First move |
|---------|------------|
| **Thin** | "Which issue tracker should this repo use — local markdown, Jira, GitHub Issues, or Linear?" |
| **Rich** / existing `WORKSPACE.md` | Load it; ask the highest-impact divergence (usually tracker or paths) |

### Scope guard

- No feature definition, modelling, or implementation
- Do not create pipeline Story/Task issues during setup (only config + empty dirs/index if markdown)

## After approval

1. Write `docs/agents/WORKSPACE.md` per [format.md](format.md).
2. Ensure agents directory exists.
3. If provider is **markdown**: create issues dir + `INDEX.md` stub per [../tracker/backends/markdown.md](../tracker/backends/markdown.md).
4. If mirror enabled: create `docs/agents/ISSUES.md` stub (headers only).
5. Commit when the user wants (ask once): workspace setup only.
6. Report path and chosen tracker. **Next** depends on intent:

```markdown
## Next
`/explore` — Start a feature
```

or

```markdown
## Next
`/bug` — Report and fix a defect
```

or, if they only wanted config: no further skill.

## Re-run

Re-invoking `/setup` updates `WORKSPACE.md`. Do not delete existing issues; note migrations the user must do if the provider changes.
