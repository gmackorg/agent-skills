---
name: reference-layout-audit
description: Use when auditing an `agent-skills` style repo to see whether the expected reference layout is present. Demonstrates a metadata-backed skill with a helper script and a small output template.
---

# Reference Layout Audit

## Overview

Use this as an example of a diagnostic skill with a bundled helper.

## Default Workflow

Run the helper:

```bash
skills/reference-layout-audit/scripts/inspect-reference-layout.sh \
  --repo /path/to/repo
```

Then compare the output against [references/report-template.md](references/report-template.md).

## What To Check

- `skills/`
- `agents/`
- `tools/`
- `catalog/`
- `docs/`
- `flake.nix`

## Output Contract

Write a short report saying which reference-layout pieces are present and which are missing.
