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
- **No key yet? Explain before you send the user anywhere.** The helper
  exits with a message saying so. Do not just repeat it. Tell the user, in a
  few sentences:
  - **What a key is.** It connects this agent to their Cashmere
    organization. It reads only the content that organization has licensed,
    and its reads are metered against the organization's credits.
  - **Why the skill needs one.** Every API call carries it. Exploring
    through the MCP connector needs no key (see below).
  - **How to get one**, depending on where they are:
    - No Cashmere account: sign up at `https://cashmere.io/accounts/signup`.
      New accounts get free starter credits, and the onboarding that follows
      signup offers collections that are free to license, then creates a
      first key.
    - An account with nothing licensed yet:
      `https://cashmere.io/discover` lists the collections they can
      license. Some are free and granted at once, and others wait for the
      publisher's approval. Then create a key.
    - Otherwise: `https://cashmere.io/settings/api-keys`.

  You cannot create the key for them, and they should never paste it into
  the chat. Then wait.
- **Where the key goes.** Pick one place for the user and give them its
  exact full path:
  - **Most people: the key file.** Create it empty, readable only by the
    user: `mkdir -p ~/.config/cashmere && touch ~/.config/cashmere/api-key && chmod 600 ~/.config/cashmere/api-key`
    (on Windows, `%APPDATA%\cashmere\api-key`). Ask them to paste the key
    into it alone on one line, with no quotes and no `KEY=`, and save.
    Offer to open it in a graphical editor (`xdg-open` on Linux, `open -t`
    on macOS, `notepad` on Windows).
  - **Developers who manage environment variables:** `CASHMERE_API_KEY`,
    in their shell profile or the project's secret store.

  When they say it is done, confirm with `scripts/cashmere-api /allowed-endpoints`.
  Step 3 of the [setup guide](https://cashmere.io/docs/agent-setup.txt)
  has the details.
- **Check what the key can do before debugging.** `GET /allowed-endpoints`
  returns the key's endpoint allowlist. A 403 that starts with
  "Insufficient permissions" means the key, not your code.

## The API or the MCP server

Cashmere has two ways in, for different jobs. When the user asks why they
would want the MCP server, explain it this way:

- **The REST API** is what this skill uses, and what code you write for the
  user calls. It does everything: search, reading, uploads, licensing and
  usage reports. It needs an API key.
- **The MCP server** (`https://mcp.cashmere.io`) gives a chat app or agent
  Cashmere tools of its own: search, publications, collections and a usage
  summary. The user signs in with OAuth, so no key is stored. Suggest it
  when they want to ask questions of licensed content inside Claude, ChatGPT
  or another MCP client, or to look around before building. It is read-only,
  so it cannot upload, manage licenses or produce a publisher's reports.

Neither replaces the other, and the skill works without the MCP server.

## Orient yourself

When the user asks for an overview or a tour, start with
`GET /allowed-endpoints`, then follow the "Orient yourself" section of the
reference file for the user's work. A developer gets the tour in
developer.md. A publisher gets content.md's, then reporting.md's. Use
read-only calls only.
