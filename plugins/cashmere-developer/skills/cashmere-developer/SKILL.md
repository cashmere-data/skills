---
name: cashmere-developer
license: MIT
description: >
  Builds apps and agents on Cashmere, the licensed premium content platform
  (books, journals, articles): search, read and cite publications through
  the Cashmere REST API or MCP server, with API keys, collection scoping,
  Cashmere Link OAuth and citation rules. Use when writing code or agent
  tools that retrieve from Cashmere, adding RAG, search or deep research over
  licensed content, connecting Cashmere to Claude, ChatGPT or another MCP
  client, or when the user asks for a tour of their Cashmere account. For
  uploading content use cashmere-content; for usage and revenue numbers use
  cashmere-reporting.
metadata:
  author: Cashmere
  version: "0.5.1"
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
  The HTML page is `https://cashmere.io/docs/guides/<path>/`.
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
| Answer from search results with citations (RAG) | [Cookbook: RAG with citations](https://cashmere.io/docs/guides/developers/cookbooks/rag-with-citations.md) |
| Limit an agent to one licensed collection | [Cookbook: an agent scoped to one collection](https://cashmere.io/docs/guides/developers/cookbooks/agent-scoped-to-one-collection.md) |
| List or search publications by tag | [Cookbook: filter by tag](https://cashmere.io/docs/guides/developers/cookbooks/filter-by-tag.md) (`/search` has no tag filter) |
| Find sources, then read whole sections | [Cookbook: deep research over MCP](https://cashmere.io/docs/guides/developers/cookbooks/deep-research-over-mcp.md) (MCP and REST) |

## Set up access

- **Base URL:** `https://cashmere.io/api/v2`. Auth is
  `Authorization: Bearer <key>`.
- **Make your own calls with `scripts/cashmere-api`** in this skill's
  directory: `scripts/cashmere-api [METHOD] PATH [curl args...]`, for
  example `scripts/cashmere-api '/omnipubs?limit=5'`. It finds the key
  (`CASHMERE_API_KEY`, then the key file `~/.config/cashmere/api-key`) and
  sends it without ever printing it. Use it instead of hand-built `curl`
  calls.
- **Keep the key out of code and transcripts.** Code you write for the user
  reads `CASHMERE_API_KEY` from its environment. Never print the key, log
  it, commit it, or send it to a browser. In a web app, call Cashmere from
  the server.
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

## Orient yourself

When the user asks for an overview or a tour, or you need context before
building, read the account first. Use read-only calls only:

1. `GET /allowed-endpoints`: the key's type and endpoint scope.
2. `GET /collections` and `GET /licenses`: what the organization can read,
   and under which licenses.
3. `GET /omnipubs`: how many publications the key can see, and a few titles.
4. One `GET /search` on a topic taken from those titles, to prove retrieval
   end to end.

Report it as a short table, then tour what the user could build, using their
real collections and titles as the examples. If the key sees no
publications, say so first. Every search will come back empty until the
organization licenses a collection, and that, not the code, is the next
step.

## MCP tools or REST

The Cashmere MCP server exposes a read-only subset of the REST API (search,
publications, collections, a usage summary) behind an OAuth sign-in. If its
tools are connected in this session:

- **Use them to explore.** Look at real content, check what a key can see,
  and try a query before writing code around it. No key is needed.
- **Build on REST.** The MCP tools exist only inside your session. Code you
  ship calls the REST API with its own key, or connects to the MCP server
  itself if the product is an MCP client. Never ship code that assumes your
  session's tools.

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
- **Repeat list parameters.** `fields`, `collection`, `tag`,
  `omnipub_uuids` and similar list parameters take one value per occurrence
  (`collection=1&collection=2`), and that form works everywhere. Don't
  comma-join `fields`: a joined value is read as one field name, matches
  nothing, and is ignored without an error. `external_ids` is the exception:
  it is a comma-separated string.
- When a call fails, read the `detail` in the error body before changing
  code. 401 is a bad or missing key. 402 is a token or billing limit. 403 is
  key permissions or a redistribution restriction. 422 is a bad parameter.
- Never tell the user the API cannot do something until you have checked the
  spec. Parameters are added more often than this skill is updated.
