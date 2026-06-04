# Agent Project Playbook

Bootstrap new software projects with agent-safe rules, setup tiers, notes/control structure, and PR/version discipline for Codex + Claude Code.

This repo is a public-safe starter playbook. It is not a framework and it is not a runtime. Use it as a reference when starting a new repo, adding agent instructions to an existing project, or deciding how much process a project actually needs.

## Who This Is For

Use this if you work with coding agents and want new projects to start with clear rules for scope, safety, memory, PRs, versions, and handoffs.

It is especially useful when:

- more than one agent or chat may touch the same repo,
- the project needs durable notes without loading a whole notes vault every session,
- PRs need predictable version/changelog discipline,
- production deploys need exact-SHA verification,
- you want Codex and Claude Code to cooperate without blurring who owns edits and QA.

## Is This For You, Or Do You Want GBrain?

This playbook is local-first: plain markdown, a tiny routing rule, and the agent reads the 1-3 right files. No database, no server, and no tokens in the retrieval path, and it works the moment you clone a repo. That keeps day-to-day sessions fast and deterministic.

If instead you need a database-backed brain that synthesizes answers across a very large, cross-domain corpus — or a shared team brain with scoped access — Garry Tan's [GBrain](https://github.com/garrytan/gbrain) is built for exactly that, and the two compose well.

See [Local-First Routing vs. a Database-Backed Brain](docs/gbrain-vs-playbook.md) for an honest side-by-side, pros and cons, and how to run both — and [How It Works, With Evidence](docs/how-it-works-evidence.md) for a zero-token way to prove the local-first approach is actually firing.

## What It Gives You

- Setup tiers for lightweight utility repos, medium product repos, and high-risk production systems.
- Agent rules for Codex, Claude Code, and parallel agent work.
- Notes/control structure for projects that need persistent private memory.
- Branching, worktree, version, changelog, and PR discipline.
- Handoff prompts for asking an agent to apply the playbook.
- Templates for `AGENTS.md`, `CLAUDE.md`, changelogs, version files, PowerShell helpers, and GitHub Actions.
- Brain-first knowledge guidance for keeping agents useful without loading a whole notes vault every run.
- Optional Claude Code launch profiles for fast local-first sessions without skipping `CLAUDE.md` routing.

## How To Use The Pieces

| Piece | Use It When | Start Here |
| --- | --- | --- |
| Setup tiers | You are deciding how much process a repo needs | [docs/setup-tiers.md](docs/setup-tiers.md) |
| Agent rules | You want Codex/Claude to know the repo boundaries | Codex: [AGENTS.md.template](templates/AGENTS.md.template), Claude Code: [CLAUDE.md.template](templates/CLAUDE.md.template) |
| GitHub workflow | You need branch, PR, cleanup, release, or deploy discipline | [docs/github-workflow.md](docs/github-workflow.md) |
| Notes/control | A project needs private state, task pointers, and session history | [docs/notes-control-structure.md](docs/notes-control-structure.md) |
| Version scripts | Multiple PRs may claim versions at the same time | [templates/scripts/claim_version.ps1.template](templates/scripts/claim_version.ps1.template) |
| Cleanup script | You use worktrees and want safe post-merge cleanup | [templates/scripts/cleanup_after_merge.ps1.template](templates/scripts/cleanup_after_merge.ps1.template) |
| Knowledge routing | Agents need prior project knowledge without a database/MCP hot path | [docs/agent-knowledge.md](docs/agent-knowledge.md) |
| Claude profiles | You want repeatable lean/heavy Claude Code launch commands | [docs/claude-profiles.md](docs/claude-profiles.md) |
| Handoff prompts | You want an agent to port the setup into another repo | [docs/handoff-prompts.md](docs/handoff-prompts.md) |
| Local-first vs GBrain | You are deciding between zero-infra routing and a database-backed brain | [docs/gbrain-vs-playbook.md](docs/gbrain-vs-playbook.md) |
| Proof it works | You want the mechanism plus a zero-token way to measure adoption | [docs/how-it-works-evidence.md](docs/how-it-works-evidence.md) |

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
9. [Local-First Routing vs. a Database-Backed Brain](docs/gbrain-vs-playbook.md)
10. [How It Works, With Evidence](docs/how-it-works-evidence.md)

## Repository Layout

```text
agent-project-playbook/
  docs/        # public guidance
  templates/   # copy/adapt into target projects
  examples/    # fictional examples
  scripts/     # public-safety checks
```

## Common Starting Points

- Small public utility: use [examples/tier1-minimal](examples/tier1-minimal/) and skip notes/control/version scripts unless needed.
- Ongoing app or website: use [examples/tier2-standard](examples/tier2-standard/) and add notes/control if project memory matters.
- High-risk production system: use [Tier 3](docs/setup-tiers.md#tier-3-high-risk-production-system), including version scripts, worktrees, exact-SHA deploy rules, and cleanup discipline.
- Existing repo that only needs version tracking: use Prompt 3 in [docs/handoff-prompts.md](docs/handoff-prompts.md).

## Versioning Note

The playbook includes templates for four-segment operational versioning: `major.minor.patch.micro`. That is intentional for projects with many small agent-driven PRs where docs, cleanup, patches, and larger feature work should be distinguishable without overloading patch releases.

| Segment | Use For |
| --- | --- |
| `major` | Breaking platform, API, auth, data-contract, or stable milestone changes |
| `minor` | Meaningful new capabilities, integrations, workflows, or major UX direction |
| `patch` | Bug fixes and behavior corrections |
| `micro` | Very small shipped changes such as docs, copy, cleanup, styling polish, or low-risk internal adjustments |

Example: `0.1.2.3` means pre-1.0 work, first minor line, second patch line, third micro change after that patch.

This is not strict three-segment SemVer. Small public repos or packages whose tooling expects SemVer can use normal `major.minor.patch` tags and GitHub Releases instead. The first playbook releases were published close together because this repo was extracted, sanitized, documented, and released in one pass; each release has notes, but future releases should be less frequent and more bundled.

## What Not To Copy Blindly

Do not copy the Tier 3 setup into every project. Start with the smallest tier that fits the risk.

Do not commit private notes, session logs, credentials, local paths, production hostnames, client names, or project-specific operating procedures into public repos.

Do not treat generated summaries as truth. Keep source markdown as the authority and cite it when agents use it.

## Companion Skills

This playbook pairs well with [McStacks: Codex Claude Skills](https://github.com/cmm219/mcstacks-codex-claude-skills), especially `claude-readonly-review`, `claude-design-html`, `claude-design-loop`, `pr-batching`, `prd-review-loop`, and `prd-ship-loop`.

The repos are separate on purpose:

- This repo defines project structure and operating rules.
- The skills repo defines agent behaviors Codex can invoke.

## License

MIT
