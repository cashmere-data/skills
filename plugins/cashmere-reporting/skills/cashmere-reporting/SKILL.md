---
name: cashmere-reporting
license: MIT
description: >
  Answers a publisher's questions about how its content is used on Cashmere:
  tokens consumed, billed revenue, which titles and sections are read, which
  licensees and AI apps use them, which queries lead to them, and how often
  they are cited, over any date range. Builds recurring reports, spreadsheets
  and CSV exports from the Cashmere usage API. Use for "how did we do this
  month", "top titles by licensee", "export Q3 usage", reconciling an
  invoice, or a tour of a publisher's usage. For uploading or fixing content
  use cashmere-content; for building apps that read Cashmere content use
  cashmere-developer.
metadata:
  author: Cashmere
  version: "0.5.0"
---

# Report on Cashmere usage

Every time a licensed AI product searches or reads a publisher's content,
Cashmere records a usage event: who read what, under which license, how many
tokens, and what it cost. This skill turns those events into the numbers a
publisher asks for.

**Usage rows can include licensee names and the search queries their users
typed. Treat query text as the licensee's confidential data.** Summarize it
(top themes, counts) unless the user asks for the raw queries, and keep raw
exports out of anything shared outside the publisher.

## Read the live docs

**The live Cashmere docs are the source of truth. Read them as part of the
task.** This skill gives direction. The docs carry the current fields,
filters and limits. Where this skill and the docs disagree, the docs win.

- Start with [Usage data via API](https://cashmere.io/docs/guides/developers/usage-data-via-api.md),
  then the `/report` endpoints in
  [`https://cashmere.io/api/v2/openapi.json`](https://cashmere.io/api/v2/openapi.json).
  The spec outranks the guide on field names and filters.
- The [documentation index](https://cashmere.io/docs/llms.txt) lists every
  other page.
- If a `.md` fetch fails, fetch the HTML page. With no live access, say so
  and do not invent fields or totals.

## Set up access

- **A Read-only key is enough** and is the right choice for reporting. The
  user creates it at `https://cashmere.io/settings/api-keys`. You cannot.
- **Make every call with `scripts/cashmere-api`** in this skill's directory:
  `scripts/cashmere-api [METHOD] PATH [curl args...]`, for example
  `scripts/cashmere-api '/report/summary?view=publisher&start_date=2026-09-01'`.
  It finds the key (`CASHMERE_API_KEY`, then the key file
  `~/.config/cashmere/api-key`, or `%APPDATA%/cashmere/api-key` on Windows)
  and sends it without printing it. Never print, log or commit the key.
  A script meant to outlive this session must not point into the skill's
  install directory, which moves on every update. Copy the helper into the
  user's project and call that copy.
- **No key?** The helper exits with a message saying so. Follow step 3 of
  the [setup guide](https://cashmere.io/docs/agent-setup.txt). The key
  file is the easy route for users who don't work in a shell.
- **Do not answer publisher questions with the MCP usage-summary tool**
  unless its tool list shows a publisher view. It reports what the signed-in
  organization *consumed*, not who consumed its content. Use the REST API.
- **Ask for the publisher view.** The usage endpoints default to the
  *consumer* view (what this organization read). A publisher asking about
  its own content needs `view=publisher` (who read our content). Using the
  wrong view returns real but unrelated numbers, and nothing errors to warn
  you.

## Orient yourself

When the user asks for an overview or a tour, start with the numbers they
will care about:

1. `GET /report/summary` with `view=publisher`, for this month and for last
   month: tokens, events, and the date of the first and last event.
2. If there is usage, page through last month's `GET /report` rows with
   `view=publisher`, and show the top titles and top licensees. Fetch every
   page before ranking anything.
3. If there is no usage at all, check `GET /omnipubs` with
   `view_mode=published` and `GET /licenses`. Nothing to report usually
   means no live titles or no licensees yet, so name which.

Then tour the questions you can answer (by title, licensee, app, day,
license right, citation), and offer to turn one into a recurring report.

## Pick the right endpoint

| Question | Use |
| --- | --- |
| A headline number for a period: tokens, events, date span | `GET /report/summary` |
| Anything broken down by title, licensee, app, day, license right, query or citation | `GET /report` (one row per usage event), then aggregate in code |

- **The summary covers a limited window** (a month at most; see the spec).
  For a longer period, query it month by month and add the results up, and
  say that you did.
- **`/report` is paginated.** Page through all of it with `limit` and
  `offset` before you aggregate. A report built from the first page is wrong,
  and it looks plausible. For long ranges, fetch one week or month at a time
  so a failure costs one window, not the whole run.
- Filter on the server where the API allows it (dates, license right,
  external IDs, API key, app). Aggregate everything else yourself.

## Get the numbers right

- **Dates are UTC and inclusive** at both ends. State the range you used in
  every report. "October" means `2026-10-01` to `2026-10-31`, not "the last
  30 days".
- **Name the measure.** Tokens consumed, billed dollars, usage events and
  citations are different numbers. Label every column with what it counts.
  Never call tokens "reads" or dollars "revenue" unless the user defined
  them that way.
- **Separate development traffic.** Rows from development keys are flagged.
  Report them separately or leave them out, and say which you did.
- **Citations are a subset.** A row counts as cited only when the consuming
  app reported that the passage appeared in an answer. Not every app reports
  citations, so a low citation count may mean low reporting, not low use.
- **The dashboard at `https://cashmere.io/reports` is the human view** of
  the same events. If the user compares your numbers with it and they
  differ, check the date range, the view, development traffic and the
  measure before assuming either side is wrong.

## Deliver

- Lead with the answer: the number or the top-N table, with the date range
  and the measure in the heading.
- Then show how it was produced: endpoint, filters, row count fetched. That
  way the user can rerun it next month.
- For a recurring report, write a small script that takes the date range as
  arguments and writes CSV. Do not hand back a one-off notebook.
- If the data cannot answer the question (for example, the API has no field
  for it), say so plainly and name the closest question it can answer.
