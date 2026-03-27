---
name: agent-skills-catalog-maintenance
description: Use when adding, migrating, or reorganizing skills, tools, or agent definitions in an `agent-skills` style repo and you need to keep the catalog surface coherent. Maintains a merged view of metadata-backed skills, checks for missing metadata, and updates repo-facing catalog snapshots without treating ad hoc notes as the source of truth.
---

# Agent Skills Catalog Maintenance

## Overview

Keep the repo's discovery surface coherent as skills, tools, and agent definitions evolve.

This skill is for catalog maintenance, not for inventing skill ideas from scratch. Use it after adding or migrating content so the repo can still answer simple questions like:

- what skills exist
- which ones are public or private
- which agents they support
- which helper tools they expect

## Default Workflow

### 1. Discover metadata-backed entries

Look for:

- `skills/*/skill.json`
- `tools/*/tool.json`
- `agents/*/agent-metadata.json`

Ignore:

- stray markdown notes
- temporary experiments without metadata
- copied skill artifacts that are not part of the current repo contract

### 2. Check for contract drift

Flag when any of these are true:

- `SKILL.md` exists without `skill.json`
- metadata points at a missing `SKILL.md`
- a helper tool is referenced but missing
- an agent definition exists without `agent-metadata.json`
- the README or other repo-facing inventory is clearly stale

### 3. Generate a local catalog snapshot

Use the bundled helper:

```bash
skills/agent-skills-catalog-maintenance/scripts/generate-catalog-snapshot.sh /path/to/repo
```

Treat the generated snapshot as a derived artifact, not the canonical source of truth. The canonical source remains the repo metadata files.

### 4. Update the human-facing surface

When the repo has materially changed:

- update README skill summaries if needed
- update catalog or inventory docs if they exist
- keep the output concise and derived from metadata

Do not create sprawling documentation just to mirror the metadata.

## Output Contract

When asked to maintain the catalog, produce:

- findings about drift or missing metadata
- a short list of added/removed/changed entries
- the path of the generated snapshot
- any follow-up cleanup needed

## Quick Reference

| Need | Action |
| --- | --- |
| see what exists | scan metadata-backed entries |
| detect drift | compare metadata paths against real files |
| generate current inventory | run the catalog snapshot helper |
| update repo surface | touch README or catalog docs only if stale |

## Common Mistakes

- treating README text as the canonical catalog
- letting copied skills exist without metadata
- mixing private-repo assumptions into a public catalog
- writing a giant manual inventory when the metadata can generate it

## Example

If the user asks:

`update the catalog after we migrated skills`

do this:

1. scan the repo for `skill.json`, `tool.json`, and `agent-metadata.json`
2. report drift or missing metadata
3. generate a local snapshot
4. update only the repo-facing docs that are now obviously stale
