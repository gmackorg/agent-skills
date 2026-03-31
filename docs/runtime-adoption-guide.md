# Runtime Adoption Guide

This reference repo is meant to be consumed by runtimes, editors, CLIs, and bootstrap systems without forcing a runtime-specific skill format.

## Core Rule

Treat `agent-skills` as the content source.

Runtimes should import, install, or index the repo. They should not fork the skill schema unless they have a very strong reason.

## Recommended Consumption Pattern

1. Use `skills/` as the installable skill surface.
2. Use `catalog/installable-skills.json` as the canonical grouped inventory.
3. Use `agents/` as optional agent presets.
4. Use `tools/` for helper scripts or packaged wrappers.
5. Use `skill.json`, `tool.json`, and `agent-metadata.json` as machine-readable metadata.

## Runtime Examples

### `npx skills`

- read installable skills directly from `skills/*/SKILL.md`
- optionally use the catalog as the curated default set

### Codex / Claude

- install or symlink selected skills from the repo into the runtime's skill directory
- preserve the repo as the source of truth instead of editing copies under the home directory

### `smol-agent`

- ingest the generated source config in `catalog/smol-agent.reference.json`
- map groups from the catalog into agent definitions instead of redefining them by hand

### OpenClaw

- keep OpenClaw integration thin
- adapt this repo through an `openclawPlugin` output or a companion plugin repo
- avoid making the content layer OpenClaw-specific

### Other Tools

Tools like internal starters, scaffolds, IDE helpers, `t3-code`, or `bob` should treat this repo as a source catalog:

- discover skills from the catalog
- install by repo URL or local path
- layer their own UX on top without changing the repo contract

## Public / Private Split

Production setups should usually aggregate two repos:

- one public
- one private

The runtime should merge them at install time or index time. The reference repo only demonstrates the shape.
