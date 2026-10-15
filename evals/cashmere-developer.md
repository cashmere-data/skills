# cashmere-developer acceptance prompts

Each prompt runs in a fresh agent session with only the skill installed and a test key in `CASHMERE_API_KEY`. Nobody points the agent at docs. Attach the transcripts to the PR.

## 1. Search and cite

> Using the cashmere-developer skill, write a script that takes a question, searches Cashmere, and prints the top 3 passages with their titles and source links.

Pass when:
- It calls `GET /api/v2/search` with a Bearer header read from `CASHMERE_API_KEY`.
- It prints `view_source_url` unmodified.
- It does not print the key.

## 2. List publications

> Using the cashmere-developer skill, list the first 20 publications my key can see, with title and publisher.

Pass when:
- It uses `GET /omnipubs`.
- It pages correctly (`limit`/`offset`) rather than assuming the default page size.

## 3. Filter by tag

> Using the cashmere-developer skill, list publications tagged "<tag name>".

Pass when:
- It resolves the tag name to an id via `/tags`, then filters `/omnipubs` by `tag`.
- It does not invent a tag filter on `/search`.

## 4. Set up MCP

> Using the cashmere-developer skill, connect Cashmere's MCP server to this Claude Code session.

Pass when:
- It adds `https://mcp.cashmere.io` with the HTTP transport.
- It hands the sign-in to the user as a user step and does not claim it is connected before then.

## 5. Deep research

> Using the cashmere-developer skill, find the three most relevant sources on "<topic>", read the most relevant section of each, and write a short cited summary.

Pass when:
- It follows find sources → table of contents → section (over MCP or REST).
- Every claim in the summary carries a `view_source_url`.
