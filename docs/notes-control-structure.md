---
project: Agent Project Playbook
type: reference
section: notes-control-structure
updated: 2026-05-14
---

# Notes / Control Structure

Projects that need persistent private memory get a folder in the notes vault that mirrors the canonical shape. Tier 1 public utility repos may skip notes control unless the user wants private project memory. Tier 2 and Tier 3 projects usually use this structure.

## Canonical Project Folder Shape

```
<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/
├── control/
│   ├── STATE.md                ← current status (pointer stub, ≤60 lines)
│   ├── TASKS.md                ← 3-5 focus items (pointer stub, ≤60 lines)
│   ├── CODEX_GUARDRAILS.md     ← durable agent checks (≤80 lines)
│   └── CONCURRENT_WORKTREES.md ← multi-agent isolation rules
├── sessions/                   ← per-session detail/history notes
├── tasks/
│   ├── audits/                 ← optional cross-agent plans/review packets awaiting approval
│   ├── archive/                ← finished work, usually YYYY-MM-done.md
│   └── backlog.md              ← open/deferred/triage work
└── reference-version-history.md ← deploy log
```

## Multi-Bot Or Multi-App Projects

If one project contains multiple independently runnable bots, apps, or live-money entrypoints, give each active unit its own folder under the project notes folder:

```
<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/bots/<BOT_SLUG>/
├── control/
│   ├── STATE.md
│   ├── TASKS.md
│   └── CODEX_GUARDRAILS.md
├── tasks/
│   └── backlog.md
├── CHANGELOG.md
├── VERSION
└── README.md
```

The project-level `control/` tracks the batch and inventory. The per-bot folder tracks that bot's run command, live status, CLV/ledger location, current fixes, and verification proof. This prevents one bot's live-money state or version history from getting buried under unrelated bots.

## Control Files Are Pointers, Not Journals

The most important rule: `STATE.md` and `TASKS.md` stay short.

- **`STATE.md`** describes current state and points to detail in other files. It does not contain history. History lives in `sessions/` and `reference-version-history.md`.
- **`TASKS.md`** lists 3-5 current focus/watch items. It does not contain the full backlog, completed work, or detailed task history.
- **`tasks/backlog.md`** stores open, deferred, and triage-needed work that should not load at startup.
- **`tasks/audits/`** is optional. Use it for cross-agent review gates: one agent writes a plan/review packet, another reviews it, and implementation waits for approval. This prevents parallel Codex/Claude chats from stepping on each other's PRs, branches, or file scope.
- **`tasks/archive/YYYY-MM-done.md`** stores completed task summaries. Move finished work here instead of leaving "Recently Done" in `TASKS.md`.
- **`CODEX_GUARDRAILS.md`** is durable agent checks (e.g., "always grep for shims before editing dual-tree files"). It does not contain current state.

If these files grow long, you're using them wrong. Move detail out, link a path back.

## `check_control_hygiene.ps1` Enforces The Limits

- `STATE.md` ≤ 60 lines
- `TASKS.md` ≤ 60 lines, with ≤ 5 bold focus/watch bullets
- `CODEX_GUARDRAILS.md` ≤ 80 lines
- `STATE.md` and `TASKS.md` cannot contain "## Recent Notes" or "## Recently Done" sections (those are journal patterns; link instead)

Run the script before finishing any session that edits control files.

Templates: `templates/scripts/check_control_hygiene.ps1.template` and `templates/CONCURRENT_WORKTREES.md.template`.

## Session Notes

- One file per work session in `sessions/`.
- Naming: `YYYY-MM-DD-HHMM-session-<slug>.md` or `YYYY-MM-DD-session-<slug>.md`.
- Frontmatter: `type: session`, `project`, `status: done`, `created`, `updated`, `session_start`, `session_end` (ISO local time).
- Content shape:
  - Cliff Notes (3-5 bullets)
  - What We Built/Fixed
  - Decisions Made
  - Resume Here
  - Open Items
  - Next Session Should (1-2-3 list)

## Task Lifecycle

- Active focus/watch items live in `<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/control/TASKS.md`.
- Open/deferred/triage-needed items live in `<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/tasks/backlog.md`.
- Plans and review packets that need approval live in `<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/tasks/audits/` (e.g., `2026-05-07-<task_name>-plan.md`). Skip this folder for simple work that does not need a separate review gate.
- Finished task summaries move to `<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/tasks/archive/YYYY-MM-done.md`.
- Detailed session history lives in `<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/sessions/`.

When a task is done, remove it from `control/TASKS.md`, add the compact result to the current month archive, and put any useful narrative in a session note. If the work started from `tasks/audits/`, link the plan from the session/archive entry instead of copying it into startup files.

For an approved multi-PR PRD/task list, the batch is the task. Do not treat each individual PR as a completed task that needs `TASKS.md`, archive, and session-note churn. File the normal control/session/archive update at the end of the approved batch, or earlier only for a real blocker, handoff, or interruption.

## Cross-Agent Review Gate

Use normal work for small safe tasks. Use `tasks/audits/` only when work needs a review gate: risky changes, broad refactors, parallel Codex/Claude work, PR/version/deploy coordination, data or money impact, or anything where one agent should review before another implements. Plans with `status: review-needed` must not be implemented until reviewed.

Recommended frontmatter:
```
---
project: <PROJECT_NAME>
date: YYYY-MM-DD
task: <task_name>
status: review-needed
owner: Codex
reviewer: Claude
---
```

Required content:
- Current base branch/SHA/version.
- Owner/implementer and reviewer roles.
- "Do not implement until reviewed/approved" if approval is required.
- Exact worktree/branch path to use.
- Allowed files and do-not-touch files.
- Required proof and stop conditions.
- PR body checklist, including review trail and safety statement.

After approval, the owner implements in the named worktree/branch. For a multi-PR batch, one approved plan may cover the batch when it names the slices/PRs and stop gates. The session note and PR body should link the plan and record the reviewer verdict, but routine session/archive/control updates wait for batch end.

## `reference-version-history.md`

One row per deploy. Format:
```
## <VERSION> — YYYY-MM-DD — <one-line summary>

- PR #<num>
- SHA <full-sha>
- <any notable detail>
```

Append-only. Newest at the top.

## Repo `CONTROL/` Stubs

Repos with notes-vault control also get a top-level `CONTROL/` folder with two pointer files:

- `CONTROL/STATE.md` — single line: "Authoritative state lives in `<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/control/STATE.md`."
- `CONTROL/TASKS.md` — same pattern for tasks.

These exist so an agent that opens the repo and doesn't know the notes vault location still gets a clear pointer. They never contain real content. Skip repo `CONTROL/` stubs when the project intentionally has no notes-vault control folder.

## Session Start Protocol

When an agent starts a session on a project that uses notes control:

1. Read `<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/control/STATE.md`
2. Read `<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/control/TASKS.md`
3. Read `<NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/control/CODEX_GUARDRAILS.md`
4. Do NOT auto-load `tasks/backlog.md` or recent session notes unless STATE/TASKS indicates something mid-flight that requires it.
5. Open the conversation with: "Last session you [X]. Picking up from [Y]."

## Session End Protocol

When the user says "done" / "stopping" / equivalent on a project that uses notes control:

1. Write a session note to `sessions/`
2. Update `control/STATE.md` (status line + maybe a session pointer)
3. Update `control/TASKS.md` only if focus changed; keep to 3-5 items
4. Run `check_control_hygiene.ps1` to validate
5. Commit (if the changes are repo-side; notes-vault commits are optional per project)
