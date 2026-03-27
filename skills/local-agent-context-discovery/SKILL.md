---
name: local-agent-context-discovery
description: Use when an agent should discover relevant local context on its own before asking for pasted files or paths. Scans the current repo, nearby working repos, and local Claude or Codex directories for plans, docs, reviews, TODOs, and skill artifacts so later workflows can start from real project evidence instead of user-supplied excerpts.
---

# Local Agent Context Discovery

## Overview

Discover likely-relevant local context before asking the user to paste it.

Use this when the job depends on recent plans, design notes, reviews, skill files, or agent workspace artifacts that probably already exist on disk. This skill does not analyze the findings deeply. It builds the search surface for later skills and workflows.

## Default Workflow

### 1. Search the highest-signal locations first

Default search order:

1. the current repo
2. sibling repos that are likely part of the same working set, especially `../smol-agent`, `../tiered-router`, and `../nix-config`
3. `~/.claude`
4. `~/.codex`

Search for:

- `docs/`
- `*PLAN*.md`
- `*DESIGN*.md`
- `*REVIEW*.md`
- `*TODO*.md`
- `SKILL.md`
- `skill.md`
- `AGENTS.md`

### 2. Use the bundled helper

Run:

```bash
skills/local-agent-context-discovery/scripts/discover-local-agent-context.sh /path/to/repo
```

Default output is tab-separated:

```text
source<TAB>absolute-path
```

For machine use, request JSON lines:

```bash
skills/local-agent-context-discovery/scripts/discover-local-agent-context.sh /path/to/repo --format json
```

### 3. Triage before reading deeply

Prefer opening:

- current-repo results before sibling repos
- design and review artifacts before generic notes
- skill files when the task might already be encoded as a skill

Do not read everything. Use discovery output to choose the smallest useful next set of files.

### 4. Ask for input only after local discovery fails

Ask the user to paste or point to files only when:

- the local search surface is clearly insufficient
- the relevant repo or directory is not present
- the needed source is external to the machine

## Output Contract

When using this skill in a larger workflow, report:

- the search roots scanned
- the highest-signal files found
- any obvious gaps such as missing sibling repos or empty home directories

If the user asks for a written artifact, keep it short and place it in the current repo unless directed otherwise.

## Quick Reference

| Need | Action |
| --- | --- |
| get likely context fast | run the helper with default text output |
| feed another script or tool | run the helper with `--format json` |
| reduce noise | read current-repo hits first |
| avoid unnecessary asks | search locally before requesting pasted context |

## Common Mistakes

- asking for pasted transcripts before checking the local machine
- reading every discovered file instead of triaging
- treating home-directory noise as more important than the current repo
- skipping sibling repos that are clearly part of the same project cluster

## Example

If the user asks:

`look at our recent work and tell me what patterns are emerging`

do this:

1. run local context discovery for the current repo
2. inspect the highest-signal files from the current repo and sibling repos
3. only then expand into `~/.claude` or `~/.codex` if needed
