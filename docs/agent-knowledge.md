---
project: Agent Project Playbook
type: guide
section: agent-knowledge
updated: 2026-05-16
---

# Brain-First Project Knowledge

Agents stay useful by loading the smallest reliable context first, then retrieving cited source material only when needed. Do not solve project memory by dumping a whole wiki, notes vault, or prior chat archive into every run.

## The Short Answer

Yes, agents can stay smart without loading everything every time.

No, they cannot magically know private project knowledge unless it is in context, retrieved from a source they can access, cached by the platform, or encoded in their model weights.

The practical pattern:

1. Always load a tiny startup brief.
2. Keep markdown/git as the source of truth.
3. Search local knowledge quickly.
4. Read only the 1-3 relevant source files.
5. Cite source paths in answers and PR notes.
6. Keep summaries compact and refreshable.
7. Treat MCP as optional plumbing, not the required hot path.

## Where Agent Knowledge Comes From

### Model Weights

General knowledge and skills live in the model weights. This is fast because the model is not searching a database for every answer, but it can be stale and does not include private project facts.

### Current Context

The current conversation, system instructions, files read into context, tool results, and pasted snippets are the most direct source of truth for the current run. Large context is useful but expensive and can dilute attention.

### Prompt And KV Caching

Repeated stable prefixes can be cached by model providers. Keep durable startup rules stable and put changing task details later. This helps long-running projects without re-sending noisy dynamic context first.

### Local Files

`AGENTS.md`, `CLAUDE.md`, `docs/`, `tasks/`, `control/`, and source files are project memory. Good project setup makes the most important files small, predictable, and easy to search.

### Retrieval And Tools

Search, connectors, web, MCP servers, local CLIs, and databases can retrieve facts. They are powerful but add round trips. Use them selectively and cite what they return.

## Recommended Project Pattern

### 1. Tiny Always-Loaded Brief

Keep startup files short:

- What this project is.
- Where authoritative state lives.
- What rules cannot be violated.
- Which files to read next.

Avoid giant startup journals. Move history to sessions, archives, changelogs, and reference docs.

### 2. Source-Of-Truth Markdown

Use markdown files for durable project truth:

- `docs/` for product and engineering references.
- `control/STATE.md` for current status pointers.
- `control/TASKS.md` for current focus.
- `sessions/` for history.
- `tasks/archive/` for completed work.

Markdown is easy for humans, agents, git, and search tools.

### 3. Fast Local Lookup

Prefer local lookup before remote systems when searching private project knowledge.

Good first tools:

- `rg` for lexical search.
- SQLite FTS5 for indexed local search when the corpus grows.
- Small CLIs that return compact text or JSON.

Keep MCP optional. It can be useful for IDE-style clients, but an agent workflow should not require a slow server round trip for every local fact lookup.

### 4. Cited Source Reads

Search results are not enough. Agents should read the relevant source files and cite paths.

Good answer shape:

```text
I found the rule in docs/agent-rules.md and the current status in control/STATE.md.
```

Bad answer shape:

```text
I remember we decided this earlier.
```

### 5. Compiled Truth Plus Timeline

For complex projects, keep a short compiled truth at the top of key docs and move history below it.

Useful shape:

```text
# Current Truth
- What is true now.
- What command or workflow is canonical now.
- What is intentionally deprecated.

# Evidence / Timeline
- Date, PR, SHA, or session note that explains how it got here.
```

The current truth gives agents fast orientation. The timeline keeps the evidence auditable.

## What To Avoid

- Loading a full notes vault at startup.
- Treating generated summaries as authoritative when sources changed.
- Depending on a remote database for local project recall.
- Requiring MCP for normal local lookup.
- Requiring shell restarts or environment rituals before every agent session.
- Letting source federation or stale indexes make old project facts look current.
- Returning uncited claims from memory.

## Public-Friendly Knowledge Runtime

A good public design target is:

- Markdown/git remains canonical.
- Local CLI handles search and compact output.
- SQLite FTS5 or similar indexing is optional and rebuildable.
- Output includes file paths and short snippets.
- JSON output exists for agents.
- MCP can be generated later from the same operations.
- The system works on Windows, macOS, and Linux without a daemon.

This is a project setup principle, not a requirement to adopt any specific tool.
