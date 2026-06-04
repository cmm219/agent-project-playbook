---
project: Agent Project Playbook
type: comparison
section: gbrain-vs-playbook
updated: 2026-06-04
---

# Local-First Routing vs. a Database-Backed Brain (GBrain)

This playbook and Garry Tan's [GBrain](https://github.com/garrytan/gbrain) solve the same core problem — *agents are amnesiac about everything that isn't code* — from opposite ends. They are not competitors. They are two points on a spectrum, and the right pick depends on the size and shape of your knowledge, not on which is "better."

This page is an honest comparison so you can choose deliberately, or run both.

## The One-Sentence Version

- **GBrain** turns your markdown into a Postgres-backed, MCP-served brain that *synthesizes an answer* across a large corpus.
- **This playbook** keeps your markdown as the answer and teaches the agent to *read the 1–3 right files* with no database, no server, and no tokens in the retrieval path.

If your corpus is tens of thousands of cross-linked pages about people, companies, and deals, a synthesis layer earns its keep. If your corpus is "this project's docs, decisions, and session history," reading the source directly is faster, cheaper, and easier to trust.

## Side By Side

| Dimension | GBrain | This Playbook (local-first routing) |
| --- | --- | --- |
| Storage | Markdown synced into Postgres (PGLite / Supabase) | Plain markdown in git; no database |
| Retrieval | MCP server, hybrid search + synthesis | Agent reads local files directly (grep/glob + routing rules) |
| Answer shape | Synthesized prose with citations + gap analysis | Source files, cited by path; the agent reads them |
| Hot-path cost | DB round trip; raw search is cheap, synthesis ("think") adds an LLM call | A file read; no network, no extra LLM call |
| Cold start | Seconds for a local PGLite brain; ~30 min for the full agent setup (DB / keys / daemon) | Works immediately on a fresh clone |
| Infra to keep alive | Server / daemon (optional dream cycle) | None |
| Scale ceiling | Designed for 100K+ pages | Best for a project-sized corpus |
| Cross-entity graph queries | Yes (typed edges: `works_at`, `invested_in`, …) | No |
| Multi-tenant team brain | Yes (per-login scoping) | No (single project / machine) |
| Secrets surface | DB creds, MCP tokens, OAuth clients | None required |
| Determinism / auditability | Retrieval quality measured by eval benchmarks | Deterministic; zero-token audit you can re-run |

## Why Local-First Keeps the Agent Quick

Speed is the reason this approach exists, so it is worth being precise about *where* the time goes.

- **Retrieval is just a file read the agent already knows how to do.** No query planner, no server process, no auth handshake. A `grep` plus two `Read`s is sub-second and local.
- **No tokens spent retrieving.** Raw lexical search in a database brain is cheap; but a *synthesis* query spends an LLM call to turn pages into a prose answer. Reading the source spends neither — the model was going to read context anyway.
- **No cold start, ever.** Clone the repo and the memory is already there. Nothing to install, provision, or warm up before the first useful answer.
- **Cache stays warm.** A tiny, stable startup brief sits at the front of the prompt, so prompt/KV caching keeps working. You are not re-sending a fresh retrieval blob each turn.
- **Nothing to be down.** No server to rate-limit, no index to fall out of sync, no daemon to babysit. Offline still works.

The trade is real: you are asking the agent to read rather than handing it a pre-synthesized answer. At project scale that is a feature. At 100K pages it stops scaling, and that is exactly where GBrain takes over.

## Pros and Cons

### Local-first routing (this playbook)

**Pros**
- Zero infrastructure, zero tokens, zero network in the retrieval hot path.
- Instant on a fresh machine or fresh clone; no install ritual.
- Deterministic and auditable — you can re-run the measurement yourself (see [how-it-works-evidence.md](how-it-works-evidence.md)).
- No new secret surface (no DB credentials, no MCP tokens).
- Markdown you can read, diff, and edit by hand; git is the whole system.
- Plays well with prompt caching because the startup brief is small and stable.

**Cons**
- No synthesized answer — the agent does the reading. Fine at project scale, not at 100K pages.
- No semantic search; you lean on routing + lexical search, so good file naming and a small index matter.
- No cross-entity graph queries.
- Not a shared, multi-tenant team brain.
- New durable knowledge is compiled by hand (inbox → curated article), not ingested automatically.

### Database-backed brain (GBrain)

**Pros**
- Synthesized, cited answers with explicit gap analysis ("here's what the brain doesn't know yet").
- A self-wiring knowledge graph for relationship queries vector search can't reach.
- Scales to very large, cross-domain corpora.
- Multi-tenant, per-login scoping for team / company memory.
- Optional autonomous ingestion and overnight consolidation.

**Cons**
- Real infrastructure: a database, an MCP server, and (for the full setup) a daemon.
- DB / MCP round trips on the retrieval path; synthesis answers also cost LLM tokens (raw search does not).
- Install and provisioning before the first answer.
- New secret surface to manage (DB creds, MCP tokens, OAuth clients).
- Index can drift from source; retrieval quality becomes something you have to measure.

## When To Use Which

**Reach for this playbook when:**
- The corpus is project-sized (this repo's docs, decisions, sessions), not a 100K-page knowledge base.
- You want per-repo project memory with zero infrastructure and zero token cost.
- You value determinism, auditability, and a small secret surface.
- You are a solo dev or small team on one machine, often on Windows, and want low friction.

**Reach for GBrain when:**
- You are building a large, cross-domain brain (people, companies, deals, ideas).
- You need synthesized answers and gap analysis, not just the right files.
- You need a shared team brain with scoped access.
- You want autonomous ingestion and are comfortable running Postgres + an MCP server.

## Use Both

These are layers, not rivals.

- Keep **local-first routing per repo** as the fast hot path: a tiny startup brief, markdown source of truth, read 1–3 cited files. This is what keeps day-to-day sessions quick.
- Add **GBrain as the heavyweight index** when a question genuinely needs cross-corpus synthesis or relationship traversal that local files can't answer cheaply.

The routing rule generalizes cleanly: *try local files first; escalate to the database-backed brain only when the question actually needs synthesis or graph traversal.* That keeps the common case fast and reserves the expensive path for when it pays for itself.

## See Also

- [How It Works, With Evidence](how-it-works-evidence.md) — the mechanism and a deterministic way to prove it is working.
- [Brain-First Project Knowledge](agent-knowledge.md) — the routing pattern in full.
- [GBrain](https://github.com/garrytan/gbrain) and [gstack](https://github.com/garrytan/gstack) — the database-backed brain and the surrounding toolset.
