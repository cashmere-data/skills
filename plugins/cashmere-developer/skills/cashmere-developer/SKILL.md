---
name: cashmere-developer
license: MIT
description: >
  Build on Cashmere: licensed premium content (books, journals, articles) that
  AI products can search, read, and cite. Covers the Cashmere REST API
  (search, publications, sections, collections), the Cashmere MCP server, API
  keys and collection scoping, Cashmere Link OAuth for third-party apps, and
  citation rules. Use when writing code or agent tools that retrieve from
  Cashmere, wiring Cashmere into Claude/ChatGPT/another MCP client, or
  designing RAG or deep-research flows over licensed content. For publishers
  uploading content use cashmere-content; for usage and revenue numbers use
  cashmere-reporting.
---

# Build with Cashmere

Cashmere licenses premium publisher content to AI. Developers retrieve it
through a REST API or an MCP server. Every read is metered against a license,
and every answer built on it should link back to the source.

## Read the live docs

**The live Cashmere docs are the source of truth. Read them as part of the
task.** This skill gives direction. The docs carry the current endpoints,
parameters, search models, limits, and examples. Where this skill and the docs
disagree, the docs win.

- Start with the [documentation index](https://cashmere.io/docs/llms.txt) to
  find relevant pages. Read only the pages the task needs.
- Every guide is served as Markdown at `https://cashmere.io/docs/guides/<path>.md`.
  Drop the `.md` to get the HTML page.
- The API contract is the OpenAPI spec at
  [`https://cashmere.io/api/v2/openapi.json`](https://cashmere.io/api/v2/openapi.json),
  rendered for humans at [cashmere.io/docs](https://cashmere.io/docs). For a
  parameter name, a response field, or an error code, the spec outranks the
  guides.
- If the index is unavailable, use the direct links below. If a `.md` fetch
  fails, fetch the HTML page. If you have no live access at all, say so, and
  do not invent parameters, model names, or response fields.

| Task | Start here |
| --- | --- |
| First API call, end to end | [Developer quickstart](https://cashmere.io/docs/guides/developers/quickstart.md) |
| Get an API key, scope it to collections | [Creating an API key](https://cashmere.io/docs/guides/creating-an-api-key.md) |
| Search licensed content | [AI search on licensed content](https://cashmere.io/docs/guides/developers/ai-search-on-licensed-content.md), then `GET /search` in the spec |
| Give an LLM agent a Cashmere search tool | [Enabling AI search for your agents](https://cashmere.io/docs/guides/developers/enabling-ai-search-for-your-ai-agents.md) |
| Understand publications, sections, blocks | [What is an Omnipub](https://cashmere.io/docs/guides/omnipub.md) |
| Connect the MCP server to Claude | [Connecting MCP to Claude](https://cashmere.io/docs/guides/developers/connecting-mcp-to-claude.md), or [with an API key](https://cashmere.io/docs/guides/developers/installing-private-content-app-in-claude.md) |
| Connect the MCP server to ChatGPT | [Connecting MCP to ChatGPT](https://cashmere.io/docs/guides/developers/connecting-mcp-to-chatgpt.md), [custom app](https://cashmere.io/docs/guides/developers/creating-custom-app-in-chatgpt.md) |
| See what the MCP tools do | [Cashmere MCP tools](https://cashmere.io/docs/guides/developers/cashmere-mcp-tools.md) |
| Let your users connect their own Cashmere account | [Cashmere Link (OAuth)](https://cashmere.io/docs/guides/developers/cashmere-link-oauth-overview.md) |
| Report usage back, or read your usage | [Usage data via API](https://cashmere.io/docs/guides/developers/usage-data-via-api.md) |

## Set up access

- **Base URL:** `https://cashmere.io/api/v2`. Auth is
  `Authorization: Bearer <key>`.
- **Keep the key out of code and transcripts.** Read it from the
  `CASHMERE_API_KEY` environment variable. Never print it, log it, commit it,
  or send it to a browser. In a web app, call Cashmere from the server.
- **No key yet?** The user creates one at
  `https://cashmere.io/settings/api-keys`. You cannot do this for them. Ask,
  then wait. A Read-only key covers retrieval. Sending usage back with
  `POST /report` needs a Read & Write key.
- **Check what the key can do before debugging.** `GET /allowed-endpoints`
  returns the key's endpoint allowlist. A 403 that starts with
  "Insufficient permissions" means the key, not your code.
- **Keys belong to an organization, and they only see licensed content.** A
  key with no collections attached sees every collection its organization is
  licensed for. Attaching collections narrows it. Empty search results usually
  mean the key has no license to that content, not that the query is wrong.

## Find the useful shape

Start from what the user's product must show or decide, then pick the
smallest retrieval that serves it. Keep ranking rules, thresholds and
formatting in code.

- **Retrieve passages for an answer (RAG).** `GET /search` returns ranked
  passages with `score`, publication and section labels, and a
  `view_source_url`. Filter by collection or publication when the product is
  scoped. Threshold on `score` using the user's own queries, not a constant
  from an example.
- **Research across sources, then read deeply.** Find the few relevant
  publications, read their table of contents, then read the sections that
  matter. Over MCP this is `find_relevant_sources` → `get_table_of_contents`
  → `get_section`. Over REST it is `/search`, then `GET /omnipub/{uuid}`
  (its `nav` is the TOC), then the section or `/content` endpoints.
- **Browse a catalog.** `GET /omnipubs` lists publications, with filters for
  collection, tag, external ID and text. Use it to build pickers, not to
  find passages.
- **Scope an agent to one licensed collection.** Prefer a key restricted to
  that collection over a `collection` filter the agent could drop. The key is
  the boundary; a filter is only a preference.
- **Let end users bring their own access.** Use Cashmere Link: OAuth
  (authorization code + PKCE) whose access token is a Cashmere API key bound
  to the collections the user chose.
- **Hand an agent the MCP server instead of writing tools.** If the product
  is itself an MCP client, connect `https://mcp.cashmere.io` and skip the
  REST integration. Tool names and parameters come from the server's tool
  list. Trust that list over this skill.

For an open-ended request, offer the two or three shapes that fit and
recommend one. For a concrete request, pick the shape and build.

## Cite, and respect the license

- **Every answer built on Cashmere content links to its source.** Show the
  `view_source_url` from the response, next to the claim it supports. Do not
  rewrite it or replace it with a URL you built.
- **`view_source_url` is a short link with a lifetime.** It may expire after
  first use. Do not cache it for long. Run the search again to get a fresh
  link. The search docs give the exact rules.
- **Reads are metered.** Search, section reads and content reads are counted
  against the license. Fetch what the answer needs, not whole books "just in
  case". Do not crawl, mirror or archive content, and do not use it to train
  models. The terms of service forbid all of these.
- **Report citations when the product cites.** If the integration knows which
  passages ended up in an answer, report them with `POST /report` so the
  publisher's numbers reflect real use.

## Verify before you hand it over

- Make one real call with the user's key and show the result: status code,
  result count, one title, one `view_source_url`. An empty list from a valid
  key is still a pass for the wiring. Say that the content scope may be empty,
  and name the reason.
- When a call fails, read the `detail` in the error body before changing
  code. 401 is a bad or missing key. 402 is a token or billing limit. 403 is
  key permissions or a redistribution restriction. 422 is a bad parameter.
- Never tell the user the API cannot do something until you have checked the
  spec. Parameters are added more often than this skill is updated.
