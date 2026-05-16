# Tier 1 Minimal Example

Fictional project: `example-cli-helper`

Use Tier 1 for small public tools, docs repos, examples, and utility libraries.

This tier is intentionally light. It gives users enough project context to install, validate, and contribute without adding private notes control, worktree rules, or version-claim scripts that the repo does not need.

Typical files:

```text
example-cli-helper/
  README.md
  AGENTS.md
  CHANGELOG.md
  LICENSE
  SECURITY.md
  .github/workflows/validate.yml
```

Usually skip:

- Notes-vault control folder.
- `VERSION` file.
- Version-claim scripts.
- Exact-SHA deploy notes.
- Mandatory worktrees.

Use Git tags or GitHub releases for meaningful versions.

## How To Apply

1. Copy `templates/AGENTS.md.template` into `AGENTS.md` and fill the project-specific commands.
2. Copy `templates/CHANGELOG.md.template` into `CHANGELOG.md`.
3. Add a normal `README.md`, `LICENSE`, and `SECURITY.md` if users run local tooling.
4. Add lightweight CI that proves the package validates.
5. Publish meaningful versions with Git tags and GitHub Releases.

Do not add `VERSION`, notes vault folders, or cleanup scripts unless the repo starts having active PR/version coordination or concurrent-agent work.
