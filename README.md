# Agent Skills Library

This repo is a tracked source of truth for reusable agent skills and a smaller set of example agent definitions. The immediate goal is to keep the installable skill surface compatible with `npx skills` while growing stronger mobile, QA, and release-engineering coverage.

## Current Shape

The installable part of the repo is the `skills/` directory.

Each installable skill should live at:

```text
skills/<skill-name>/SKILL.md
```

`npx skills add . --list` currently detects the skills in this repo successfully.

The `agents/` directory is auxiliary. It contains example agent definitions, but the primary maintained artifact here should be reusable skills.

## Local Usage

List the skills available from this repo:

```bash
npx skills add . --list
```

Install one or more skills from this repo:

```bash
npx skills add . --skill expo-build-validation
npx skills add . --skill expo-build-submit --global
```

Install everything from this repo:

```bash
npx skills add . --skill '*'
```

## Repo Conventions

- Keep installable skills under `skills/<skill-name>/SKILL.md`.
- Add machine-readable metadata at `skills/<skill-name>/skill.json` when a skill has declarative dependency or bootstrap needs.
- Prefer minimal frontmatter: `name` and `description`.
- Move large supporting material into `references/`.
- Put reusable automation in `scripts/`.
- Treat `docs/` as repo guidance, not skill payload.
- Avoid flat markdown files in `skills/` for new work; prefer skill folders.

## Nix Contract

This repo now includes a starter `flake.nix` and Home Manager module.

Current purpose:

- aggregate `skill.json` metadata from the repo
- aggregate `tool.json` metadata from the repo
- aggregate `agent-metadata.json` metadata from the repo
- expose `skillMetadata` as a flake output
- expose `toolMetadata` and packaged helper tools as flake outputs
- expose `agentMetadata` as a flake output
- expose `homeManagerModules.default` for declarative installation

The split is:

- `SKILL.md`: agent-facing instructions
- `skill.json`: machine-facing dependency and install metadata
- `tool.json`: machine-facing metadata for repo-owned helper tools
- `agent-metadata.json`: machine-facing metadata for agent definitions

See:

- [docs/skill-metadata-contract.md](/Volumes/dev/agent-skills/docs/skill-metadata-contract.md)
- [docs/nix-consumption-example.md](/Volumes/dev/agent-skills/docs/nix-consumption-example.md)
- [flake.nix](/Volumes/dev/agent-skills/flake.nix)
- [home-manager-module.nix](/Volumes/dev/agent-skills/nix/home-manager-module.nix)

## Current Focus

The next area to build out is mobile development and QA:

- React Native / Expo release readiness
- Maestro-driven mobile QA
- App Store review preparation
- Better tracking of globally installed skills managed outside the repo
- Cross-project retrospective and skill-harvesting workflows
- x402 and `smol-agent` workflow support

See:

- [docs/mobile-skills-roadmap.md](/Volumes/dev/agent-skills/docs/mobile-skills-roadmap.md)
- [docs/installed-global-skills.md](/Volumes/dev/agent-skills/docs/installed-global-skills.md)

## Existing Skills

Current installable skills include:

- Workflow/meta: `local-agent-context-discovery`, `llm-session-retrospective`, `x402-smol-agent-workflow`, `agent-skills-catalog-maintenance`
- Mobile QA: `maestro-qa-report`, `maestro-qa`
- Release orchestration: `react-native-expo-release-readiness`
- Expo: `expo-build-validation`, `expo-build-submit`
- React: `react-project-init`, `react-debugging-advanced`, `react-ui-shadcn-tailwind`
- Next.js / SaaS: `nextjs-project-init`, `clerk-auth-integration`, `stripe-payments-integration`, `saas-turbo-bootstrap`
- Unity: `unity-project-setup`, `unity-scripting-advanced`, `unity-debug-workflow`
- ESP32: `esp32-project-init`, `esp32-wifi-setup`

## Notes

Some existing skills still reflect an older Kiro-style authoring format. They are installable today, but the repo should keep moving toward the simpler open skills layout used by `npx skills`.

## Next Steps

The highest-value additions from here are:

- Next.js / Cloudflare / vinext workflow coverage
- a generated merged catalog across public and private repos
- more public workflow skills harvested from real `smol-agent`, x402, and adjacent repo work

See:

- [docs/cloudflare-next-skill-opportunities.md](/Volumes/dev/agent-skills/docs/cloudflare-next-skill-opportunities.md)
