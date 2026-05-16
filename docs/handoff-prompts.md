---
project: Agent Project Playbook
type: reference
section: handoff-prompts
updated: 2026-05-14
---

# Handoff Prompts

Reusable prompts for handing off setup work to Codex/Claude inside a new repo. Paste the relevant prompt, fill in placeholders, let the agent do the work.

---

## Prompt 1: Don't-Drag-Prior-Project-Names Guard (paste at the top of any port-the-setup brief)

```
Critical: do not literally copy paths, names, or project-specific values from any prior project I've shown you. Read those files as structural templates only — copy the shape, write your own content.

Specifically:
- Every absolute path under a prior project's folder is a source to read, not a path to write into the target. Your output paths live under this repo's root only.
- Every occurrence of any prior project's name, package prefix, port, service name (e.g. systemd unit), brand name, person name, or vault path is project-specific. Strip it. Do not carry it into this repo even as an example.
- Project name is <PROJECT_NAME>. Use it consistently.
- Repo root for output is wherever this repo is cloned locally — pick the path yourself, don't reuse mine.
- Notes vault path: ask me, don't assume.
- Branch prefixes (codex/*, claude/*, human/*), worktree pattern (.worktrees/*), version-discipline shape, CHANGELOG format, fix-tier framework, multi-agent isolation rule — these are generic patterns, port them. Everything else, treat as prior-project-only and drop it.
- If you find yourself about to write any literal prior-project name into a file in this repo, stop. That's the rule being violated.

When in doubt: would this sentence make sense to someone who has never heard of any prior project? If no, rewrite or drop it.
```

---

## Prompt 2: Port-The-Setup Brief

```
Task: Port the standard project workflow scaffolding into <PROJECT_NAME>.

Reference playbook: <PATH_TO_AGENT_PROJECT_PLAYBOOK_CHECKOUT>/

First read `docs/setup-tiers.md` and choose the smallest sufficient tier:
- Tier 1 Light Public Utility Repo
- Tier 2 Medium Product / Website Repo
- Tier 3 High-risk Production System

Explain the tier choice before creating files.

Then read these files from the playbook and port only the relevant equivalents into <PROJECT_NAME>, adapting paths and project-specific values:

1. docs/setup-tiers.md — decides light/medium/high-risk setup and what to skip.

2. docs/github-workflow.md — establishes default-branch choice, branching rule, branch prefixes, worktree isolation, version + CHANGELOG discipline, exact-SHA deploy protocol, PR lifecycle. Apply the full version/deploy/worktree setup only for the tiers that need it.

3. docs/notes-control-structure.md — establishes the notes-vault folder shape (control/STATE.md, control/TASKS.md, sessions/, tasks/audits/, tasks/archive/, reference-version-history.md) and the control-hygiene limits. Skip notes control for Tier 1 unless the user wants persistent private project memory.

4. docs/agent-rules.md — hard rules, fix tiers, multi-agent isolation, don't-drag-names guard.

5. templates/ — copy only the templates needed for the chosen tier:
   - CLAUDE.md.template → <REPO_ROOT>/CLAUDE.md
   - AGENTS.md.template → <REPO_ROOT>/AGENTS.md (if Codex is used)
   - claim_version.ps1.template → <REPO_ROOT>/scripts/claim_version.ps1
   - version_helpers.ps1.template → <REPO_ROOT>/scripts/version_helpers.ps1
   - check_version_unique.ps1.template → <REPO_ROOT>/scripts/check_version_unique.ps1
   - cleanup_after_merge.ps1.template → <REPO_ROOT>/scripts/cleanup_after_merge.ps1
   - check_control_hygiene.ps1.template → <REPO_ROOT>/scripts/check_control_hygiene.ps1
   - version-check.yml.template → <REPO_ROOT>/.github/workflows/version-check.yml
   - CONCURRENT_WORKTREES.md.template → <NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/control/CONCURRENT_WORKTREES.md
   - CHANGELOG.md.template → <REPO_ROOT>/CHANGELOG.md
   - VERSION.template → <REPO_ROOT>/VERSION
   - reference-version-history.md.template → <NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/reference-version-history.md

For Tier 1, usually create README/AGENTS/CHANGELOG/LICENSE/SECURITY/CI and skip VERSION/scripts/notes unless requested.

For Tier 2, add notes control and deploy/project rules if ongoing project memory or production deploys exist.

For Tier 3, use the full setup, including notes control, VERSION/scripts/version-check CI, worktree rules, and exact-SHA deploy.

6. If the chosen tier includes notes control, create the notes-vault folder structure under <NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/ matching the canonical shape. Seed control/STATE.md with the initial scaffold status and control/TASKS.md with a 2-3 item current-focus list.

7. Replace every placeholder (<PROJECT_NAME>, <DEFAULT_BRANCH>, <NOTES_VAULT_PATH>, <DEPLOY_TARGET>, <SERVICE_NAME>, <HEALTH_PATH>, <BACKEND_PORT>, <FRONTEND_PORT>, etc.) with the values you determine for this project. Stop and ask before assuming any value.

Things to deliberately NOT carry over:
- Any prior project's literal names, paths, ports, services, brands, person names
- Any prior project's domain-specific hard rules unless this project shares the same domain (money/balances/billing)

Open one draft PR titled "chore: port standard project workflow scaffolding" against the new project's default branch. Include in the PR body:
- The chosen setup tier and why
- The values you used for each placeholder
- If the chosen tier includes version scripts: a test run of claim_version.ps1 showing it produces the next version correctly
- If the chosen tier includes version-check CI: confirmation that the GitHub Actions workflow runs on pull_request
- Any TODOs/placeholders you couldn't resolve and need user input on

Stop and ask before:
- Choosing the setup tier if the project risk level is unclear
- Picking the starting VERSION (likely 0.1.0.0 but confirm)
- Picking the default branch (main vs master)
- Picking the notes-vault path
- Picking the deploy target / service name / health path
- Adding any domain-specific hard rules (money/balance language) — only if confirmed

[Insert Prompt 1 (Don't-Drag-Names Guard) at the very top of this brief before pasting to the agent.]
```

