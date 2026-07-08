#!/usr/bin/env python3
"""arXiv research helper — stdlib only, MCP-free.

Fetches papers from the official arXiv Atom API, parses results to JSON,
deduplicates across queries, and supports snowball follow-up searches.

Usage:
  python3 scripts/arxiv_research.py search --query 'all:topic AND cat:cs.LG' --max-results 25
  python3 scripts/arxiv_research.py lookup --ids 1706.03762,2312.00752
  python3 scripts/arxiv_research.py snowball --ids 1706.03762 --max-results 15
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import asdict, dataclass, field
from typing import Any

API_BASE = "https://export.arxiv.org/api/query"
RATE_LIMIT_SEC = 3.0
MAX_RESULTS_CAP = 200
DEFAULT_MAX_RESULTS = 25

NS = {
    "atom": "http://www.w3.org/2005/Atom",
    "opensearch": "http://a9.com/-/spec/opensearch/1.1/",
    "arxiv": "http://arxiv.org/schemas/atom",
}

_last_request_at = 0.0


@dataclass
class Paper:
    arxiv_id: str
    version: int | None
    canonical_id_with_version: str
    title: str
    authors: list[str]
    abstract: str
    submitted_date: str
    updated_date: str
    primary_category: str
    categories: list[str]
    comment: str | None = None
    journal_ref: str | None = None
    doi: str | None = None
    abs_url: str = ""
    pdf_url: str = ""
    source_queries: list[str] = field(default_factory=list)


@dataclass
class QueryResult:
    search_query: str | None
    id_list: str | None
    sort_by: str
    sort_order: str
    start: int
    max_results: int
    total_results: int
    items_per_page: int
    start_index: int
    papers: list[Paper]


def _text(elem: ET.Element | None) -> str:
    if elem is None or elem.text is None:
        return ""
    return re.sub(r"\s+", " ", elem.text).strip()


def _parse_arxiv_id(entry_id: str) -> tuple[str, int | None, str]:
    """Return (canonical_id, version, canonical_id_with_version)."""
    raw = entry_id.rstrip("/").split("/")[-1]
    match = re.match(r"^(.+?)v(\d+)$", raw)
    if match:
        return match.group(1), int(match.group(2)), raw
    return raw, None, raw


def _find_link(entry: ET.Element, rel: str, mime: str | None = None) -> str:
    for link in entry.findall("atom:link", NS):
        if link.get("rel") != rel:
            continue
        if mime is not None and link.get("type") != mime:
            continue
        href = link.get("href")
        if href:
            return href
    return ""


def _parse_entry(entry: ET.Element, source_query: str | None = None) -> Paper:
    entry_id = _text(entry.find("atom:id", NS))
    arxiv_id, version, canonical_with_version = _parse_arxiv_id(entry_id)

    authors = [_text(a.find("atom:name", NS)) for a in entry.findall("atom:author", NS)]
    authors = [a for a in authors if a]

    categories = [
        c.get("term", "")
        for c in entry.findall("atom:category", NS)
        if c.get("term")
    ]
    primary_el = entry.find("arxiv:primary_category", NS)
    primary = primary_el.get("term", "") if primary_el is not None else ""

    comment_el = entry.find("arxiv:comment", NS)
    journal_el = entry.find("arxiv:journal_ref", NS)
    doi_el = entry.find("arxiv:doi", NS)

    paper = Paper(
        arxiv_id=arxiv_id,
        version=version,
        canonical_id_with_version=canonical_with_version,
        title=_text(entry.find("atom:title", NS)),
        authors=authors,
        abstract=_text(entry.find("atom:summary", NS)),
        submitted_date=_text(entry.find("atom:published", NS)),
        updated_date=_text(entry.find("atom:updated", NS)),
        primary_category=primary,
        categories=categories,
        comment=_text(comment_el) or None,
        journal_ref=_text(journal_el) or None,
        doi=_text(doi_el) or None,
        abs_url=_find_link(entry, "alternate"),
        pdf_url=_find_link(entry, "related", "application/pdf"),
    )
    if source_query:
        paper.source_queries.append(source_query)
    return paper


def _normalize_query(query: str) -> str:
    """Convert URL-style '+' separators to spaces for proper urlencode."""
    return query.replace("+", " ").strip()


def _throttle() -> None:
    global _last_request_at
    elapsed = time.monotonic() - _last_request_at
    if elapsed < RATE_LIMIT_SEC:
        time.sleep(RATE_LIMIT_SEC - elapsed)
    _last_request_at = time.monotonic()


def _fetch_atom(
    *,
    search_query: str | None = None,
    id_list: str | None = None,
    start: int = 0,
    max_results: int = DEFAULT_MAX_RESULTS,
    sort_by: str = "relevance",
    sort_order: str = "descending",
) -> ET.Element:
    params: dict[str, str] = {
        "start": str(start),
        "max_results": str(min(max_results, MAX_RESULTS_CAP)),
    }
    if search_query:
        params["search_query"] = _normalize_query(search_query)
    if id_list:
        params["id_list"] = id_list
    if sort_by != "relevance":
        params["sortBy"] = sort_by
        params["sortOrder"] = sort_order

    url = f"{API_BASE}?{urllib.parse.urlencode(params)}"
    _throttle()
    req = urllib.request.Request(url, headers={"User-Agent": "arxiv-research-skill/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = resp.read()
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"arXiv API HTTP {exc.code}: {exc.reason}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"arXiv API request failed: {exc.reason}") from exc

    return ET.fromstring(data)


def _parse_feed(
    root: ET.Element,
    *,
    search_query: str | None,
    id_list: str | None,
    sort_by: str,
    sort_order: str,
    start: int,
    max_results: int,
) -> QueryResult:
    total_el = root.find("opensearch:totalResults", NS)
    items_el = root.find("opensearch:itemsPerPage", NS)
    start_el = root.find("opensearch:startIndex", NS)

    papers = []
    for entry in root.findall("atom:entry", NS):
        papers.append(_parse_entry(entry, source_query=search_query))

    return QueryResult(
        search_query=search_query,
        id_list=id_list,
        sort_by=sort_by,
        sort_order=sort_order,
        start=start,
        max_results=max_results,
        total_results=int(_text(total_el) or "0"),
        items_per_page=int(_text(items_el) or "0"),
        start_index=int(_text(start_el) or "0"),
        papers=papers,
    )


def run_search(
    queries: list[str],
    *,
    max_results: int = DEFAULT_MAX_RESULTS,
    sort_by: str = "relevance",
    sort_order: str = "descending",
    start: int = 0,
    paginate: bool = False,
) -> dict[str, Any]:
    """Run one or more search queries; merge and deduplicate results."""
    all_papers: dict[str, Paper] = {}
    query_runs: list[dict[str, Any]] = []

    for query in queries:
        offset = start
        fetched_for_query = 0
        total_for_query = None

        while True:
            root = _fetch_atom(
                search_query=query,
                start=offset,
                max_results=max_results,
                sort_by=sort_by,
                sort_order=sort_order,
            )
            result = _parse_feed(
                root,
                search_query=query,
                id_list=None,
                sort_by=sort_by,
                sort_order=sort_order,
                start=offset,
                max_results=max_results,
            )
            if total_for_query is None:
                total_for_query = result.total_results
                query_runs.append(
                    {
                        "search_query": query,
                        "total_results": result.total_results,
                        "fetched": 0,
                    }
                )

            for paper in result.papers:
                if paper.arxiv_id in all_papers:
                    existing = all_papers[paper.arxiv_id]
                    for sq in paper.source_queries:
                        if sq not in existing.source_queries:
                            existing.source_queries.append(sq)
                else:
                    all_papers[paper.arxiv_id] = paper
                fetched_for_query += 1

            query_runs[-1]["fetched"] = min(
                fetched_for_query, total_for_query or fetched_for_query
            )

            if not paginate:
                break
            offset += len(result.papers)
            if offset >= (total_for_query or 0) or not result.papers:
                break

    papers = sorted(
        all_papers.values(),
        key=lambda p: (p.submitted_date, p.arxiv_id),
        reverse=True,
    )
    return {
        "mode": "search",
        "queries": query_runs,
        "unique_papers": len(papers),
        "papers": [asdict(p) for p in papers],
    }


def run_lookup(
    ids: list[str],
    *,
    max_results: int | None = None,
) -> dict[str, Any]:
    """Fetch metadata for known arXiv IDs via id_list."""
    if not ids:
        raise ValueError("At least one arXiv ID is required")

    id_list = ",".join(ids)
    limit = max_results if max_results is not None else max(len(ids), DEFAULT_MAX_RESULTS)
    root = _fetch_atom(id_list=id_list, max_results=limit)
    result = _parse_feed(
        root,
        search_query=None,
        id_list=id_list,
        sort_by="relevance",
        sort_order="descending",
        start=0,
        max_results=limit,
    )
    return {
        "mode": "lookup",
        "id_list": id_list,
        "total_results": result.total_results,
        "papers": [asdict(p) for p in result.papers],
    }


def _author_last_name(author: str) -> str:
    parts = author.strip().split()
    if not parts:
        return ""
    last = parts[-1].lower()
    return re.sub(r"[^a-z]", "", last)


def run_snowball(
    ids: list[str],
    *,
    max_results: int = DEFAULT_MAX_RESULTS,
    years_back: int = 3,
    max_authors: int = 3,
    max_categories: int = 2,
) -> dict[str, Any]:
    """Expand from seed papers via author + category follow-up queries."""
    seed = run_lookup(ids)
    seed_papers = seed["papers"]
    if not seed_papers:
        return {
            "mode": "snowball",
            "seed_ids": ids,
            "follow_up_queries": [],
            "seed_papers": [],
            "unique_papers": 0,
            "papers": [],
            "warning": "No papers found for seed IDs.",
        }

    author_counts: dict[str, int] = {}
    category_counts: dict[str, int] = {}
    seed_id_set = {p["arxiv_id"] for p in seed_papers}

    for paper in seed_papers:
        for author in paper.get("authors", [])[:5]:
            last = _author_last_name(author)
            if last:
                author_counts[last] = author_counts.get(last, 0) + 1
        for cat in paper.get("categories", []):
            category_counts[cat] = category_counts.get(cat, 0) + 1

    top_authors = sorted(author_counts, key=author_counts.get, reverse=True)[:max_authors]
    top_categories = sorted(category_counts, key=category_counts.get, reverse=True)[
        :max_categories
    ]

    from datetime import datetime, timezone

    now = datetime.now(timezone.utc)
    start_year = now.year - years_back
    date_from = f"{start_year}01010000"
    date_to = now.strftime("%Y%m%d%H%M")
    date_range = f"submittedDate:[{date_from} TO {date_to}]"

    follow_up_queries: list[str] = []
    for author in top_authors:
        parts = [f"au:{author}"]
        if top_categories:
            cat_expr = " OR ".join(f"cat:{c}" for c in top_categories)
            parts.append(f"({cat_expr})")
        parts.append(date_range)
        follow_up_queries.append(" AND ".join(parts))

    for cat in top_categories:
        q = f"cat:{cat} AND {date_range}"
        if q not in follow_up_queries:
            follow_up_queries.append(q)

    expanded = run_search(
        follow_up_queries,
        max_results=max_results,
        sort_by="submittedDate",
        sort_order="descending",
    )

    # Remove seed papers from expanded set
    expanded_papers = [
        p for p in expanded["papers"] if p["arxiv_id"] not in seed_id_set
    ]

    return {
        "mode": "snowball",
        "seed_ids": ids,
        "seed_papers": seed_papers,
        "follow_up_queries": follow_up_queries,
        "top_authors": top_authors,
        "top_categories": top_categories,
        "unique_papers": len(expanded_papers),
        "papers": expanded_papers,
    }


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Search arXiv via the official Atom API and emit structured JSON.",
    )
    parser.add_argument(
        "--compact",
        action="store_true",
        help="Emit compact JSON (no indentation).",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    search_p = sub.add_parser("search", help="Run one or more search queries")
    search_p.add_argument(
        "--query",
        "-q",
        action="append",
        required=True,
        dest="queries",
        metavar="EXPR",
        help="arXiv search_query expression (repeatable)",
    )
    search_p.add_argument(
        "--max-results",
        type=int,
        default=DEFAULT_MAX_RESULTS,
        help=f"Results per query page (default {DEFAULT_MAX_RESULTS}, max {MAX_RESULTS_CAP})",
    )
    search_p.add_argument(
        "--sort",
        choices=["relevance", "submittedDate", "lastUpdatedDate"],
        default="relevance",
        help="Sort field (default: relevance)",
    )
    search_p.add_argument(
        "--order",
        choices=["ascending", "descending"],
        default="descending",
        help="Sort order (default: descending)",
    )
    search_p.add_argument(
        "--start",
        type=int,
        default=0,
        help="0-based offset for pagination (default: 0)",
    )
    search_p.add_argument(
        "--paginate",
        action="store_true",
        help="Fetch all pages for each query (respects rate limits)",
    )

    lookup_p = sub.add_parser("lookup", help="Fetch papers by arXiv ID")
    lookup_p.add_argument(
        "--ids",
        required=True,
        help="Comma-separated arXiv IDs",
    )
    lookup_p.add_argument(
        "--max-results",
        type=int,
        default=None,
        help="Max results (default: number of IDs)",
    )

    snow_p = sub.add_parser("snowball", help="Expand from seed papers via follow-up queries")
    snow_p.add_argument(
        "--ids",
        required=True,
        help="Comma-separated seed arXiv IDs",
    )
    snow_p.add_argument(
        "--max-results",
        type=int,
        default=DEFAULT_MAX_RESULTS,
        help=f"Max results per follow-up query (default {DEFAULT_MAX_RESULTS})",
    )
    snow_p.add_argument(
        "--years-back",
        type=int,
        default=3,
        help="How many years back for follow-up date window (default: 3)",
    )
    snow_p.add_argument(
        "--max-authors",
        type=int,
        default=3,
        help="Top authors to snowball from (default: 3)",
    )
    snow_p.add_argument(
        "--max-categories",
        type=int,
        default=2,
        help="Top categories to snowball from (default: 2)",
    )

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    indent = None if args.compact else 2

    try:
        if args.command == "search":
            result = run_search(
                args.queries,
                max_results=args.max_results,
                sort_by=args.sort,
                sort_order=args.order,
                start=args.start,
                paginate=args.paginate,
            )
        elif args.command == "lookup":
            ids = [i.strip() for i in args.ids.split(",") if i.strip()]
            result = run_lookup(ids, max_results=args.max_results)
        elif args.command == "snowball":
            ids = [i.strip() for i in args.ids.split(",") if i.strip()]
            result = run_snowball(
                ids,
                max_results=args.max_results,
                years_back=args.years_back,
                max_authors=args.max_authors,
                max_categories=args.max_categories,
            )
        else:
            parser.error(f"Unknown command: {args.command}")
            return 2
    except (RuntimeError, ValueError) as exc:
        print(json.dumps({"error": str(exc)}, indent=indent), file=sys.stderr)
        return 1

    print(json.dumps(result, indent=indent))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
