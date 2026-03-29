# Skill Source Inventory

Snapshot date: 2026-03-28

This note tracks outside skill sources and related repos worth reviewing for possible import, adaptation, or inspiration. It is intentionally lightweight and grouped into:

- public candidates
- private candidates
- not-found-yet gaps

## Public Candidates

### Cloudflare

- `cloudflare-troubleshooting`
  Source: [daymade/claude-code-skills](https://github.com/daymade/claude-code-skills)
  Why look: Cloudflare diagnostics and troubleshooting workflow.

- `cloudflare`
  Source: [sundial-org/awesome-openclaw-skills](https://github.com/sundial-org/awesome-openclaw-skills)
  Why look: Cloudflare CLI workflow for DNS, cache, and Workers routes.

- `cloudflare-2`
  Source: [sundial-org/awesome-openclaw-skills](https://github.com/sundial-org/awesome-openclaw-skills)
  Why look: Cloudflare API workflow for DNS, tunnels, and zone administration.

- `send-me-my-files-r2-upload-with-short-lived-signed-urls`
  Source: [sundial-org/awesome-openclaw-skills](https://github.com/sundial-org/awesome-openclaw-skills)
  Why look: R2 and signed URL flow patterns.

### vinext

- `migrate-to-vinext`
  Source: local skill at [migrate-to-vinext](/Volumes/dev/agent-skills/skills/migrate-to-vinext/SKILL.md)
  Why look: already the strongest concrete vinext skill in hand.

### Namecheap

- `domain-dns-ops`
  Source: [sundial-org/awesome-openclaw-skills](https://github.com/sundial-org/awesome-openclaw-skills)
  Why look: explicitly spans Cloudflare, DNSimple, and Namecheap.

- `premium-domains`
  Source: [sundial-org/awesome-openclaw-skills](https://github.com/sundial-org/awesome-openclaw-skills)
  Why look: adjacent domain acquisition and registrar workflow.

### Hetzner

- `hetzner-cloud`
  Source: [sundial-org/awesome-openclaw-skills](https://github.com/sundial-org/awesome-openclaw-skills)
  Why look: Hetzner Cloud CLI management workflow.

### Stripe

- `stripe-payments-integration`
  Source: local skill at [stripe-payments-integration](/Volumes/dev/agent-skills/skills/stripe-payments-integration/SKILL.md)
  Why look: already relevant and maintained here.

- `stripe`
  Source: [sundial-org/awesome-openclaw-skills](https://github.com/sundial-org/awesome-openclaw-skills)
  Why look: external reference point for payment workflow coverage.

## Private Candidates

These look better as app- or org-specific skills than public imports.

### ControlsFoundry

- `controlsfoundry-release-loop`
- `controlsfoundry-cloudflare-stack`

### Level Forge

- `levelforge-content-release`

### ForgeGraph

- `forgegraph-worker-ops`

## Not Found Yet

These areas did not produce a strong public skill candidate in this pass.

### Sentry

- no clear public skill source identified yet
- likely better explored via MCP/tools or a private app-specific workflow skill

### PostHog

- no clear public skill source identified yet
- likely better explored via MCP/tools or private product analytics workflows

### QuickBooks

- no strong public skill source identified yet

### Dylan Milroy

- no clear primary-source repo or skill collection identified in this pass
- if there is a specific repo to mine, add it here explicitly next round

## Best Immediate Review Order

1. [migrate-to-vinext](/Volumes/dev/agent-skills/skills/migrate-to-vinext/SKILL.md)
2. [stripe-payments-integration](/Volumes/dev/agent-skills/skills/stripe-payments-integration/SKILL.md)
3. [daymade/claude-code-skills](https://github.com/daymade/claude-code-skills)
4. [sundial-org/awesome-openclaw-skills](https://github.com/sundial-org/awesome-openclaw-skills)

## Adjacent Internal Docs

- [cloudflare-next-skill-opportunities.md](/Volumes/dev/agent-skills/docs/cloudflare-next-skill-opportunities.md)
