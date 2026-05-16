# Tier 2 Standard Example

Fictional project: `example-product-app`

Use Tier 2 for apps, websites, prototypes, and ongoing projects that may deploy or need persistent project memory.

This tier keeps the repo approachable while giving agents enough context to pick up work across sessions. It is the usual starting point for real apps that are not yet high-risk production systems.

Typical repo files:

```text
example-product-app/
  README.md
  AGENTS.md
  CLAUDE.md
  CHANGELOG.md
  LICENSE
  docs/
  .github/workflows/validate.yml
```

Typical private notes shape:

```text
<NOTES_VAULT_PATH>/projects/example-product-app/
  control/
    STATE.md
    TASKS.md
    CODEX_GUARDRAILS.md
  sessions/
  tasks/
    backlog.md
    archive/
    audits/
  reference-version-history.md
```

Add `VERSION` and version scripts only when release coordination matters.

## How To Apply

1. Copy `templates/AGENTS.md.template` and/or `templates/CLAUDE.md.template` into the repo.
2. Fill project-specific dev, test, deploy, and port commands.
3. Create the notes/control folder only if the project needs persistent private memory.
4. Use `templates/CONCURRENT_WORKTREES.md.template` when multiple chats or agents may work at the same time.
5. Add `VERSION`, version scripts, and version-check CI from `templates/workflows/version-check.yml.template` only when multiple PRs/releases need monotonic coordination.

Upgrade to Tier 3 when the project starts handling money, customer data, production writes, schedulers, external sends, or irreversible operational changes.
