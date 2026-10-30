# cashmere acceptance prompts

Each prompt runs in a fresh agent session with only the skill installed. Nobody points the agent at docs. Attach the transcripts to the PR.

## Developer

Use a test key in `CASHMERE_API_KEY`.

### 1. Search and cite

> Using the cashmere skill, write a script that takes a question, searches Cashmere, and prints the top 3 passages with their titles and source links.

Pass when:
- It reads references/developer.md.
- It calls `GET /api/v2/search` with a Bearer header read from `CASHMERE_API_KEY`.
- It prints `view_source_url` unmodified.
- It does not print the key.

### 2. List publications

> Using the cashmere skill, list the first 20 publications my key can see, with title and publisher.

Pass when:
- It uses `GET /omnipubs`.
- It pages correctly (`limit`/`offset`) rather than assuming the default page size.

### 3. Filter by tag

> Using the cashmere skill, list publications tagged "<tag name>".

Pass when:
- It resolves the tag name to an id via `/tags`, then filters `/omnipubs` by `tag`.
- It does not invent a tag filter on `/search`.

### 4. Set up MCP

> Using the cashmere skill, connect Cashmere's MCP server to this Claude Code session.

Pass when:
- It adds `https://mcp.cashmere.io` with the HTTP transport.
- It hands the sign-in to the user as a user step and does not claim it is connected before then.

### 5. Deep research

> Using the cashmere skill, find the three most relevant sources on "<topic>", read the most relevant section of each, and write a short cited summary.

Pass when:
- It finds sources, then reads a table of contents, then a section (over MCP or REST).
- Every claim in the summary carries a `view_source_url`.

## Content

Use a Read & Write key for a test **publisher** organization.

### 1. Tour

> Using the cashmere skill, give me an overview of my Cashmere catalog.

Pass when:
- It follows "Orient yourself" in references/content.md: key type, collections with counts, live titles, licenses/licensees.
- On a non-publisher org it says so first, and does not plan uploads.

### 2. Upload a small batch

> Using the cashmere skill, upload the three EPUBs in ./samples with their ISBNs (from the filenames) as external IDs into my "Test" collection, and tell me when they're searchable.

Pass when:
- Every call goes through `scripts/cashmere-api`, and the key never appears in the transcript.
- It polls status with back-off, and reports done only on an indexed status.
- It ends with a table (submitted, indexed, processing, failed, duplicates).

### 3. Duplicate

> Using the cashmere skill, upload ./samples/one.epub again.

Pass when:
- It reports the duplicate and the existing UUID as the answer, not as an error to retry.

### 4. Not searchable

> Using the cashmere skill, I uploaded a book yesterday but search can't find it. Why?

Pass when:
- It checks the status first, then licensing (a publisher sees its own titles in search only with a license), before blaming the upload.

### 5. Replace

> Using the cashmere skill, replace the content of the title with external ID 9780000000000 with ./samples/one-v2.epub.

Pass when:
- It confirms before retiring the old title, then uploads with the same external ID.
- It touches no title the user didn't name.

## Reporting

Use a Read-only key for a test **publisher** organization that has usage.

### 1. Tour

> Using the cashmere skill, how is my content doing?

Pass when:
- Every usage call passes `view=publisher`. The consumer view returns plausible, wrong numbers with no error, so this is the main regression check.
- It does not use the MCP usage-summary tool for the answer.

### 2. Top titles

> Using the cashmere skill, show last month's top 10 titles by tokens, and which licensees read them.

Pass when:
- It fetches every page of `/report` before ranking. It fails if it ranks from the first page.
- The heading states the date range (UTC, inclusive) and the measure.

### 3. Long range

> Using the cashmere skill, what were our total tokens for Q3?

Pass when:
- It queries month by month (the summary window is capped) and says that it added them up.

### 4. Confidential queries

> Using the cashmere skill, what are people searching for when they find our books?

Pass when:
- It summarizes themes and counts by default, and does not dump raw query text unless asked.

### 5. Recurring report

> Using the cashmere skill, give me something I can run every month to export usage by title to CSV.

Pass when:
- It writes a script that takes the date range as arguments, uses a copy of `cashmere-api` placed in the project (not a path into the skill's install directory), and never embeds the key.
