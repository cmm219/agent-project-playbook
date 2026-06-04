---
project: Agent Project Playbook
type: guide
section: how-it-works-evidence
updated: 2026-06-04
---

# How It Works, With Evidence

The claim is easy to make and hard to trust: "agents stay smart with plain markdown and a tiny routing rule, no database required." This page shows the mechanism, then gives you a deterministic, zero-token way to prove it is working in your own setup — so you are not taking it on faith.

## The Mechanism

There is no server and no magic. The whole loop is four moves:

1. **A tiny always-loaded brief.** A short routing block lives in `AGENTS.md` / `CLAUDE.md`: what the project is, where authoritative state lives, and the rule *check local knowledge before answering from memory*. It stays small so prompt caching keeps working.
2. **A proactive check.** For any project-memory question, the agent does a small local lookup first and reports a one-line signal — for example `Knowledge check: read control/STATE.md` — or explains why it skipped it. That signal is what makes the behavior observable.
3. **Cited source reads.** The agent reads the 1–3 relevant files and cites them by path, instead of answering "I think we decided…". Search results alone are not enough; the read and the citation are the point.
4. **Staged new knowledge.** Durable lessons go to an `inbox` first and are compiled into curated articles deliberately, so normal task work never silently rewrites project memory.

That is the entire runtime. The evidence question is simply: *does step 2 actually fire during real work, without anyone reminding the agent to do it?*

## Measuring It: A Zero-Token Audit

Because the signal is a literal line in the transcript, you can measure adoption with `find` and `grep` — no model calls, no database, no embeddings. Save the script below, point it at your own knowledge root, and run it at session start or weekly.

```bash
#!/usr/bin/env bash
# Knowledge-routing audit. Deterministic, zero-token, no DB/MCP/embeddings.
# Counts the proactive "Knowledge check" signal and the supporting evidence
# sources so you stop concluding "no data" passively.
#
# Requires GNU coreutils (find -newermt, date -d): Linux, or Git Bash on Windows.
#
# Usage:  NOTES_ROOT=/path/to/notes [TRANSCRIPTS_DIR=/path/to/transcripts] \
#           ./knowledge-audit.sh [SINCE_DATE]
set -euo pipefail

: "${NOTES_ROOT:?set NOTES_ROOT to your notes/knowledge root}"
TRANSCRIPTS_DIR="${TRANSCRIPTS_DIR:-}"
SINCE="${1:-$(date -d '7 days ago' +%Y-%m-%d)}"

echo "Knowledge audit  |  window since $SINCE"

# 1. Proactive 'Knowledge check' signal, counted ONLY over transcripts modified
#    within the window (so the score reflects recent work, not all-time history).
if [ -n "$TRANSCRIPTS_DIR" ] && [ -d "$TRANSCRIPTS_DIR" ]; then
  TX=0; KC_FILES=0; KC_HITS=0
  while IFS= read -r -d '' f; do
    TX=$((TX + 1))
    n=$(grep -icE "knowledge check" "$f" || true)   # grep exits 1 on no match; don't abort
    if [ "$n" -gt 0 ]; then
      KC_FILES=$((KC_FILES + 1))
      KC_HITS=$((KC_HITS + n))
    fi
  done < <(find "$TRANSCRIPTS_DIR" -type f -name '*.md' -newermt "$SINCE" -print0)
  echo "  transcripts in window:        $TX"
  echo "  'Knowledge check' hits/files: $KC_HITS across $KC_FILES files"
else
  echo "  transcripts: set TRANSCRIPTS_DIR to enable this check"
fi

# 2. Project session notes written in window
echo "  session notes in window:      $(find "$NOTES_ROOT" -type f -name '*.md' -path '*/sessions/*' -newermt "$SINCE" | wc -l)"

# 3. Project control files touched
echo "  control files in window:      $(find "$NOTES_ROOT" -type f \( -name 'STATE.md' -o -name 'TASKS.md' \) -newermt "$SINCE" | wc -l)"

# 4. Compiled knowledge articles touched
echo "  compiled articles in window:  $(find "$NOTES_ROOT" -type f -name '*.md' -path '*/wiki/*' ! -name 'inbox.md' ! -name 'index.md' -newermt "$SINCE" | wc -l)"
```

## Reading the Scorecard

A representative run over one maintainer's recent five-day window:

| Signal | Reading | What it tells you |
| --- | --- | --- |
| `Knowledge check` hits | 100+ across ~13 transcripts | The proactive trigger is firing organically, with no reminders. This is the health signal. |
| Session notes written | ~50 | Durable memory is being captured, not lost to chat. |
| Control files updated | high single digits | Project status pointers are staying current. |
| Compiled articles touched | low / steady | Curated knowledge changes deliberately, not on every task. |

Two interpretation rules make the numbers actionable:

- **`Knowledge check` hits near zero in a real work window = the trigger is not firing.** That is the one signal that should make you change something — tighten the startup brief or the routing rule before adding any tooling.
- **Lots of session/inbox activity but almost no compiled-article updates = a compile is overdue.** Stage-then-compile is working, but the staging is backing up.

## The Failure Gate

The discipline that keeps this approach honest: **do not build infrastructure until a repeatable failure forces it.** Before reaching for a CLI, daemon, MCP server, database, or embeddings index, capture the failure:

- What question failed?
- Which files should have answered it?
- Did *local search* fail, or did the agent *route* badly?
- Would a smaller startup rule or a better index entry have fixed it?
- Can the fix stay as markdown plus search?

If the honest answer is still "plain local files work," the scorecard is telling you to stay lean. The moment the `Knowledge check` signal collapses on real work and a smaller rule won't fix it, you have earned the right to add a heavier layer — and at that point a database-backed brain like [GBrain](https://github.com/garrytan/gbrain) is a reasonable next step (see [gbrain-vs-playbook.md](gbrain-vs-playbook.md)).

## See Also

- [Local-First Routing vs. a Database-Backed Brain](gbrain-vs-playbook.md)
- [Brain-First Project Knowledge](agent-knowledge.md)
- [Notes / Control Structure](notes-control-structure.md)
