---
name: tracker
description: >-
  Shared issue-tracker contract for pipeline skills. Resolves the provider from
  docs/agents/WORKSPACE.md (markdown, jira, github, or linear). Not for user
  invocation — composed by explore, define, implement, review, ship, and setup.
disable-model-invocation: true
---

# Tracker

**Shared reference skill.** Users configure the tracker via [setup](../setup/SKILL.md), not this file.

1. Read the repo's `docs/agents/WORKSPACE.md` (or path from that file).
2. Read [reference.md](reference.md) for the logical operations.
3. Read the matching backend:
   - [backends/markdown.md](backends/markdown.md)
   - [backends/jira.md](backends/jira.md)
   - [backends/github.md](backends/github.md)
   - [backends/linear.md](backends/linear.md)

If `WORKSPACE.md` is missing, tell the user to run `/setup` before creating issues.
