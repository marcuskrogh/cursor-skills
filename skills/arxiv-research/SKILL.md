---
name: arxiv-research
description: >-
  Investigates a user-described research topic through arXiv using the official
  export.arxiv.org Atom API via scripts/arxiv_research.py. Plans search strategy,
  runs batched queries with built-in rate limiting, triages papers, snowballs from
  seed hits, and delivers a structured research brief with citations. Use when the
  user wants literature review, paper discovery, state of the art, or research on
  a topic via arXiv.
---

# arXiv Research

Systematic literature investigation on arXiv for a user-described topic.

**Primary tool:** `scripts/arxiv_research.py` — stdlib Python, MCP-free, calls the official arXiv Atom API, returns structured JSON. Read [reference.md](reference.md) for query syntax and output schema.

## When to use

- "What does arXiv say about …?"
- Literature review, survey, or state-of-the-art on a topic
- Find seminal or recent papers in a field
- Compare approaches, methods, or trends from preprints
- Resolve or enrich known arXiv IDs in context of a broader question

## Data source (mandatory)

Use `scripts/arxiv_research.py` as the **first** retrieval path:

```bash
python3 scripts/arxiv_research.py search -q 'all:topic AND cat:cs.LG' --max-results 25
python3 scripts/arxiv_research.py lookup --ids 1706.03762,2312.00752
python3 scripts/arxiv_research.py snowball --ids 1706.03762 --max-results 20
```

The script handles URL encoding, rate limiting (≥3 s between API calls), Atom XML parsing, deduplication, and JSON output.

**Fallback** (only if Python is unavailable): `curl -sL` on `https://export.arxiv.org/api/query?...` or `WebFetch` on the same URL. Do **not** scrape `arxiv.org/search` unless the request needs DOI, ORCID, ACM, or MSC lookup (see reference.md).

## Workflow

### 1. Scope the research question

Before searching, pin down:

| Dimension | Clarify if missing |
|-----------|-------------------|
| **Topic** | Core concepts, synonyms, acronyms |
| **Intent** | Survey, seminal works, recent advances, method comparison, gap analysis |
| **Time horizon** | All time, last N years, or explicit date window |
| **Domain** | arXiv categories (`cat:cs.LG`, `cat:math.OC`, …) |
| **Depth** | Quick scan (5–10 papers) vs thorough review (25–50+) |
| **Exclusions** | Topics, methods, or application areas to skip |

If the user's message is already specific, infer reasonable defaults and state them briefly. Ask **one** clarifying question only when a wrong assumption would waste the search.

### 2. Plan the search strategy

Design **2–4 complementary queries**, not one monolithic string:

1. **Broad discovery** — `all:` terms + optional `cat:` filter
2. **Title-focused** — `ti:"key phrase"` for landmark papers
3. **Abstract-focused** — `abs:` terms for methodological overlap
4. **Recency slice** — same query + `submittedDate:` window
5. **Author anchor** (if user names researchers) — `au:lastname`

Record the planned queries before executing.

### 3. Execute searches (one script call)

Run **all planned queries in a single invocation** — the script throttles internally and deduplicates:

```bash
python3 scripts/arxiv_research.py search \
  -q 'all:retrieval+augmented+generation+AND+cat:cs.CL' \
  -q 'ti:"retrieval+augmented"' \
  -q 'abs:RAG+AND+submittedDate:[202301010000+TO+202512312359]' \
  --max-results 50 \
  --sort submittedDate \
  --order descending
```

**Sort defaults:**

| Intent | Flags |
|--------|-------|
| Seminal / foundational | default (`relevance`) |
| Latest work | `--sort submittedDate --order descending` |
| Recently updated surveys | `--sort lastUpdatedDate --order descending` |

**Lookup known papers** in the same pass when IDs are known:

```bash
python3 scripts/arxiv_research.py lookup --ids 1706.03762,2401.12345
```

**Pagination** (only when `total_results` exceeds one page and more depth is needed):

```bash
python3 scripts/arxiv_research.py search -q 'all:topic' --max-results 50 --start 50
```

Use `--paginate` to fetch all pages for a query (respects rate limits; use sparingly).

