# OpenNext Adoption Checklist

Use this checklist when deciding whether a Next.js repo is ready to run on Cloudflare Workers through OpenNext.

## Repo Fit

- `package.json` contains `next`
- the app uses App Router, Pages Router, or a mixed Next.js shape
- the desired outcome is still a Next.js app on Workers, not a vinext rewrite
- the team accepts Cloudflare Worker deployment constraints and Wrangler-managed infrastructure

## Platform Setup

- `@opennextjs/cloudflare` is installed or planned
- a root Wrangler config exists or is explicitly part of the plan
- local development strategy is clear:
  - simulated local bindings
  - or remote bindings when justified
- generated binding types are part of the workflow

## App Surface

- routing, middleware, and rendering strategy are known
- environment variables are mapped to the right runtime boundary
- Cloudflare resources are identified:
  - KV
  - D1
  - R2
  - Durable Objects
  - Queues
  - Workflows
- any Vercel-specific assumptions are called out before migration work starts

## Rollout Discipline

- first milestone is adoption proof, not a big-bang deployment rewrite
- local preview comes before first production cutover
- bindings and secrets are verified in the same environment model the app will use
- the final plan names the next concrete implementation step
