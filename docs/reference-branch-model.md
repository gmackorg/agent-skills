# Reference Branch Model

This repo uses branches to present the reference surface clearly, not to separate real private content.

## Intended Meaning

- `main`: the branch most users should read first
- `reference`: a branch that mirrors `main` so tooling, examples, or docs can point at a stable reference name
- `private`: a public branch that explains how a separate private repo should be structured

## What The `private` Branch Is For

Use the `private` branch to demonstrate:

- how `your-org/agent-skills-private` should look
- how a public repo and a private repo share the same layout
- how bootstrap flows should install from both repos

Do not use the `private` branch for:

- real secrets
- internal-only skills
- customer-specific prompts
- operational runbooks that should not be public

## Recommended Real Deployment

Treat this repo as the documentation and demo surface.

For actual use, keep content in separate repos:

- `your-org/agent-skills`
- `your-org/agent-skills-private`

Those repos can share the same folder contract, metadata contract, and packaging examples shown here.
