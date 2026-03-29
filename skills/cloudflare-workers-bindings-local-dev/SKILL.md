---
name: cloudflare-workers-bindings-local-dev
description: Use when setting up, debugging, or hardening local development for a Cloudflare Workers project that depends on bindings like D1, KV, R2, Queues, Durable Objects, or Workflows. Inventories Wrangler config, environment-specific bindings, and local-versus-remote development assumptions, then produces a concrete local-dev plan.
---

# Cloudflare Workers Bindings Local Dev

## Overview

Use this skill when a Cloudflare Workers project works in theory but local development is unclear, drifting, or broken because of bindings.

This skill focuses on one narrow problem:

- what bindings exist
- how they are declared
- which environments they are attached to
- whether local development should use local simulations or remote bindings

It should usually run before deeper app-specific implementation work.

## Default Workflow

### 1. Inventory the Worker surface

Start with the helper:

```bash
skills/cloudflare-workers-bindings-local-dev/scripts/inspect-cloudflare-bindings.sh \
  --repo /path/to/project
```

Use it to identify:

- `wrangler.jsonc` or `wrangler.toml`
- `env.*` sections and environment-specific config
- `.dev.vars*` and `.env*` files
- binding declarations for D1, KV, R2, Queues, Durable Objects, Workflows, and service bindings

Treat the helper output as a snapshot, not the final answer.

### 2. Check the environment boundary

Cloudflare bindings and environment variables are not something to hand-wave.

Explicitly verify:

- which bindings are declared at the top level
- which bindings must be redeclared per Wrangler environment
- whether local development should use local simulations
- whether any binding truly needs remote mode during local development

Be careful with assumptions here. Per-environment binding drift is a common failure mode.

### 3. Check local state strategy

Document how local state should work for the project:

- where local D1 state should persist
- whether KV/R2/Queues should be simulated locally
- whether any bindings are unsupported in a purely local mode
- whether the team is relying on remote resources during development

If remote bindings are used, call out why and which resources they affect.

### 4. Check app access patterns

Look for binding access in code and compare it against Wrangler declarations.

Flag cases where:

- code references bindings that are not declared
- bindings are declared but apparently unused
- the app mixes `process.env` assumptions with runtime `env` binding access
- local docs imply one mode while config is set up for another

### 5. Produce a local-dev plan

Write a concise plan with:

- current binding inventory
- local-vs-remote decisions
- environment drift risks
- required config changes
- required seeding or persistence steps

Default output location:

```text
docs/cloudflare/YYYY-MM-DD-bindings-local-dev.md
```

## Output Contract

Minimum sections:

- summary
- current bindings
- environment model
- local state and persistence
- missing or inconsistent declarations
- next implementation steps

## Quick Reference

| Need | Action |
| --- | --- |
| inventory binding config | run the helper |
| check environment-specific declarations | inspect Wrangler env sections |
| decide local vs remote resources | review binding support and team workflow |
| fix app/runtime drift | compare code usage with declared bindings |

## Common Mistakes

- assuming bindings inherit automatically across Wrangler environments
- using remote bindings by default without a reason
- letting `.env` usage drift away from real Worker bindings
- treating local D1/KV/R2 state as disposable without documenting persistence needs
- debugging app code before proving the binding model is coherent
