# Agent Project Playbook

Bootstrap new software projects with agent-safe rules, setup tiers, notes/control structure, and PR/version discipline for Codex + Claude Code.

This repo is a public-safe starter playbook. It is not a framework and it is not a runtime. Use it as a reference when starting a new repo, adding agent instructions to an existing project, or deciding how much process a project actually needs.

## What It Gives You

- Setup tiers for lightweight utility repos, medium product repos, and high-risk production systems.
- Agent rules for Codex, Claude Code, and parallel agent work.
- Notes/control structure for projects that need persistent private memory.
- Branching, worktree, version, changelog, and PR discipline.
- Handoff prompts for asking an agent to apply the playbook.
- Templates for `AGENTS.md`, `CLAUDE.md`, changelogs, version files, PowerShell helpers, and GitHub Actions.
- Brain-first knowledge guidance for keeping agents useful without loading a whole notes vault every run.
- Optional Claude Code launch profiles for fast local-first sessions without skipping `CLAUDE.md` routing.

## Quick Start

1. Read [docs/getting-started.md](docs/getting-started.md).
2. Choose a tier with [docs/setup-tiers.md](docs/setup-tiers.md).
3. Copy the relevant templates from [templates/](templates/).
4. Fill every placeholder such as `<PROJECT_NAME>`, `<DEFAULT_BRANCH>`, and `<NOTES_VAULT_PATH>`.
5. Run the sanitize check before publishing or committing adapted files.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sanitize-check.ps1
```

Or with PowerShell 7:

```powershell
pwsh ./scripts/sanitize-check.ps1
```

## Recommended Reading Order

1. [Getting Started](docs/getting-started.md)
2. [Setup Tiers](docs/setup-tiers.md)
3. [Agent Rules](docs/agent-rules.md)
4. [GitHub Workflow](docs/github-workflow.md)
5. [Notes / Control Structure](docs/notes-control-structure.md)
6. [Brain-First Project Knowledge](docs/agent-knowledge.md)
7. [Claude Profiles](docs/claude-profiles.md)
8. [Handoff Prompts](docs/handoff-prompts.md)

## Repository Layout

```text
agent-project-playbook/
  docs/        # public guidance
  templates/   # copy/adapt into target projects
  examples/    # fictional examples
  scripts/     # public-safety checks
```

## What Not To Copy Blindly

Do not copy the Tier 3 setup into every project. Start with the smallest tier that fits the risk.

Do not commit private notes, session logs, credentials, local paths, production hostnames, client names, or project-specific operating procedures into public repos.

Do not treat generated summaries as truth. Keep source markdown as the authority and cite it when agents use it.

## Companion Skills

This playbook pairs well with [McStacks Codex Claude Skills](https://github.com/cmm219/mcstacks-codex-claude-skills), especially `claude-readonly-review`, `claude-design-loop`, `pr-batching`, `prd-review-loop`, and `prd-ship-loop`.

The repos are separate on purpose:

- This repo defines project structure and operating rules.
- The skills repo defines agent behaviors Codex can invoke.

## License

MIT