---

## Prompt 3: Version-Tracking Infrastructure Only (subset of Prompt 2)

If a project already exists and only needs version-tracking added:

```
Task: Establish version-tracking infrastructure for this repo.

Reference playbook: <PATH_TO_AGENT_PROJECT_PLAYBOOK_CHECKOUT>/

Create three coordinated artifacts that work together as a single discipline:

1. VERSION file at the repo root.
   - Single line, plain text, no trailing newline issues.
   - Seed with a starting version. Ask me what to use (likely 0.1.0.0).
   - Format: four numeric segments separated by dots: major.minor.patch.micro.
   - Early-alpha SaaS default: start at 0.1.0.0 and reserve 1.0.0.0 for first stable/public release.
   - Use minor for meaningful new capabilities, patch for bug fixes/behavior corrections, and micro for tiny shipped changes such as docs, copy, cleanup, or styling polish.

2. CHANGELOG.md at the repo root.
   - Keep-a-Changelog style. Newest entries at the top.
   - Every shipped PR adds one entry under its version.

3. Version-claim and version-uniqueness scripts:
   - scripts/claim_version.ps1 (template: templates/scripts/claim_version.ps1.template)
   - scripts/version_helpers.ps1 (template: templates/scripts/version_helpers.ps1.template)
   - scripts/check_version_unique.ps1 (template: templates/scripts/check_version_unique.ps1.template)
   - scripts/cleanup_after_merge.ps1 (template: templates/scripts/cleanup_after_merge.ps1.template) if the repo uses worktrees or frequent PR cleanup

4. GitHub Actions workflow at .github/workflows/version-check.yml (template: templates/workflows/version-check.yml.template) that runs check_version_unique.ps1 on pull_request.

5. A version history log file in the notes vault at <NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/reference-version-history.md (template: templates/reference-version-history.md.template). Each deploy or meaningful release appends one row.

Hard rule going forward: every shipped PR must bump VERSION and add a CHANGELOG.md entry in the same commit. CI enforces uniqueness; CHANGELOG entry is enforced by review.

Open a draft PR titled "chore: establish version-tracking infrastructure". Include the starting VERSION, the notes-vault path, confirmation that CI runs on pull_request, and a dry-run of claim_version.ps1.

Stop and ask before picking the starting VERSION or the notes-vault path.

[Insert Prompt 1 (Don't-Drag-Names Guard) at the top.]
```

