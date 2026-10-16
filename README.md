# Cashmere agent skills

Agent skills for [Cashmere](https://cashmere.io), the platform that licenses premium publisher content to AI products.

| Skill | For |
|---|---|
| [cashmere-developer](plugins/cashmere-developer/skills/cashmere-developer/SKILL.md) | Developers building apps and agents that search, read and cite licensed content via the API and MCP server |
| [cashmere-content](plugins/cashmere-content/skills/cashmere-content/SKILL.md) | Publishers uploading, organizing and licensing content |
| [cashmere-reporting](plugins/cashmere-reporting/skills/cashmere-reporting/SKILL.md) | Publishers tracking usage, citations and revenue |

## Install

Using an AI agent? Ask it to "set up Cashmere agent skills: fetch and follow https://cashmere.io/docs/agent-setup.txt". It asks which skills you want, or name them in the prompt.

### Claude Code

```bash
claude plugin marketplace add cashmere-data/skills
claude plugin install cashmere-developer@cashmere
```

Swap in `cashmere-content` or `cashmere-reporting` as needed.

### Other agents via skills.sh

```bash
npx skills add cashmere-data/skills --skill cashmere-developer
```

Select your agent when prompted. Add `-g` to install globally.

Choose one installation method to avoid duplicate copies.

## Use

Name the skill in your prompt, for example:

> Using the cashmere-developer skill, add a Cashmere search tool to this agent and cite sources in its answers.

> Using the cashmere-content skill, upload every EPUB in ./catalog with its ISBN as the external ID, and tell me which ones failed.

> Using the cashmere-reporting skill, show last month's tokens and billed revenue by title and by licensee.

The skills point the agent at the live docs. Where a skill and the docs disagree, the docs win.

## Maintaining

- Each skill ships its own copy of `scripts/cashmere-api`, because installed plugins can't reach files outside their own directory. Keep the three copies identical.
- Bump `version` in the plugin's `plugin.json` and `metadata.version` in its `SKILL.md` together on every change. Installed copies only update when the version changes.
- Check manifests with `claude plugin validate .` and `claude plugin validate plugins/<plugin>`.
- Acceptance prompts for each skill are in `evals/`.

## Update

- Claude Code: `claude plugin marketplace update cashmere`, then `claude plugin update <skill>@cashmere`.
- skills.sh: `npx skills update`.
