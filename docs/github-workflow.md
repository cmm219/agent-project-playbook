---
project: Agent Project Playbook
type: reference
section: github-workflow
updated: 2026-05-14
---

# GitHub Workflow

Repo-side workflow patterns. Use `docs/setup-tiers.md` first to decide how much of this file applies. Tier 1 public utility repos usually need only README/AGENTS/CHANGELOG/LICENSE/CI/releases. Tier 3 high-risk production systems should adopt the full workflow.

## 1. Default Branch Choice

- Pick `main` or `master`. Both work; pick once and stick to it.
- Modern default is `main`. If you have prior tooling/habits keyed on `master`, `master` is fine.
- Document the choice in the project's `CLAUDE.md` / `AGENTS.md` so all agents agree.

## 2. Branching Rule

- **Always branch from `origin/<default>`, never from local `<default>`.**
  - Local `<default>` may be stale. `origin/<default>` is authoritative.
  - Command: `git fetch origin <default> && git worktree add .worktrees/<task_name> -b <prefix>/<task_name> origin/<default>`

## 3. Branch Prefixes

- `codex/*` — Codex-owned branches
- `claude/*` — Claude-owned branches
- `human/*` — branches edited directly by you

This makes ownership obvious in `git branch -a` output and PR lists.

## 4. Worktree Isolation

Required for Tier 3. Recommended for Tier 2 when multiple agents may work concurrently. Usually skip for Tier 1 unless the user wants concurrent branch work.

- **Main checkout stays on the default branch.** Never edit it.
- **All work happens in `<REPO_ROOT>/.worktrees/<task_name>/`.**
- Worktrees share the parent's `venv` / `node_modules`. Don't run package installs from a worktree.
- Don't run long-lived dev servers (uvicorn, vite, etc.) from worktrees — only from the main checkout.

Why: prevents two simultaneous agents from corrupting each other's working state via uncommitted files, generated artifacts, or running processes.

## 5. Version + Changelog Discipline

Required for Tier 3. Optional for Tier 1 and Tier 2 unless release/version collision risk exists.

Every shipped PR must:
- Bump `VERSION` (root file, single line, `major.minor.patch.micro`)
- Add a `CHANGELOG.md` entry
- Both **in the same commit**

Recommended early-alpha starting version: `0.1.0.0`. Reserve `1.0.0.0` for the first stable/public release.

Bump types:
- `major` — breaking product/platform change, incompatible API/auth/data contract change, major relaunch, or stable milestone.
- `minor` — meaningful feature/capability added: new surface, integration, billing behavior, workflow, or major UX direction.
- `patch` — bug fix or behavior correction: CORS/auth compatibility, queue bug, UI regression, broken API behavior.
- `micro` — very small shipped change: copy tweak, docs-only, cleanup, styling polish, or small non-risky internal adjustment.

Alpha examples:
- Significant new product UX direction: `0.1.0.0` → `0.2.0.0`
- Same product with polished shell/pages: `0.1.0.0` → `0.1.1.0`
- Tiny follow-up after a patch: `0.1.1.0` → `0.1.1.1`
- Bug fix after that: `0.1.1.1` → `0.1.2.0`

## 6. `claim_version.ps1` Is The Only Way To Bump

Use this only for projects that have adopted `VERSION` + version uniqueness discipline.

- **Never hand-edit `VERSION`.**
- The script reads `origin/<default>` plus all open PR `VERSION` files, picks the next monotonic slot above the highest observed, writes `VERSION`, and seeds a `CHANGELOG.md` stub.
- Usage: `pwsh ./scripts/claim_version.ps1 -Type micro -Slug <branch_name>`
- Template: `templates/scripts/claim_version.ps1.template`.

## 7. `check_version_unique.ps1` Enforced Via CI

- A GitHub Actions workflow runs on `pull_request`.
- The workflow runs `scripts/check_version_unique.ps1`.
- The script fails the PR if `VERSION` is `<= origin/<default>` or collides with another open PR's `VERSION`.
- Template workflow: `templates/workflows/version-check.yml.template`.
- Template script: `templates/scripts/check_version_unique.ps1.template`.

## 8. Exact-SHA Deploy Protocol

Required for high-risk production deploys. Optional for static/public utility repos that only publish GitHub releases.

- Deploy only after the PR is merged to the default branch.
- **Do not use opaque `git pull && restart` deploys.** Use exact-SHA.
- Steps:
  1. Local: `git fetch origin <default>` then `git rev-parse origin/<default>` to capture the SHA.
  2. On the deploy target: `git fetch`, then check out that exact SHA.
  3. Restart the service.
  4. Verify: `/health` returns healthy, deployed `VERSION` matches expected, deployed SHA matches captured SHA, recent logs show the expected startup sequence.
- Document the project's specific deploy target, service name, and health-endpoint path in the project's `CLAUDE.md`.

## 9. Cleanup After Merge

Use targeted cleanup after a PR is verified merged. Use broad cleanup only at batch end or during explicit maintenance.

Minimum safe sequence:

1. Verify the PR state is `MERGED`.
2. Verify the merge commit is present in `origin/<default>`.
3. Delete the merged remote branch only if the project wants that cleanup.
4. Remove only the matching clean worktree.
5. Try safe local branch deletion with `git branch -d`.
6. If `git branch -d` rejects the branch, keep it and report the reason. Do not escalate to `git branch -D` automatically.
7. Sync the default-branch checkout with `git fetch origin <default> && git pull --ff-only`.

Squash-merge caveat: after a squash merge, the local branch commit is often not an ancestor of `origin/<default>`, so `git branch -d` may reject the branch even though the PR is merged. That is expected. Keep the local branch ref unless a human explicitly approves force deletion.

Template: `templates/scripts/cleanup_after_merge.ps1.template`.

## 10. PR Lifecycle

This is the mechanical loop for one PR. In Batch Mode, each PR still follows the branch/diff/commit/PR/merge/deploy mechanics, but stop/report/notes-update rituals run at batch boundaries, not after every PR.

```
draft PR → verification (tests, openapi diff, boot smoke, version uniqueness)
→ pre-merge review (often by another agent)
→ merge to <default>
→ exact-SHA deploy
→ post-deploy verify (/health, VERSION, SHA, logs)
→ cleanup (worktree, local branch, remote branch)
→ continue to the next approved batch item, or update notes if the batch is complete
```

Every PR follows the mechanical loop. Stop/report/notes rituals run at batch boundaries; see Batch Mode in `docs/agent-rules.md`.

## 11. Multi-Agent Coordination

When multiple agents work concurrently:
- One worktree per active task. No sharing.
- One branch prefix per agent (`codex/*`, `claude/*`, `human/*`).
- Document "owned files" and "do not touch" lists in the task plan.
- For projects that use notes control, keep the full concurrent-worktree rules in the project notes folder as described in `docs/notes-control-structure.md`.
