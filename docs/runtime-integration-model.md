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
- editor or CLI integrations

The runtime should select or expose skills. It should not redefine the skill format.
