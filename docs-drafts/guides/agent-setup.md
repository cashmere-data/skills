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

Install the skills the user asked for. If they did not say, ask which ones,
and let them pick more than one: a publisher often wants both
`cashmere-content` and `cashmere-reporting`. If your agent has a
multiple-choice question tool, make it multi-select.

| Skill | For | Key it needs |
| --- | --- | --- |
| `cashmere-developer` | Developers building apps or agents that search, read and cite Cashmere content | Read-only |
| `cashmere-content` | Publishers uploading and managing content | Read & Write, publisher organization |
| `cashmere-reporting` | Publishers tracking usage and revenue | Read-only |

In the commands below, replace `<skill>` with the skill's name. Repeat the
install and verify steps for each skill chosen. The marketplace is added
only once.

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

## 3. Set up the API key

The skills look for a key in this order and use the first one they find:

1. The `CASHMERE_API_KEY` environment variable.
2. The key file: `~/.config/cashmere/api-key` on Linux and macOS
   (`$XDG_CONFIG_HOME/cashmere/api-key` if that is set), or
   `%APPDATA%\cashmere\api-key` on Windows. It holds the key alone on one
   line, and nothing else.

Check both without printing the key:

```
test -n "$CASHMERE_API_KEY" && echo "env: set" || echo "env: missing"
test -s ~/.config/cashmere/api-key && echo "file: set" || echo "file: missing"
```

If either is set, confirm that the key works. This prints the key's
permissions, not the key. With the environment variable:

```
printf 'Authorization: Bearer %s\n' "$CASHMERE_API_KEY" | curl -sS -H @- https://cashmere.io/api/v2/allowed-endpoints
```

With the key file:

```
printf 'Authorization: Bearer %s\n' "$(cat ~/.config/cashmere/api-key)" | curl -sS -H @- https://cashmere.io/api/v2/allowed-endpoints
```

The header goes through stdin so that the key never appears in a command
line or a transcript.

If no key is found, or it is the wrong type for the skill (see the table in
step 1), help the user set one up. Pick the route by who the user is:

- **Developers** usually manage environment variables already. Ask them to
  set `CASHMERE_API_KEY` in their shell profile or in the project's secret
  store.
- **Everyone else** should use the key file, which needs no shell knowledge.
  Create it empty, with permissions only the user can read, then hand it
  over:

  ```
  mkdir -p ~/.config/cashmere && touch ~/.config/cashmere/api-key && chmod 600 ~/.config/cashmere/api-key
  ```

  On Windows, create `%APPDATA%\cashmere\api-key` instead.

> **User step.** Ask the user to create a key at
> `https://cashmere.io/settings/api-keys`, then either set the environment
> variable or paste the key into the key file and save it. Give them the
> file's full path, and offer to open it in a graphical editor (`xdg-open`
> on Linux, `open -t` on macOS, `notepad` on Windows). Do not suggest a
> terminal editor run through the agent, such as Claude Code's `!` prefix:
> it has no terminal, so `vim` or `nano` fails. A terminal editor in the
> user's own terminal window is fine. Never ask them to
> paste the key into the chat, never write the key yourself, and never print
> it. When they say it is done, run the check above again.

A key is not needed to finish installing. Without one, report the skill as
installed and the key as a user step.

## 4. Optional: connect the Cashmere MCP server

Only for `cashmere-developer`, and only if the user wants Cashmere tools
inside the agent itself. The content and reporting skills need the REST API. Building an app against the
REST API does not need it. The MCP server uses its own sign-in, so it works
without an API key.

In Claude Code, add it for the user, not just this project:

```
claude mcp add --transport http -s user cashmere https://mcp.cashmere.io
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
claude mcp add --transport http -s user cashmere https://mcp.cashmere.io --header "Authorization: Bearer $CASHMERE_API_KEY"
```

## Report the result

Report only what you verified. Do not mark anything done that you could not
confirm.

```
Cashmere agent setup
  ✓ <skill>        installed (Claude Code plugin | skills.sh)
  ⚠ API key        no key in CASHMERE_API_KEY or the key file (user step)
  – MCP server     not requested
```

Use `✓` for verified, `⚠` for needs the user, `✗` for failed, and `–` for
skipped. After the block, give the specific next action for every line that
is not `✓`.

If the key works, end by offering a tour, which works in any folder: "Want
an overview of your Cashmere account and a tour of what you can do with it?"
If the user says yes, follow the skill's "Orient yourself" section.

## Updating

- Claude Code: `claude plugin marketplace update cashmere`, then
  `claude plugin update <skill>@cashmere`, then `/reload-plugins`.
- Other agents: `npx -y skills update`.

If an agent invents API fields or uses parameters the API rejects, the skill
may be out of date. Update it and try again.
