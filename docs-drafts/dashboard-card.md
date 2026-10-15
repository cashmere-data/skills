# Dashboard card: "Use Cashmere from your coding agent"

Copy this into your agent:

**Developers**

    Set up the Cashmere developer skill for me: fetch and follow https://cashmere.io/docs/agent-setup.txt

**Publishers (content management)**

    Set up the Cashmere content management skill for me: fetch and follow https://cashmere.io/docs/agent-setup.txt

**Publishers (reporting)**

    Set up the Cashmere reporting skill for me: fetch and follow https://cashmere.io/docs/agent-setup.txt

`https://cashmere.io/docs/agent-setup.txt` serves `guides/agent-setup.md` as plain text. The agent maps "developer", "content management" and "reporting" to the skill names using the table in the guide's step 1.

Show the publisher rows only to publisher organizations. Every row gets a copy button (reuse the clipboard pattern in `ApiCallPanel.tsx`). Candidate homes: the onboarding hero on Home (`OnboardingHero.tsx`) and a new "Agent skills" section on `/integrations/` (`IntegrationsOverview.tsx`).
