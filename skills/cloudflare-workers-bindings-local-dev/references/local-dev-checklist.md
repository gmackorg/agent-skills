# Local Bindings Checklist

Use this checklist when validating a Cloudflare Workers local-development setup.

## Config

- a root `wrangler.jsonc` or `wrangler.toml` exists
- top-level bindings are intentional
- environment-specific bindings are explicitly redeclared when needed
- local environment files are documented:
  - `.dev.vars`
  - `.dev.vars.<environment>`
  - `.env`
  - `.env.<environment>`

## Bindings

- D1 declarations are present and local-development expectations are clear
- KV, R2, Queues, and service bindings are declared where the app expects them
- Durable Objects and Workflows are reviewed for local-dev limitations
- remote bindings are only enabled where they are actually needed

## App Access

- Worker code accesses bindings through the runtime environment model
- `process.env` usage is deliberate and not standing in for real bindings
- local docs match the actual `wrangler dev` workflow

## Rollout

- the project can explain which resources are simulated locally
- persistent local state strategy is documented when relevant
- the next config or implementation step is explicit
