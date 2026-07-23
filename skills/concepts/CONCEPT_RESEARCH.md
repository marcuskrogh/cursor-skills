# Concept: Research

**Uninvokable concept.** Skills that need this behaviour must instruct the agent to
read this file on invoke. Do not surface this concept unless a skill references it.

## Purpose

Produce an honest, citable **research brief** on a scoped question: what is known,
what themes recur, what gaps remain, and what to read next — without fabricating
sources or overstating coverage.

Skills specialise the **data source**, tooling, artifact path, and pipeline handoff.

## What this is not

- Not a user-invokable workflow by itself
- Not alignment / definition of product behaviour (those are other concepts)
- Not implementation
- Not a dump of raw search results without synthesis

## Extension contract

Skills that apply this concept **must** define:

| Extension | Purpose |
|-----------|---------|
| **Data source** | Where evidence comes from (API, corpus, script, …) |
| **Retrieval path** | Mandatory first tool / command sequence |
| **Artifact** | Brief filename and required sections |
| **Citation rules** | How claims must trace to retrieved evidence |

Skills **may** define:

| Extension | Purpose |
|-----------|---------|
| **Domain filters** | Categories, venues, date windows |
| **Depth presets** | Quick scan vs thorough review |
| **Pipeline continuity** | How to attach the brief to a Task / roadmap |
| **Handoff defaults** | Next skill after the brief |

## Workflow (conceptual)

### 1. Scope the research question

Before searching, pin down (infer defaults when safe; ask once if a wrong assumption
would waste the search):

| Dimension | Clarify if missing |
|-----------|-------------------|
| **Topic** | Core concepts, synonyms, acronyms |
| **Intent** | Survey, seminal works, recent advances, method comparison, gap analysis |
| **Time horizon** | All time, last N years, or explicit window |
| **Domain** | Field / category filters |
| **Depth** | Quick scan vs thorough review |
| **Exclusions** | Topics or methods to skip |

### 2. Plan complementary queries

Design **2–4 complementary queries**, not one monolithic string — e.g. broad
discovery, title-focused landmarks, abstract/method overlap, recency slice, author
anchor when named.

Record the planned queries before executing.

### 3. Execute retrieval

Prefer **one batched retrieval** that covers the planned queries (with internal
throttling / dedup when the skill's tool supports it) over many sequential ad-hoc
calls.

Stop when high-quality candidates suffice or additional pages yield diminishing
relevance.

### 4. Expand from core seeds

After identifying a small set of **core** papers or sources, snowball (related work,
authors, categories) to improve coverage. Merge into the candidate pool.

### 5. Triage and rank

Score candidates on relevance, recency, centrality (recurrence across queries), and
quality signals available in metadata. Produce tiers:

| Tier | Size | Action |
|------|------|--------|
| **Core** | 3–8 | Deep read |
| **Supporting** | 5–15 | Cite with one-line relevance |
| **Peripheral** | rest | Mention only to fill a gap |

### 6. Deep read (core)

For each core item, extract from **available evidence only**:

- Problem / gap
- Approach
- Contribution vs prior work
- Evidence (datasets, benchmarks, theorems)
- Limitations
- Links / identifiers

Do not hallucinate content. If the abstract or metadata is insufficient, say so.

### 7. Synthesize

Write a brief that includes at least: question, search strategy, executive summary,
key sources, themes/trends, gaps/limitations, recommended reading order, and full
citations with durable links/IDs.

### 8. Hand off

Point to the next skill only when the brief should feed definition, modelling, or
further scoping — otherwise end.

## Invariants

- **Evidence traceability.** Every claim traces to retrieved output.
- **Honest coverage.** Note corpus limits (e.g. preprints vs peer review).
- **Proportional depth.** Quick scans stay light; thorough reviews search + expand.
- **No fabrication.** Never cite sources not present in retrieval results.
- **Canonical IDs.** Prefer stable identifiers from the skill's data source.

## Anti-patterns

- Many separate retrievals when one batched call would suffice
- Treating the first page as exhaustive without checking total hit counts
- Citing papers or facts not in retrieval output
- Skipping synthesis and dumping raw JSON/XML
- Scraping HTML when the skill's API/script path works

## Authoring skills that use this concept

1. Instruct the agent to **read this file** on invoke.
2. Fill in the **extension contract** (especially data source + retrieval path).
3. Link: `[CONCEPT_RESEARCH](../concepts/CONCEPT_RESEARCH.md)`.
