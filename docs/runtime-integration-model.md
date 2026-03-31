# Runtime Integration Model

`agent-skills` should stay runtime-agnostic at the content layer.

This reference repo demonstrates three layers:

## 1. Content Layer

- `SKILL.md`
- `skill.json`
- `agents/`
- `tools/`

## 2. Packaging Layer

- `npx skills` compatibility
- Nix flake outputs
- Home Manager module

## 3. Runtime Adapter Layer

Runtimes should adapt this content through thin integrations:

- `smol-agent`
- OpenClaw
- Codex and Claude skill directories
- editor or CLI integrations like scaffolds or launchers

The runtime should select or expose skills. It should not redefine the skill format.

## Desired Outcome

The same repo should be able to feed:

- direct `npx skills` installs
- local developer dotdir installs
- Home Manager or flake-driven bootstrap
- agent catalogs for higher-level runtimes

That is the reason the reference repo keeps the content layer small and the integration layer thin.
