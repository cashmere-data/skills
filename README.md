# Cashmere agent skill

An agent skill for [Cashmere](https://cashmere.io), the platform that licenses premium publisher content to AI products.

One skill, [cashmere](plugins/cashmere/skills/cashmere/SKILL.md), covers all of it:

- **Building** apps and agents that search, read and cite licensed content through the API and MCP server.
- **Managing content**: uploading, organizing and licensing a publisher's catalog.
- **Reporting**: a publisher's usage, citations and revenue.

## Install

Using an AI agent? Ask it to "Set up the Cashmere agent skill for me: fetch and follow https://cashmere.io/docs/agent-setup.txt".

### Claude Code

```bash
claude plugin marketplace add cashmere-data/skills
claude plugin install cashmere@cashmere
```

### Claude Desktop and claude.ai

Open **Customize > Plugins**, choose **Add > Add marketplace > Add from a repository**, enter `cashmere-data/skills`, then install **cashmere** from it.

### Other agents via skills.sh

```bash
npx skills add cashmere-data/skills --skill cashmere
```

Select your agent when prompted. Add `-g` to install globally.

Choose one installation method to avoid duplicate copies.

## Use

Name the skill in your prompt, for example:

> Using the cashmere skill, add a Cashmere search tool to this agent and cite sources in its answers.

> Using the cashmere skill, upload every EPUB in ./catalog with its ISBN as the external ID, and tell me which ones failed.

> Using the cashmere skill, show last month's tokens and billed revenue by title and by licensee.

The skill points the agent at the live docs. Where the skill and the docs disagree, the docs win.

## Maintaining

- `SKILL.md` holds what every task shares. The detail for each kind of work lives in `references/`, which the agent reads only when the task needs it.
- Bump `version` in both `plugin.json` files and `metadata.version` in `SKILL.md` together on every change. Installed copies only update when the version changes.
- Every version bump needs a GitHub release carrying `dist/cashmere.zip` from `tools/build-zips.sh`. The setup guide links the latest release's zip.
- Check manifests with `claude plugin validate .` and `claude plugin validate plugins/cashmere`.
- Acceptance prompts are in `evals/`.

## Update

- Claude Code: `claude plugin marketplace update cashmere`, then `claude plugin update cashmere@cashmere`.
- skills.sh: `npx skills update`.
