---
name: nextjs-cloudflare-opennext
description: Use when adopting, validating, or hardening a Next.js deployment on Cloudflare Workers via OpenNext. Maps the repo shape, checks adapter and Wrangler prerequisites, reviews bindings and local-dev setup, and produces an adoption plan before deeper implementation or migration work.
---

# Next.js Cloudflare OpenNext

## Overview

Use this skill when a project should stay on Next.js but run on Cloudflare Workers through OpenNext.

This is an adoption and hardening skill, not a one-shot migration script. Its job is to:

- determine whether the repo is a good OpenNext candidate
- map the current Cloudflare and Next.js deployment surface
- identify missing adapter, bindings, and local-dev setup
- produce a concrete adoption plan before code changes or deploy work

If the user actually wants to leave Next.js and move to vinext, use [migrate-to-vinext](../migrate-to-vinext/SKILL.md) instead.

## Default Workflow

### 1. Confirm the skill applies

Start by checking that the repo is actually a Next.js app:

- `package.json` includes `next`
- app code lives under `app/`, `src/app/`, `pages/`, or `src/pages`

If the project is not a Next.js app, stop and say this skill does not apply.

### 2. Inventory the repo surface

Use the helper to gather a first-pass snapshot:

```bash
skills/nextjs-cloudflare-opennext/scripts/plan-opennext-adoption.sh \
  --repo /path/to/app
```

Treat that output as an inventory, not a final recommendation.

Explicitly identify:

- Next.js router shape: App Router, Pages Router, or mixed
- current deployment target: Vercel, Node server, static export, or existing Workers setup
- current Cloudflare files: `wrangler.jsonc`, `wrangler.toml`, `.dev.vars`, `.env*`
- current adapter signals: `@opennextjs/cloudflare`, `open-next`, or `opennext.config.*`
- data and platform dependencies: D1, KV, R2, Durable Objects, Queues, Workflows, or plain HTTP APIs

### 3. Check the OpenNext boundary

Before proposing work, verify the repo shape against the OpenNext model:

- the app should remain a Next.js app, not be rewritten around a new framework
- deployment should target Cloudflare Workers, not a generic Node host
- bindings should be planned through Wrangler configuration, not ad hoc environment drift
- local development should be designed around `next dev` / local preview with Cloudflare bindings available

Use [references/adoption-checklist.md](references/adoption-checklist.md) as the proof checklist.

### 4. Review bindings and local development

OpenNext on Cloudflare is usually blocked by missing binding discipline, not just missing packages.

Check for:

- a Wrangler config at repo root
- typed binding generation strategy, such as `wrangler types --env-interface CloudflareEnv`
- whether bindings should be local-only or remote during development
- whether secrets are expected in `.dev.vars`, `.env`, or some other system

If the repo already uses Cloudflare resources, document which ones are:

- already declared in Wrangler
- only implied in app code
- missing local-dev coverage

Do not wave this through. Binding and local preview drift is one of the main sources of broken first deployments.

### 5. Produce an adoption plan

Write a concise plan with:

- current repo shape
- OpenNext fit assessment
- missing packages or config
- missing bindings or local-dev setup
- deployment blockers
- recommended next skill or implementation step

Default output location:

```text
docs/cloudflare/YYYY-MM-DD-opennext-adoption.md
```

## Output Contract

Minimum sections:

- summary
- current state
- OpenNext fit
- required changes
- binding and local-dev notes
- rollout sequence

The output should help the next agent start implementation without rediscovering the repo.

## Quick Reference

| Need | Action |
| --- | --- |
| inventory the repo quickly | run the helper |
| stay on Next.js and deploy to Workers | use this skill |
| leave Next.js for a Vite-based path | use `migrate-to-vinext` |
| validate bindings and dev setup | review Wrangler config and binding access |

## Common Mistakes

- treating OpenNext adoption as only an `npm install` step
- skipping Wrangler config and binding review
- mixing up local `.env` usage with Cloudflare binding access
- assuming Vercel-specific behavior will transfer unchanged
- choosing this skill when the real goal is a vinext migration

## Example

If the user asks:

`help me move this next app onto cloudflare workers with opennext`

do this:

1. confirm it is a real Next.js app
2. inventory the repo, deployment target, and Cloudflare files
3. check whether `@opennextjs/cloudflare` and Wrangler setup exist
4. map bindings and local-dev gaps
5. write an adoption plan with the narrowest safe next implementation step
