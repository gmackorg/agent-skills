# Agent Skills Reference

This repo is a reference implementation of what an `agent-skills` repo can look like.

It is intentionally small. It is not meant to be a mirrored production skills library.

Use this repo to copy the contract:

- `skills/<skill-name>/SKILL.md`
- optional `skill.json`
- optional `references/`
- optional `scripts/`
- `agents/`
- `tools/`
- `catalog/`
- `docs/`
- `flake.nix`

## What This Repo Is

- a skeleton for individuals, teams, and orgs
- a demonstration of `npx skills` compatible layout
- an example of metadata-backed skills and agents
- an example of Nix / Home Manager packaging
- an example of a small `smol-agent` source catalog

## What This Repo Is Not

- a large public production skill library
- a personal or org-specific source of truth
- a place to mirror every skill from another repo

## Example Contents

- two example skills
- one example agent definition
- one example helper tool
- a generated install catalog
- a generated `smol-agent` reference config

## Recommended Real-World Setup

For actual use, prefer:

1. one real public skills repo
2. one separate private skills repo
3. this reference repo only as a pattern to copy or adapt

## Local Usage

List the example skills:

```bash
npx skills add . --list
```

Install everything from this reference repo:

```bash
npx skills add . --skill '*'
```

## Layout

```text
skills/
agents/
tools/
catalog/
docs/
scripts/
nix/
flake.nix
```

## Important Docs

- [reference-repo-model.md](/Users/mackieg/.config/superpowers/worktrees/agent-skills/gmackorg-reference-skeleton/docs/reference-repo-model.md)
- [runtime-integration-model.md](/Users/mackieg/.config/superpowers/worktrees/agent-skills/gmackorg-reference-skeleton/docs/runtime-integration-model.md)
- [skill-metadata-contract.md](/Users/mackieg/.config/superpowers/worktrees/agent-skills/gmackorg-reference-skeleton/docs/skill-metadata-contract.md)
- [nix-consumption-example.md](/Users/mackieg/.config/superpowers/worktrees/agent-skills/gmackorg-reference-skeleton/docs/nix-consumption-example.md)
