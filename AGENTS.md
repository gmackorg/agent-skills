# Agent Skills Reference

This repo is a public reference implementation for `agent-skills` style repositories.

It is intentionally small and uses example-only content. Do not treat it as a production skill inventory.

## What This Repo Demonstrates

- `skills/` as the installable skill surface
- `agents/` as small agent presets
- `tools/` as helper scripts or packaged wrappers
- `catalog/` as a grouped inventory that other runtimes can read
- `flake.nix` as the packaging and runtime-adapter surface

## OpenClaw Notes

The flake exports an `openclawPlugin` example. It is meant to show the contract shape:

- `name`
- `skills`
- `packages`
- `needs`

For real use, keep production content in separate public and private repos and let your machine config or runtime merge them.

## Public / Private Pattern

Recommended real-world setup:

- `your-org/agent-skills`
- `your-org/agent-skills-private`

This repo stays public and reference-only, including the `private` branch.
