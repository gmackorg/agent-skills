# Reference Repo Model

This repo is the smallest credible reference implementation of an `agent-skills` repo.

The point is to demonstrate:

- directory layout
- metadata conventions
- packaging conventions
- runtime adapter surfaces

The point is not to host a full real-world skill library.

## Recommended Pattern

Use this repo as a template for:

- `your-org/agent-skills`
- `your-org/agent-skills-private`

Keep real public and private skill content in those repos. Keep this repo small and educational.

## What A Reference Repo Should Contain

- a few example skills
- a small example agent set
- a small example tool
- contract docs
- packaging examples
- generated catalog examples

## What A Reference Repo Should Avoid

- one person’s full production skill inventory
- mirrored private content
- large domain-specific skill families
- runtime-specific lock-in

## Minimal Contract

At minimum, demonstrate:

- `skills/<skill-name>/SKILL.md`
- `skills/<skill-name>/skill.json`
- optional `references/`
- optional `scripts/`
- `agents/`
- `tools/`
- `catalog/`
- `docs/`
- `flake.nix`
