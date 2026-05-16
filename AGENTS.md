# AGENTS.md - Agent Project Playbook

This repo publishes public-safe project setup guidance and templates for agent-assisted software work.

## Boundaries

- Keep the repo public-safe: no secrets, private local paths, private project names, customer data, production hostnames, or private operating procedures.
- Do not add raw notes vault files, sessions, task ledgers, or control folders.
- Treat templates as examples until copied into a target project and filled with project-specific values.

## Validation

Run before claiming changes are ready:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sanitize-check.ps1
```

For PowerShell 7:

```powershell
pwsh ./scripts/sanitize-check.ps1
```
