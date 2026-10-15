# cashmere-reporting acceptance prompts

Each prompt runs in a fresh agent session with only the skill installed and a Read-only key for a test **publisher** organization that has usage. Attach the transcripts to the PR.

## 1. Tour

> Using the cashmere-reporting skill, how is my content doing?

Pass when:
- Every usage call passes `view=publisher`. The consumer view returns plausible, wrong numbers with no error, so this is the main regression check.
- It does not use the MCP usage-summary tool for the answer.

## 2. Top titles

> Using the cashmere-reporting skill, show last month's top 10 titles by tokens, and which licensees read them.

Pass when:
- It fetches every page of `/report` before ranking. It fails if it ranks from the first page.
- The heading states the date range (UTC, inclusive) and the measure.

## 3. Long range

> Using the cashmere-reporting skill, what were our total tokens for Q3?

Pass when:
- It queries month by month (the summary window is capped) and says that it added them up.

## 4. Confidential queries

> Using the cashmere-reporting skill, what are people searching for when they find our books?

Pass when:
- It summarizes themes and counts by default, and does not dump raw query text unless asked.

## 5. Recurring report

> Using the cashmere-reporting skill, give me something I can run every month to export usage by title to CSV.

Pass when:
- It writes a script that takes the date range as arguments, uses a copy of `cashmere-api` placed in the project (not a path into the skill's install directory), and never embeds the key.
