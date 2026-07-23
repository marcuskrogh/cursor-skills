---
name: research
description: >-
  Literature investigation via arXiv (scripts/arxiv_research.py). Writes RESEARCH.md,
  links it to a pipeline Task when given, and updates shared continuity markdown
  (ROADMAP/PLAN/ISSUES). Use for surveys, paper discovery, or state of the art.
---

# Research

Applies [CONCEPT_RESEARCH](../concepts/CONCEPT_RESEARCH.md) as a systematic literature
investigation on arXiv for a user-described topic. Optional side path on the main
pipeline — feeds **model**, **define**, or **explore**.

**On invoke:** read [../concepts/CONCEPT_RESEARCH.md](../concepts/CONCEPT_RESEARCH.md),
[../workflow/reference.md](../workflow/reference.md), and
[../tracker/SKILL.md](../tracker/SKILL.md) when a Task key or WORKSPACE exists. Read
[reference.md](reference.md) for query syntax.

**Primary tool:** `scripts/arxiv_research.py` — stdlib Python, MCP-free, official
arXiv Atom API → JSON.

## Extension contract

| Extension | This skill |
|-----------|------------|
| **Data source** | arXiv Atom API via `scripts/arxiv_research.py` |
| **Retrieval path** | Script first (`search` / `lookup` / `snowball`); curl/WebFetch fallback only if Python unavailable |
| **Artifact** | `RESEARCH.md` (path from WORKSPACE) |
| **Citation rules** | Every claim traces to script JSON; use canonical `arxiv_id` |

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

The script handles URL encoding, rate limiting (≥3 s between API calls), Atom XML
parsing, deduplication, and JSON output.

**Fallback** (only if Python is unavailable): `curl -sL` on
`https://export.arxiv.org/api/query?...` or `WebFetch` on the same URL. Do **not**
scrape `arxiv.org/search` unless the request needs DOI, ORCID, ACM, or MSC lookup
(see reference.md).

## Workflow specialisation

Follow CONCEPT_RESEARCH. arXiv-specific notes:

### Scope

Domain filters use arXiv categories (`cat:cs.LG`, `cat:math.OC`, …).

### Search strategy

Design **2–4 complementary queries**:

1. **Broad discovery** — `all:` terms + optional `cat:` filter
2. **Title-focused** — `ti:"key phrase"` for landmark papers
3. **Abstract-focused** — `abs:` terms for methodological overlap
4. **Recency slice** — same query + `submittedDate:` window
5. **Author anchor** (if user names researchers) — `au:lastname`

### Execute (one script call)

Run **all planned queries in a single invocation**:

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

### Snowball

```bash
python3 scripts/arxiv_research.py snowball \
  --ids 1706.03762,2312.00752 \
  --max-results 20 \
  --years-back 3
```

### Triage

Work from the script's JSON `papers` array. Papers appearing in multiple
`source_queries` are stronger candidates. Prefer `submitted_date`, `journal_ref` /
`doi`, and title/abstract signals ("survey", "review").

### Deep read

Extract from JSON fields: problem, approach, contribution, evidence (`abstract` +
`comment`), limitations, `abs_url` / `pdf_url`.

### Artifact

Write **`RESEARCH.md`**:

```markdown
# Research brief: <topic>

## Question
…

## Search strategy
…

## Executive summary
…

## Key papers
…

## Themes and trends
…

## Gaps and limitations
…

## Recommended reading order
…

## Sources
…

## Tracker
- Task: <KEY> (if linked)
- Artifact: RESEARCH.md

## Next
`/<skill> <KEY>` — <why>
```

## Pipeline continuity

When a pipeline **Task** (or Story) key was given or inferred:

1. `attach_or_link` `RESEARCH.md` on that issue; `comment` with path + short executive summary + **Next**.
2. Do **not** change Task status (leave **To Do** / current); do **not** create a parallel Task when a key was given.
3. If `ROADMAP.md` lists the phase, add/update an Artifact / Notes cell pointing at `RESEARCH.md`.
4. If `PLAN.md` exists for the Task, add a **Research** section or link under Open items / Inputs.
5. Upsert the markdown mirror (`docs/agents/ISSUES.md`) with artifact + **Next**.

Standalone research (no Task): still write `RESEARCH.md`; **Next** may be `/explore`
or `/define` if the user wants to start a phase.

## Handoff

| Context | Next |
|---------|------|
| Math-heavy follow-up | `/model <KEY>` |
| Ready to specify behaviour | `/define <KEY>` |
| Still scoping the initiative | `/explore` |
| Only needed the brief | No further skill |

```markdown
## Next
`/define <KEY>` — Define with research inputs
```

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
