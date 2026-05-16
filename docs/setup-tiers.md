---
project: Agent Project Playbook
type: reference
section: setup-tiers
updated: 2026-05-14
---

# Setup Tiers

Pick the smallest setup tier that fits the project. Do not blindly copy the high-risk production setup into every repo.

## Tier 1: Light Public Utility Repo

Use for small public tools, skill packs, examples, libraries, docs repos, and portfolio utilities.

Examples:
- A public Codex skill pack
- A tiny CLI/helper repo
- A static demo or example repo

Repo should have:
- `README.md`
- `AGENTS.md`
- `CHANGELOG.md`
- `LICENSE`
- `SECURITY.md` when users may run local tooling
- `.github/workflows/validate.yml` or equivalent lightweight CI
- Release tags when publishing meaningful versions

Usually skip:
- Notes-vault control folder
- `VERSION` file
- `claim_version.ps1`
- version-uniqueness CI
- `.worktrees/` requirement
- deploy/runbook files

Use Git tags and GitHub releases for versioning unless the repo has active PR/version collision risk.

## Tier 2: Medium Product / Website Repo

Use for real websites, apps, marketing sites, prototypes with deploys, and repos that may get ongoing feature work.

Examples:
- Marketing site with Vercel deploy
- Blog/product site
- Prototype app with auth/API integrations

Repo should have:
- Tier 1 files
- `CLAUDE.md` and/or `AGENTS.md` with project-specific dev/deploy/design rules
- Notes-vault control folder if the project has ongoing memory/tasks
- `control/STATE.md`, `control/TASKS.md`, `control/CODEX_GUARDRAILS.md` in notes
- `tasks/backlog.md`, `tasks/archive/`, `sessions/`
- `VERSION` and version scripts only if release/version coordination matters
- Deploy notes if production deploys exist

Usually use normal branch/PR workflow. Worktrees are recommended for concurrent agents, but not mandatory for every tiny change.

## Tier 3: High-risk Production System

Use for money, balances, customer data, production databases, schedulers, messaging systems, payments, billing, imports, or irreversible operational changes.

Examples:
- Financial/accounting production app
- SaaS with tenant data
- Bot/scheduler system that sends real messages
- Any project where data mistakes are expensive

Repo should have the full setup:
- Tier 1 and Tier 2 files
- Notes-vault control folder
- Repo `CONTROL/` pointer stubs
- `VERSION`
- `CHANGELOG.md`
- `scripts/claim_version.ps1`
- `scripts/check_version_unique.ps1`
- `.github/workflows/version-check.yml`
- `scripts/check_control_hygiene.ps1`
- `.worktrees/<task>/` workflow for concurrent work
- Exact-SHA deploy protocol
- Guardrails for data/money/messaging risk
- Read-only audit or plan before production corrections

Every shipped PR should bump `VERSION` and `CHANGELOG.md` in the same commit.

## Decision Rule

Start with Tier 1. Upgrade only when the project needs the extra structure.

Ask these questions:

1. Will this repo deploy to production? If yes, consider Tier 2.
2. Will multiple agents work concurrently? If yes, add worktree rules.
3. Does it handle money, customer data, production DB writes, schedulers, or external sends? If yes, use Tier 3.
4. Does it need monotonic release/version coordination across PRs? If yes, add `VERSION` and version scripts.
5. Is it mainly a public utility/docs repo? If yes, keep Tier 1.

## Upgrade Path

It is fine to start light and add structure later:

- Tier 1 -> Tier 2: add notes control, deploy docs, and project-specific agent rules.
- Tier 2 -> Tier 3: add version scripts, exact-SHA deploy, worktree isolation, and high-risk guardrails.

Do not downgrade guardrails on a project that already handles high-risk production work.
