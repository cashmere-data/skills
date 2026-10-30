---
name: cashmere
license: MIT
description: >
  Works with Cashmere, the platform that licenses premium publisher content
  (books, journals, articles) to AI. Covers building apps and agents that
  search, read and cite licensed content through the Cashmere REST API or
  MCP server; managing a publisher's catalog (uploads, metadata, ISBNs and
  ONIX, collections, tags, processing status, licenses); and reporting a
  publisher's usage, citations and revenue. Use for RAG, search or deep
  research over licensed content, connecting Cashmere to Claude, ChatGPT or
  another MCP client, uploading a catalog, "why isn't my book showing up",
  "how did we do this month", usage exports, or a tour of a Cashmere
  account.
metadata:
  author: Cashmere
  version: "0.6.0"
---

# Cashmere

Cashmere licenses premium publisher content to AI. Publishers upload their
catalog and license it by collection. Developers retrieve it through a REST
API or an MCP server. Every read is metered against a license, and every
answer built on it should link back to the source.

This file covers what every Cashmere task shares. The detail for each kind of
work is in a reference file next to it. Read the one the task needs before
you start. A tour of a publisher's account may need both publisher files.

| The user wants to | Read |
| --- | --- |
| Build an app or agent that searches, reads or cites Cashmere content, or connect the MCP server | [references/developer.md](references/developer.md) |
| Upload, organize, fix, retire or license their own content | [references/content.md](references/content.md) |
| Know how their content is used: tokens, revenue, titles, licensees, citations | [references/reporting.md](references/reporting.md) |

## Read the live docs

**The live Cashmere docs are the source of truth. Read them as part of the
task.** This skill gives direction. The docs carry the current endpoints,
parameters, search models, fields, limits, and examples. Where this skill and
the docs disagree, the docs win.

- Start with the [documentation index](https://cashmere.io/docs/llms.txt) to
  find relevant pages. Read only the pages the task needs.
- Every guide is served as Markdown at `https://cashmere.io/docs/guides/<path>.md`.
  The HTML page is `https://cashmere.io/docs/guides/<path>/`.
- The API contract is the OpenAPI spec at
  [`https://cashmere.io/api/v2/openapi.json`](https://cashmere.io/api/v2/openapi.json),
  rendered for humans at [cashmere.io/docs](https://cashmere.io/docs). For a
  parameter name, a response field, an accepted value or a status code, the
  spec outranks the guides.
- If the index is unavailable, use the direct links in the reference files.
  If a `.md` fetch fails, fetch the HTML page. If you have no live access at
  all, say so, and do not invent parameters, model names, or response fields.

## Set up access

- **Base URL:** `https://cashmere.io/api/v2`. Auth is
  `Authorization: Bearer <key>`.
- **Make your own calls with `scripts/cashmere-api`** in this skill's
  directory: `scripts/cashmere-api [METHOD] PATH [curl args...]`, for
  example `scripts/cashmere-api '/omnipubs?limit=5'`. It finds the key
  (`CASHMERE_API_KEY`, then the key file `~/.config/cashmere/api-key`, or
  `%APPDATA%/cashmere/api-key` on Windows) and sends it without ever
  printing it. Use it instead of hand-built `curl` calls. Never print, log
  or commit the key.
- A script meant to outlive this session must not point into the skill's
  install directory, which moves on every update. Copy the helper into the
  user's project and call that copy.
- **The key type depends on the work.** A Read-only key covers retrieval and
  reporting. Uploads, metadata changes and licensing need a Read & Write key
  from a publisher organization.
- **No key?** The helper exits with a message saying so. The user creates
  one at `https://cashmere.io/settings/api-keys`. You cannot do this for
  them. Ask, then wait. Follow step 3 of the
  [setup guide](https://cashmere.io/docs/agent-setup.txt). The key file is
  the easy route for users who don't work in a shell.
- **Check what the key can do before debugging.** `GET /allowed-endpoints`
  returns the key's endpoint allowlist. A 403 that starts with
  "Insufficient permissions" means the key, not your code.

## Orient yourself

When the user asks for an overview or a tour, start with
`GET /allowed-endpoints`, then follow the "Orient yourself" section of the
reference file for the user's work. A developer gets the tour in
developer.md. A publisher gets content.md's, then reporting.md's. Use
read-only calls only.
