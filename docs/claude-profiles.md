---
project: Agent Project Playbook
type: guide
section: claude-profiles
updated: 2026-05-16
---

# Claude Profiles

Claude Code launch profiles are optional shell helpers that start Claude with a known set of flags for a class of work.

Use them when you want repeatable local behavior across projects without editing every repo's `CLAUDE.md` or changing global settings. They work well with [agent-knowledge.md](agent-knowledge.md): the profile keeps the session lean, and `CLAUDE.md` provides the tiny routing map for local knowledge.

## What Profiles Should Do

A useful profile should:

- Preserve normal `CLAUDE.md` auto-discovery.
- Keep local notes recall on the file-search path, not the MCP hot path.
- Disable optional integrations that are not needed for the session.
- Forward all user-provided Claude arguments.
- Restore process environment variables after Claude exits.
- Stay machine-local; do not commit a personal PowerShell profile to project repos.

## Example Profiles

This repo includes [templates/powershell/claude-profiles.ps1.template](../templates/powershell/claude-profiles.ps1.template).

The template defines:

- `claudelean`: daily-driver profile using the configured default model, medium effort, strict MCP config, and no Chrome integration.
- `claude200`: heavier-model profile using the model in `CLAUDE_PROFILE_HEAVY_MODEL`, or `opus` if that environment variable is unset.

The names are examples. Use names that make sense for your machine.

## Why No `--bare`

Do not use `--bare` for these profiles when your workflow depends on project or global routing text.

`--bare` is useful for minimal, explicitly configured runs, but it skips normal `CLAUDE.md` auto-discovery. If your knowledge routing lives in `CLAUDE.md`, a bare profile can make Claude miss the map that tells it where to search, when to cite local files, and when not to use MCP.

Use normal Claude startup plus focused flags instead:

```powershell
claudelean
claudelean -p "What did we decide about local notes vs MCP?"
claude200 "Review this architecture plan"
```

## Recommended Defaults

For local-first knowledge work:

- Use `--strict-mcp-config` so Claude only uses MCP servers explicitly supplied for that session.
- Use `--no-chrome` when browser integration is not needed.
- Set `ENABLE_CLAUDEAI_MCP_SERVERS=false` when you do not need hosted connectors, if your Claude Code version supports that environment variable.
- Set `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` when you want to avoid large-context model variants for routine sessions, if your Claude Code version supports that environment variable.
- Use `--effort medium` as the default, then create a separate high-effort profile for harder reviews when needed.

Do not automatically add `--dangerously-skip-permissions` to a public template. If a user wants that mode for a trusted sandbox, they can pass it explicitly per run.

## Multi-Agent And Notes Access

Claude subagents or subprocess-style runs may not inherit the parent session's local knowledge routing or filesystem access. If a task depends on a notes vault or local wiki, make both pieces explicit:

- Put the local-first routing rule in the parent prompt and in each subagent prompt.
- Ask each subagent to report files read, whether MCP/web was used, and whether it needed broader-vault fallback.
- Launch from a directory that can read the notes root, or pass the notes root explicitly:

```powershell
claude --add-dir "<NOTES_VAULT_PATH>"
```

Use more than one `--add-dir` only when a task genuinely needs multiple roots. Keep public templates generic; never commit a personal machine path.

## Temporary Model Pinning

Sometimes a default non-interactive Claude route can fail while a specific model route still works. A typical symptom is headless `claude -p` runs exiting non-zero while interactive Claude still starts. Treat a profile-level model pin as an outage workaround, not a memory-system design.

Public-safe pattern:

- Keep the normal profile unpinned by default.
- Allow an environment variable such as `CLAUDE_PROFILE_LEAN_MODEL` to pin a model temporarily.
- Remove the pin after the default route recovers.
- Do not hardcode personal model names or incident-specific settings into public templates.

## Setup

1. Copy the template into your PowerShell profile or dot-source it from your profile.
2. Replace any model aliases or environment variables with values that fit your Claude Code install.
3. Run `claudelean --version` or `claude200 --version` to confirm arguments forward to Claude.
4. Ask a small knowledge-routing question and confirm Claude cites local files instead of loading broad context.
5. For multi-agent work, run one small subagent test and confirm the child agent can read the notes root with `--add-dir` when needed.

For example, a project can use:

```text
<HOME_DIR>/Dev/notes/knowledge/wiki
<HOME_DIR>/Dev/notes
```

as local knowledge roots, while keeping the exact machine path out of public repos.

## How Profiles Fit The Playbook

Profiles are a convenience layer, not the source of truth.

- `AGENTS.md` and `CLAUDE.md` define repo behavior.
- The local notes wiki stores durable knowledge.
- The profile chooses the launch posture for one session.
- Live code inspection still beats old notes.
- Web or official docs still beat local notes for current external facts.

If profile behavior starts carrying project policy, move that policy into the repo's agent instructions or private notes control files instead.
