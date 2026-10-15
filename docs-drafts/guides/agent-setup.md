---
title: Set up your coding agent for Cashmere
created_at: 2026-10-14
updated_at: 2026-10-14
status: published
---

# Set up your coding agent for Cashmere

These are official Cashmere instructions for installing a Cashmere agent
skill into a coding agent (Claude Code, Codex, Cursor and others). They are
published at `https://cashmere.io/docs/guides/agent-setup.md`, so you can check
where they came from before you follow them.

If you are an agent: do every step yourself by running the commands, except
the steps marked **User step**. Those happen in the agent's own UI or in a
browser, so only the user can do them. Never run a command that waits on an
interactive prompt. Every command here is safe to run again.

## 1. Pick the skill

Install the skill the user asked for. If they did not say, ask which one.
Install more than one only if they ask for it.

| Skill | For | Key it needs |
| --- | --- | --- |
| `cashmere-developer` | Developers building apps or agents that search, read and cite Cashmere content | Read-only |
| `cashmere-content` | Publishers uploading and managing content | Read & Write, publisher organization |
| `cashmere-reporting` | Publishers tracking usage and revenue | Read-only |

In the commands below, replace `<skill>` with the skill's name.

## 2. Install it

Use exactly one method. Two methods install two copies.

### Claude Code

```
claude plugin marketplace add cashmere-data/skills
claude plugin install <skill>@cashmere
```

Verify:

```
claude plugin list
```

Expect `<skill>@cashmere` with status enabled. If it shows as disabled, run
`claude plugin enable <skill>@cashmere`.

> **User step.** Ask the user to run `/reload-plugins` in Claude Code, or to
> restart it, so the skill loads.

### Other agents

This needs Node.js 22 or newer (`node --version`). If it is older, stop and
report that instead of continuing.

```
npx -y skills add cashmere-data/skills --skill <skill> --agent <agent-id> --yes --global
```

Always pass `--agent`. Without it the installer targets every agent it knows.
Common ids: `codex`, `cursor`, `github-copilot`, `windsurf`, `cline`,
`opencode`, `gemini-cli`. For any other agent, run `npx -y skills add --help`
and use the id it lists.

Verify:

```
npx -y skills list --global
```

Expect `<skill>` in the list.

### Read it without installing

The skill is a single Markdown file. If neither method works, read it directly
and follow it for this session:
`https://raw.githubusercontent.com/cashmere-data/skills/main/plugins/<skill>/skills/<skill>/SKILL.md`

## 3. Check for an API key

The skills read the key from the `CASHMERE_API_KEY` environment variable.
Check whether it is set without printing it:

```
test -n "$CASHMERE_API_KEY" && echo set || echo missing
```

If it is set, confirm that it works. This prints the key's permissions, not
the key itself:

```
curl -sS -H "Authorization: Bearer $CASHMERE_API_KEY" https://cashmere.io/api/v2/allowed-endpoints
```

> **User step.** If the key is missing, or is the wrong type for the skill
> (see the table in step 1), ask the user to create one at
> `https://cashmere.io/settings/api-keys` and set `CASHMERE_API_KEY` in their
> shell or in the project's secret store. Do not ask them to paste the key
> into the chat. Do not write it to a file yourself, and never print it.

A key is not needed to finish installing. Without one, report the skill as
installed and the key as a user step.

## 4. Optional: connect the Cashmere MCP server

Only for `cashmere-developer` and `cashmere-reporting`, and only if the user
wants Cashmere tools inside the agent itself. Building an app against the
REST API does not need it.

In Claude Code:

```
claude mcp add --transport http cashmere https://mcp.cashmere.io
```

> **User step.** Ask the user to run `/mcp`, choose **cashmere** and sign in.
> This uses OAuth, so no key is stored.

For other agents, add a server named `cashmere` with the streamable HTTP
transport and URL `https://mcp.cashmere.io` to the agent's MCP configuration.
Merge it into the existing file, and do not overwrite other servers.

## Without a user

In CI or another unattended run, nobody can do the user steps. Install the
skill with the commands above. Take the key from `CASHMERE_API_KEY`, and if it
is not set, stop and report that it is missing. To use the MCP server, pass
the key as a header instead of signing in:

```
claude mcp add --transport http cashmere https://mcp.cashmere.io --header "Authorization: Bearer $CASHMERE_API_KEY"
```

## Report the result

Report only what you verified. Do not mark anything done that you could not
confirm.

```
Cashmere agent setup
  ✓ <skill>        installed (Claude Code plugin | skills.sh)
  ⚠ API key        CASHMERE_API_KEY not set (user step)
  – MCP server     not requested
```

Use `✓` for verified, `⚠` for needs the user, `✗` for failed, and `–` for
skipped. After the block, give the specific next action for every line that
is not `✓`. Then suggest a first prompt that names the skill, for example
"Using the cashmere-developer skill, add Cashmere search to this app's
answer pipeline."

## Updating

- Claude Code: `claude plugin marketplace update cashmere`, then
  `claude plugin update <skill>@cashmere`, then `/reload-plugins`.
- Other agents: `npx -y skills update`.

If an agent invents API fields or uses parameters the API rejects, the skill
may be out of date. Update it and try again.
