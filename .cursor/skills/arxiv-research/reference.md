# arXiv API reference (for agents)

Official docs: https://info.arxiv.org/help/api/user-manual.html

## Primary tool: `scripts/arxiv_research.py`

Stdlib Python script — no MCP, no extra dependencies. Always prefer this over raw `curl`.

### Commands

| Command | Purpose |
|---------|---------|
| `search` | One or more `-q` queries; merges and deduplicates |
| `lookup` | Fetch metadata by arXiv ID (`--ids`) |
| `snowball` | Expand from seed IDs via author/category follow-ups |

### Examples

```bash
# Multi-query search (one invocation)
python3 scripts/arxiv_research.py search \
  -q 'all:transformer AND cat:cs.LG' \
  -q 'ti:"attention is all you need"' \
  --max-results 50 \
  --sort submittedDate \
  --order descending

# Known paper lookup
python3 scripts/arxiv_research.py lookup --ids 1706.03762,hep-th/9711200

# Snowball from seeds
python3 scripts/arxiv_research.py snowball \
  --ids 1706.03762 \
  --max-results 20 \
  --years-back 3

# Pagination
python3 scripts/arxiv_research.py search -q 'all:topic' --max-results 50 --start 50

# Fetch all pages (slow; rate-limited)
python3 scripts/arxiv_research.py search -q 'all:topic' --paginate --max-results 100
```

### Flags

| Flag | Applies to | Default | Description |
|------|-----------|---------|-------------|
| `-q` / `--query` | search | — | Search expression (repeatable) |
| `--ids` | lookup, snowball | — | Comma-separated arXiv IDs |
| `--max-results` | all | 25 | Page size (max 200) |
| `--sort` | search | relevance | `relevance`, `submittedDate`, `lastUpdatedDate` |
| `--order` | search | descending | `ascending`, `descending` |
| `--start` | search | 0 | Pagination offset |
| `--paginate` | search | off | Fetch all pages per query |
| `--years-back` | snowball | 3 | Date window for follow-ups |
| `--max-authors` | snowball | 3 | Top authors to expand |
| `--max-categories` | snowball | 2 | Top categories to expand |
| `--compact` | all | off | Compact JSON output |

### JSON output schema

**`search` mode:**

```json
{
  "mode": "search",
  "queries": [
    { "search_query": "...", "total_results": 1234, "fetched": 25 }
  ],
  "unique_papers": 42,
  "papers": [ { "...paper fields..." } ]
}
```

**`lookup` mode:**

```json
{
  "mode": "lookup",
  "id_list": "1706.03762",
  "total_results": 1,
  "papers": [ { "...paper fields..." } ]
}
```

**`snowball` mode:**

```json
{
  "mode": "snowball",
  "seed_ids": ["1706.03762"],
  "seed_papers": [ { "..." } ],
  "follow_up_queries": ["au:vaswani+AND+..."],
  "top_authors": ["vaswani"],
  "top_categories": ["cs.CL", "cs.LG"],
  "unique_papers": 18,
  "papers": [ { "..." } ]
}
```

**Paper object fields:**

| Field | Type | Description |
|-------|------|-------------|
| `arxiv_id` | string | Canonical ID without version |
| `version` | int \| null | Version number |
| `canonical_id_with_version` | string | e.g. `1706.03762v7` |
| `title` | string | Paper title |
| `authors` | string[] | Author names (ordered) |
| `abstract` | string | Abstract text |
| `submitted_date` | string | ISO 8601 v1 submission |
| `updated_date` | string | ISO 8601 latest update |
| `primary_category` | string | e.g. `cs.LG` |
| `categories` | string[] | All categories |
| `comment` | string \| null | Author comments |
| `journal_ref` | string \| null | Journal reference |
| `doi` | string \| null | DOI if set |
| `abs_url` | string | Abstract page URL |
| `pdf_url` | string | PDF URL |
| `source_queries` | string[] | Which search queries returned this paper |

## Raw API (fallback only)

```
https://export.arxiv.org/api/query
```

Use when Python is unavailable:

```bash
curl -sL "https://export.arxiv.org/api/query?search_query=all:topic&max_results=25"
```

## Query parameters

| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| `search_query` | string | — | Boolean search expression |
| `id_list` | CSV | — | One or more arXiv IDs |
| `start` | int | 0 | 0-based offset |
| `max_results` | int | 10 | Page size (server max 2000) |
| `sortBy` | enum | relevance | `relevance`, `submittedDate`, `lastUpdatedDate` |
| `sortOrder` | enum | descending | `ascending`, `descending` |

## Field prefixes (`search_query`)

| Field | Prefix | Example |
|-------|--------|---------|
| All | `all:` | `all:diffusion+model` |
| Title | `ti:` | `ti:"graph+neural+network"` |
| Author | `au:` | `au:lecun` |
| Abstract | `abs:` | `abs:reinforcement+learning` |
| Comments | `co:` | `co:"NeurIPS+2024"` |
| Journal ref | `jr:` | `jr:"Nature"` |
| Report number | `rn:` | `rn:CERN-PH-TH` |
| Category | `cat:` | `cat:cs.LG` |

## Boolean operators

- `AND`, `OR`, `ANDNOT` — join with `+`: `all:transformer+AND+cat:cs.LG`
- Group: `%28cat:cs.LG+OR+cat:cs.AI%29`
- Phrases: `%22...%22`

## Date ranges

```
submittedDate:[YYYYMMDDHHMM TO YYYYMMDDHHMM]
lastUpdatedDate:[YYYYMMDDHHMM TO YYYYMMDDHHMM]
```

URL-encode brackets as `%5B` and `%5D`.

## arXiv ID formats

- **New style:** `YYMM.NNNNN` (e.g. `1706.03762`)
- **Old style:** `archive/YYMMNNN` (e.g. `hep-th/9711200`)
- **Version pin:** append `vN` to `id_list`

## Rate limiting

The script enforces **≥ 3 seconds** between API requests. Do not bypass with parallel raw `curl` calls.

## API limitations (HTML fallback)

Not searchable via Atom API: DOI, ORCID, ACM/MSC field search, cross-listed-only filter. Use `arxiv.org/search` via WebFetch, extract IDs, then `lookup --ids`.

## Common categories

| Code | Area |
|------|------|
| `cs.LG` | Machine learning |
| `cs.CL` | Computation and language |
| `cs.CV` | Computer vision |
| `cs.AI` | Artificial intelligence |
| `stat.ML` | Machine learning (statistics) |
| `math.OC` | Optimization and control |
| `q-bio` | Quantitative biology |

Full list: https://arxiv.org/category_taxonomy
