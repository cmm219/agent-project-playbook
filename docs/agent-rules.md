---
project: Agent Project Playbook
type: reference
section: agent-rules
updated: 2026-05-07
---

# Agent Rules

The hard rules, fix tiers, and guards every project's `CLAUDE.md` / `AGENTS.md` should encode.

## Hard Rules (Apply To All Projects)

- **Never run destructive commands** (`rm -rf`, `git reset --hard`, `git push --force`, `git branch -D`, `git checkout .`, etc.) without explicit user confirmation.
- **No refactors without explicit approval.**
- **No silent edits.** Show diffs *before* changes when the user is in plan mode or asking for review.
- **One feature at a time.** Complete and verify before moving on.
- **No architecture changes without approval.**
- **If uncertain → STOP and ask.**
- **Always launch agents in parallel** when tasks are independent.
- **Always give full absolute file paths** for every reference (notes, plans, scripts, repo files). Copy-pasted handoffs must be actionable without rewriting.
- **Verify before claiming done.** Run focused tests. For deploys, verify VERSION, SHA, `/health`, and recent logs.

## Domain-Specific Hard Rules (Adapt Per Project)

If the project handles money, balances, billing, or other irreversible operations, add:

- **Never manually touch balances or the DB unless the user explicitly approves a specific non-balance correction.**
- **No mass edits.**
- **Treat money paths as high-risk.** Adapt names: payouts, imports, transactions, scheduler, outbox, messaging integrations, etc.
- **Read-only audit before correction.** For data reconciliation issues, produce a report/correction packet first. Do not write rows until the user approves exact rows/actions.

## Fix Tiers

A simple framework for matching effort to scope:

- **Tier 1 (<20 lines, one file):** investigate → fix → verify. No plan needed.
- **Tier 2 (multi-file, <100 lines):** investigate → short plan → execute → verify.
- **Tier 3 (architectural / security-critical):** plan first; keep scope explicit; review the plan before executing.

Default to Tier 2 if unclear. Don't auto-escalate to autoplan / multi-agent review for small fixes.

## Batch Mode

When the user approves a PRD or task list with "do it all", "keep going", "finish this", "ship it", or equivalent, treat the approved list as one batch scope.

Inside a batch:
- Multiple PRs may be used. Individual PR merge/deploy is not a stop condition.
- Continue to the next approved item automatically after verification.
- Each PR must map to an approved PRD/task list item; stop before inventing new scope.
- Claude review is batch-level by default, with focused mid-batch review only for material new risk such as schema, auth, billing, infra, deploy, data, or money changes.
- Control/session/archive updates happen at batch end unless there is a real blocker, handoff, or interruption.
- Do not merge/deploy a PR with failing relevant checks. If checks are unavailable or unrelated, record that and continue only when local verification covers the change.

Stop only for:
- Secrets, access, or credentials needed.
- Destructive or irreversible operations outside approved scope.
- Unclear product, data, or money risk.
- Conflicting instructions versus the approved PRD/task list.
- Failed production smoke requiring a rollback versus roll-forward decision.
- Full batch completion.

Batch Mode starts after approval. It does not override planning approval, destructive-command rules, or genuine uncertainty.

## Multi-Agent Isolation

When multiple agents may work on the project simultaneously:

- Main checkout stays on the default branch; never edit there.
- Work only in your assigned `.worktrees/<task>/`.
- Branch prefixes: `codex/*`, `claude/*`, `human/*`.
- Never touch another agent's branch, worktree, or PR.
- Before edits: print repo root, branch, and `git status --short`.

## Subagent Discipline

When delegating to a subagent:

- Include a clear "DO NOT MODIFY" list in the brief.
- Verify only planned files changed when the subagent reports back.
- Prefer hardcoded changes over rewrites when scope is small.
- Plans must include explicit DO NOT MODIFY lists to prevent scope creep.

## Don't-Drag-Prior-Project-Names Guard

When porting setup from one project to another, or building reusable templates:

- Read source files as **structural templates only** — copy the shape, write your own content.
- Every absolute path under a prior project's folder is a *source to read*, not a path to write into the target.
- Strip every literal occurrence of: prior project names, package prefixes, ports, services (e.g., systemd unit names), brand names, person names, vault paths, deploy targets.
- Keep generic patterns (branch prefixes `codex/*` `claude/*` `human/*`, worktree pattern `.worktrees/*`, version-discipline shape, CHANGELOG format, fix-tier framework, multi-agent isolation rule).
- If you find yourself about to write any literal prior-project name into a target file, stop. That's the rule being violated.
- **Test:** would the sentence make sense to someone who has never heard of the prior project? If no, rewrite or drop it.

This guard goes verbatim into the `CLAUDE.md` of any new project that's being bootstrapped from a prior one.

## Session Workflow

Default loop for any non-trivial change outside Batch Mode:

```
Plan → Review → Confirm → Implement → Diff → Log → Commit
```

Do not start coding until approach is approved. After the approach or PRD is approved, Batch Mode applies when the user asks the agent to keep going through the approved list.

## Verification Discipline

Before declaring a change "done":

- Run focused tests for the changed behavior.
- Run any nearby guard tests (especially money-adjacent ones).
- For UI changes: verify by browser (use a CDP or Playwright path, not visual handwaving).
- For deploys: verify deployed version/commit and `/health` (or the project's equivalent health check).
