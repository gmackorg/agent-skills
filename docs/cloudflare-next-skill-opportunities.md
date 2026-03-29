# Cloudflare, Next.js, and App-Specific Skill Opportunities

Snapshot date: 2026-03-28

This note captures the next likely skill lanes after the mobile QA push. It focuses on public skills that fit `agent-skills`, plus a smaller set of private app-specific skills that likely belong in `agent-skills-private`.

## What Changed In This Pass

Two existing Expo skills were refactored into the newer repo style:

- `expo-build-validation`
- `expo-build-submit`

They now use minimal frontmatter and push detailed checklists into `references/` rather than carrying the older Kiro-style inline dump.

## Strong Public Skill Candidates

### 1. `nextjs-cloudflare-opennext`

Use when deploying or migrating a Next.js app to Cloudflare Workers via the OpenNext adapter.

Why it should exist:

- Cloudflare’s official path for full-stack Next.js on Workers is now OpenNext, not Pages-first SSR advice.
- This is a distinct workflow from `migrate-to-vinext`.
- It should encode the difference between `npm run dev` on Node and `npm run preview` on `workerd`.

Core scope:

- scaffold or convert to `@opennextjs/cloudflare`
- validate `wrangler` configuration
- enforce preview-before-deploy
- catch runtime and middleware incompatibilities early

### 2. `vinext-cloudflare-hardening`

Use when a project already migrated to vinext and now needs Cloudflare-specific production hardening rather than the migration itself.

Why it should exist:

- `migrate-to-vinext` covers package replacement and config generation.
- It does not yet cover runtime hardening, deploy verification, or Cloudflare-specific review.

Core scope:

- verify Cloudflare deploy path
- validate `wrangler` / worker output assumptions
- check cache, env, and asset behavior
- verify local preview against deployed runtime assumptions

### 3. `cloudflare-workers-bindings-local-dev`

Use when developing Workers apps that rely on D1, KV, R2, Queues, Durable Objects, or service bindings and the real problem is local-vs-remote binding behavior.

Why it should exist:

- Cloudflare’s current local development story is much better than it used to be.
- Remote bindings and local persistence are easy to misuse.
- This is broadly reusable across Next.js, vinext, Hono, and plain Workers apps.

Core scope:

- pick local simulation vs remote binding per resource
- avoid committing `.wrangler/state`
- decide when `wrangler dev`, preview, or remote bindings are the right fit

### 4. `cloudflare-d1-development`

Use when an app uses D1 and needs schema, local development, seed data, or preview/production environment discipline.

Why it should exist:

- D1 is one of the highest-leverage Cloudflare-specific surfaces.
- It appears repeatedly in modern Workers and Next/OpenNext projects.

Core scope:

- local D1 development
- Pages/Workers D1 differences
- migrations and seed flow expectations
- binding and preview assumptions

### 5. `cloudflare-workers-workflows`

Use when building long-running or human-in-the-loop workflows on Cloudflare Workflows.

Why it should exist:

- Workflows are now a stronger product surface than a year ago.
- They fit agent-like orchestration well and are relevant to `smol-agent` and adjacent projects.

Core scope:

- workflow step design
- idempotency and retry boundaries
- event wait patterns
- dashboard visualization and debugging expectations

### 6. `cloudflare-microfrontend-routing`

Use when splitting a larger web app into multiple deployable Workers or framework frontends on Cloudflare.

Why it should exist:

- Cloudflare now has official microfrontend guidance.
- This could matter for product family work or gradual migrations.

Core scope:

- router worker patterns
- service bindings
- asset prefix concerns for framework outputs

## Public Skill Candidates Adjacent To Existing Repo Themes

### `nextjs-cloudflare-migration-review`

A narrower review skill for existing Next.js apps being evaluated for OpenNext vs vinext vs static Pages.

This would complement:

- `migrate-to-vinext`
- future `nextjs-cloudflare-opennext`

### `workers-browser-rendering-automation`

A specialized skill for using Cloudflare Browser Rendering in automation-heavy Workers projects.

This is interesting because it overlaps with QA, screenshots, scraping, and agent workflows.

### `workers-turnstile-integration`

A narrower skill around Cloudflare Turnstile for Next.js and Workers apps.

This is probably more reusable publicly than many app-specific auth flows.

## Existing Skill To Keep, Not Replace

### `migrate-to-vinext`

Keep it.

It already fills an important niche and should remain migration-focused. The better next move is to complement it with Cloudflare/vinext deployment and hardening skills, not overload it.

## Private Skill Candidates

These likely belong in `agent-skills-private`, not the public repo.

### `controlsfoundry-release-loop`

Likely scope:

- app-specific QA checklist
- deployment expectations
- customer-facing rollout discipline
- incident rollback notes

### `levelforge-content-release`

Likely scope:

- content/data pipeline validation
- QA for creation/editing flows
- release notes and regression hotspots

### `forgegraph-worker-ops`

Likely scope:

- graph-specific data/index validation
- Workers or background job health
- cache/invalidation patterns

### `controlsfoundry-cloudflare-stack`

If ControlsFoundry or sibling products converge on a shared Cloudflare runtime stack, a private stack skill would be more useful than many per-app fragments.

## Import / Harvest Opportunities

### Cloudflare

The strongest import surface is not “skills” so much as official framework and platform guidance:

- Cloudflare framework guides
- Cloudflare templates
- D1 / Workers / Workflows docs
- OpenNext for Cloudflare docs and adapter repo

This suggests writing first-party style skills from primary docs rather than copying community prompts.

### Dylan Milroy

I did not find a clear primary-source public repo or skill collection to anchor on in this pass. That means we should not assume there is a trustworthy import target yet.

Inference:

- if there is a specific Dylan Milroy repo you want to mine, it is better to point at it directly in the next pass
- otherwise Cloudflare and OpenNext primary sources are the stronger base

## Recommended Build Order

### Public

1. `nextjs-cloudflare-opennext`
2. `cloudflare-workers-bindings-local-dev`
3. `cloudflare-d1-development`
4. `vinext-cloudflare-hardening`
5. `cloudflare-workers-workflows`

### Private

1. `controlsfoundry-release-loop`
2. one shared Cloudflare stack skill if multiple apps converge
3. app-specific release or content skills only after shared stack patterns are clear

## Sources

- Cloudflare Next.js on Workers guide: https://developers.cloudflare.com/workers/frameworks/framework-guides/nextjs/
- Cloudflare Pages Next.js guide: https://developers.cloudflare.com/pages/framework-guides/nextjs/
- Cloudflare framework guides overview: https://developers.cloudflare.com/workers/framework-guides/
- Cloudflare templates repo: https://github.com/cloudflare/templates
- D1 local development: https://developers.cloudflare.com/d1/build-with-d1/local-development/
- Workers local bindings matrix: https://developers.cloudflare.com/workers/local-development/bindings-per-env/
- Cloudflare Workflows docs: https://developers.cloudflare.com/workflows/
- OpenNext for Cloudflare docs: https://opennext.js.org/cloudflare
- OpenNext for Cloudflare adapter repo: https://github.com/opennextjs/opennextjs-cloudflare
- `migrate-to-vinext` local skill: [migrate-to-vinext](/Volumes/dev/agent-skills/skills/migrate-to-vinext/SKILL.md)
