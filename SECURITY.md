# Security

This repo is a public playbook and template set. Do not open issues or pull requests that include secrets, production hostnames, private project names, customer data, local notes, or private operating procedures.

Before publishing adapted files, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sanitize-check.ps1
```

You can add project-specific private terms to `.sanitize-denylist.local`. Keep that file out of git.

If you find a public-safety issue in this repo, open a GitHub issue with a sanitized description and no sensitive values.
