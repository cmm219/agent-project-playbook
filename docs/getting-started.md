---
project: Agent Project Playbook
type: guide
section: getting-started
updated: 2026-05-16
---

# Getting Started

Use this playbook when you are starting a new software project or adding agent-safe workflow rules to an existing repo.

## 1. Choose The Smallest Setup Tier

Start with [setup-tiers.md](setup-tiers.md).

- Tier 1: small public tools, examples, docs, skill packs, tiny CLIs.
- Tier 2: real apps, websites, prototypes, deployable projects.
- Tier 3: high-risk systems involving money, customer data, production writes, schedulers, external sends, or irreversible operations.

Do not start at Tier 3 unless the project needs it.

## 2. Decide The Required Values

Before copying templates, decide:

- Project name.
- Default branch: usually `main`.
- Whether the project uses Codex, Claude Code, or both.
- Whether private notes/control files are needed.
- Whether `VERSION` and version-claim scripts are needed.
- Whether deploy notes or exact-SHA deploy rules are needed.

If an answer is unknown, leave a placeholder and ask before inventing it.

## 3. Copy The Right Templates

For most public utility repos:

- `templates/AGENTS.md.template`
- `templates/CHANGELOG.md.template`

For Claude Code projects:

- `templates/CLAUDE.md.template`

For optional Claude Code launch profiles:

- `templates/powershell/claude-profiles.ps1.template`

For version-disciplined projects:

- `templates/VERSION.template`
- `templates/scripts/claim_version.ps1.template`
- `templates/scripts/version_helpers.ps1.template`
- `templates/scripts/check_version_unique.ps1.template`
- `templates/workflows/version-check.yml.template`

For notes/control projects:

- `templates/scripts/check_control_hygiene.ps1.template`
- `templates/CONCURRENT_WORKTREES.md.template`

## 4. Fill Placeholders

Replace every placeholder:

- `<PROJECT_NAME>`
- `<DEFAULT_BRANCH>`
- `<NOTES_VAULT_PATH>`
- `<DEPLOY_TARGET>`
- `<SERVICE_NAME>`
- `<HEALTH_PATH>`
- Any project-specific dev, test, or deploy command.

Do not leave placeholders in committed project files unless they are deliberately documented TODOs.

## 5. Validate Before Publishing

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sanitize-check.ps1
```

Or with PowerShell 7:

```powershell
pwsh ./scripts/sanitize-check.ps1
```

For adapted downstream projects, add your own private denylist in `.sanitize-denylist.local` and keep it out of git.