Stop when you have enough high-quality candidates, or when additional pages yield diminishing relevance.

### 4. Snowball from core papers

After identifying 2–5 **core** seed papers, expand coverage in one call:

```bash
python3 scripts/arxiv_research.py snowball \
  --ids 1706.03762,2312.00752 \
  --max-results 20 \
  --years-back 3
```

The script fetches seeds, extracts top authors and categories, runs follow-up queries for recent related work, and excludes the seeds from results. Merge snowball hits into the candidate pool.

### 5. Triage and rank

Work from the script's JSON `papers` array. Papers appearing in multiple `source_queries` are stronger candidates.

Score each paper on:

- **Relevance** — matches the scoped question
- **Recency** — `submitted_date` vs time horizon
- **Centrality** — recurrence across queries, author/category snowball hits, title/abstract signals ("survey", "review")
- **Quality signals** — clear problem statement, `journal_ref` / `doi` when present

Produce a short ranked shortlist:

| Tier | Size | Action |
|------|------|--------|
| **Core** | 3–8 | Deep read (abstract + metadata) |
| **Supporting** | 5–15 | Cite in synthesis with one-line relevance |
| **Peripheral** | rest | Mention only if they fill a gap |

### 6. Deep read (core papers)

For each **Core** paper, extract from JSON fields:

- **Problem** — what gap or question
- **Approach** — method / architecture / theory
- **Contribution** — main claim vs prior work
- **Evidence** — datasets, benchmarks, theorems (from `abstract` + `comment`)
- **Limitations** — stated or inferable caveats
- **Links** — `abs_url`, `pdf_url`

Do not hallucinate paper content. If the abstract is insufficient, say so.

### 7. Synthesize findings

Deliver a **structured research brief**. Always include citations with arXiv links.

```markdown
# Research brief: <topic>

## Question
<Restated research question and scope>

## Search strategy
<Script commands run, queries, result counts>

## Executive summary
<3–6 sentences: main themes, consensus, open questions>

## Key papers
### 1. <Title> ([arXiv:ID](abs_url))
- **Authors:** …
- **Date:** …
- **Category:** …
- **Relevance:** …
- **Takeaway:** …

## Themes and trends
<Grouped findings>

## Gaps and limitations
<Under-explored or contested areas>

## Recommended reading order
<Ordered list for newcomers>

## Sources
<Bulleted arXiv IDs with abs URLs>
```

### 8. Offer follow-ups

After the brief, offer (only if natural): narrow/broaden search, extend date window, snowball from new seeds, compare sub-topics.

## Operational rules

1. **Script first** — one `search` call with multiple `-q` flags beats many sequential `curl` calls.
2. **MCP-free** — do not require MCP servers; the script is the standard path.
3. **Honest coverage** — arXiv is preprints; note peer-review status.
4. **No fabrication** — every claim must trace to script JSON output.
5. **Proportional depth** — quick scan: 1 script call; thorough review: search + snowball.
6. **Canonical IDs** — use `arxiv_id` field (no `vN` suffix) unless version matters.

## Anti-patterns

- Multiple separate script invocations when one `search -q ... -q ...` suffices
- Hand-parsing Atom XML when the script is available
- Ignoring `total_results` and treating the first page as exhaustive
- Citing papers not present in script output
- Scraping search HTML when the API suffices

## Quick examples

**Recent diffusion models for protein design:**

```bash
python3 scripts/arxiv_research.py search \
  -q 'all:diffusion+protein+design+AND+cat:q-bio' \
  -q 'ti:"protein"+AND+abs:diffusion' \
  -q 'all:diffusion+AND+cat:q-bio+AND+submittedDate:[202401010000+TO+202512312359]' \
  --max-results 30 --sort submittedDate --order descending
```

Then triage → brief.

**Transformer paper + 2017 attention landscape:**

```bash
python3 scripts/arxiv_research.py lookup --ids 1706.03762
python3 scripts/arxiv_research.py search \
  -q 'all:attention+AND+submittedDate:[201701010000+TO+201712312359]+AND+cat:cs.CL' \
  --max-results 30 --sort submittedDate
python3 scripts/arxiv_research.py snowball --ids 1706.03762 --years-back 1 --max-results 15
```