---

## Prompt 4: Codex Review Of A Bootstrap PR (paste to a different agent than the one that built it)

```
Task: Review a bootstrap PR that ports the standard project workflow scaffolding into <PROJECT_NAME>.

Reference playbook: <PATH_TO_AGENT_PROJECT_PLAYBOOK_CHECKOUT>/

First identify the setup tier claimed by the PR:
- Tier 1 Light Public Utility Repo
- Tier 2 Medium Product / Website Repo
- Tier 3 High-risk Production System

Verify only the artifacts required for that tier. Do not reject a Tier 1 PR for intentionally omitting notes control, VERSION, version scripts, or exact-SHA deploy docs.

Verify:

1. If the chosen tier includes notes control, folder structure under the notes vault matches docs/notes-control-structure.md:
   - <NOTES_VAULT_PATH>/projects/<PROJECT_NAME>/control/STATE.md exists, ≤60 lines
   - control/TASKS.md exists, ≤60 lines, ≤5 bold focus bullets
   - control/CODEX_GUARDRAILS.md exists, ≤80 lines
   - control/CONCURRENT_WORKTREES.md exists
   - sessions/, tasks/audits/, tasks/archive/ exist
   - reference-version-history.md exists with v0.1.0.0 seed

2. Repo files match the chosen tier:
   - Tier 1: README, AGENTS or CLAUDE, CHANGELOG, LICENSE, SECURITY when relevant, and lightweight validation CI if useful.
   - Tier 2: Tier 1 plus project-specific dev/deploy/design rules and notes control if ongoing project memory exists.
   - Tier 3: Tier 2 plus VERSION, version scripts, version-check CI, control hygiene script, worktree rules, exact-SHA deploy docs, and high-risk guardrails.

3. Generic-template discipline:
   - Grep the entire bootstrap PR for any literal name from prior projects you know about (project names, package prefixes, ports, services, brands, person names). Should be zero hits.
   - Grep for placeholder leftovers (<PROJECT_NAME>, <DEFAULT_BRANCH>, etc.) in committed files. Should be zero hits.

4. Functional checks:
   - Tier 1: lightweight repo validation passes, if present.
   - Tier 2: deploy/dev validation and notes hygiene pass, if present.
   - Tier 3: claim_version.ps1 -DryRun produces a valid next version; check_version_unique.ps1 returns "VERSION <x> is unique"; check_control_hygiene.ps1 returns "Control hygiene passed".

5. Multi-agent isolation is documented if concurrent agent work is expected. It is required for Tier 3.

6. Branch from origin/<default> rule is documented for Tier 2/3. Tier 1 can use simpler branch/release discipline unless the user requests PR workflow.

Report findings as:
- ✅ Conforming items
- ❌ Missing or wrong items (cite file path + what's wrong)
- ⚠️ Style/scope concerns

Do not make changes. Review only.
```

---

## Prompt 5: Approved PRD Batch Execution Handoff

Use this after a PRD/task list has already been approved and the user wants execution, not during initial project bootstrap.

```
Task: Execute the approved PRD/task list as one batch.

Approved scope:
- <PASTE_OR_LINK_APPROVED_PRD_OR_TASK_LIST>

Batch instruction:
- Treat this approved PRD/task list as one batch scope.
- Multiple PRs may be used, but individual PR merge/deploy is not a stop condition.
- Continue to the next approved item automatically after verification.
- Each PR must map to an approved PRD/task list item; stop before inventing new scope.
- Claude review is batch-level by default, with focused mid-batch review only for material new risk such as schema, auth, billing, infra, deploy, data, or money changes.
- Control/session/archive updates happen at batch end unless there is a real blocker, handoff, or interruption.

Stop only for:
- Secrets, access, or credentials needed.
- Destructive or irreversible operations outside approved scope.
- Unclear product, data, or money risk.
- Conflicting instructions versus the approved PRD/task list.
- Failed production smoke requiring a rollback versus roll-forward decision.
- Full batch completion.

Do not stop after each PR to ask what is next. If the next approved item is clear, keep going.
```
