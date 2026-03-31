# 2026-03-29 Skill Portfolio Review

## Scope Scanned

- `skills/`
- [catalog/installable-skills.json](/Volumes/dev/agent-skills/catalog/installable-skills.json)
- [catalog/smol-agent.reference.json](/Volumes/dev/agent-skills/catalog/smol-agent.reference.json)
- [docs/skill-source-inventory.md](/Volumes/dev/agent-skills/docs/skill-source-inventory.md)

## Portfolio Snapshot

- total public skills: `30`
- catalog groups: `11`
- metadata-backed skills: `19`
- legacy monolithic skills without `skill.json`: `11`
- long skills at `300+` lines: `6`

Current catalog groups:

- `workflow-meta`: `agent-skills-catalog-maintenance`, `llm-session-retrospective`, `local-agent-context-discovery`, `x402-smol-agent-workflow`
- `mobile-qa`: `maestro-qa-report`, `maestro-qa`, `react-native-expo-release-readiness`
- `expo`: `expo-build-validation`, `expo-build-submit`
- `react`: `react-project-init`, `react-debugging-advanced`, `react-ui-shadcn-tailwind`
- `nextjs-saas`: `nextjs-project-init`, `stripe-payments-integration`, `saas-turbo-bootstrap`, `migrate-to-vinext`, `nextjs-cloudflare-opennext`, `vinext-cloudflare-hardening`
- `cloudflare`: `cloudflare-workers-bindings-local-dev`, `cloudflare-d1-development`
- `observability`: `sentry-release-triage`, `posthog-product-instrumentation`
- `infrastructure`: `hetzner-cloud-ops`, `namecheap-domain-dns-ops`
- `unity`: `unity-project-setup`, `unity-scripting-advanced`, `unity-debug-workflow`
- `esp32`: `esp32-project-init`, `esp32-wifi-setup`
- `naming`: `brand-domain-naming`

Legacy skills still on the older format:

- `esp32-project-init`
- `esp32-wifi-setup`
- `nextjs-project-init`
- `react-debugging-advanced`
- `react-project-init`
- `react-ui-shadcn-tailwind`
- `saas-turbo-bootstrap`
- `stripe-payments-integration`
- `unity-debug-workflow`
- `unity-project-setup`
- `unity-scripting-advanced`

Longest skills:

- `stripe-payments-integration` (`632` lines)
- `saas-turbo-bootstrap` (`525` lines)
- `react-ui-shadcn-tailwind` (`512` lines)
- `react-debugging-advanced` (`489` lines)
- `unity-scripting-advanced` (`442` lines)
- `brand-domain-naming` (`309` lines)

## High-Signal Findings

### 1. The repo is effectively two skill systems

The newer skills are tighter and composable:

- they use `skill.json`
- they often have one helper script
- they move detail into `references/`
- they behave like orchestrators or focused diagnostics

The older skills are mostly self-contained markdown handbooks:

- no `skill.json`
- no helper scripts
- no split references
- large inline code blocks and example payloads

This matters because the newer skills are visible to Nix metadata aggregation and are easier to compose into `smol-agent`, while the older ones are mostly just installable markdown.

### 2. The strongest lanes already have the right architecture

The best-composed areas in the repo are:

- `workflow-meta`
- mobile / Expo QA and release
- Cloudflare / vinext

These are good because they have a narrow stack shape:

- inventory skill
- report-only or diagnostic skill
- fix-capable or deeper skill
- orchestration skill above them

This is the pattern to reuse elsewhere.

### 3. The largest duplication cluster is React / Next / SaaS

There is heavy overlap between:

- `react-project-init`
- `react-ui-shadcn-tailwind`
- `nextjs-project-init`
- `stripe-payments-integration`
- `saas-turbo-bootstrap`

The biggest offender is `saas-turbo-bootstrap`. It is trying to be:

- a monorepo bootstrap skill
- a Next.js setup skill
- an Expo app skill
- an auth skill
- a billing skill
- an analytics skill
- an observability skill

That is too much surface for one public skill.

### 4. The new observability and infrastructure skills are promising but still thin

These are good first-pass building blocks:

- `sentry-release-triage`
- `posthog-product-instrumentation`
- `hetzner-cloud-ops`
- `namecheap-domain-dns-ops`

But they are not yet a workflow family in the same way the mobile and Cloudflare lanes are. They have focused review skills, but no orchestration layer yet.

### 5. Some groups are under-modeled in `smol-agent`

The current `smol-agent` bridge defaults:

- `general` -> `workflow-meta`
- `mobile` -> `workflow-meta`, `mobile-qa`, `expo`
- `web` -> `workflow-meta`, `react`, `nextjs-saas`, `cloudflare`, `observability`

There is still no first-class:

- `infrastructure` agent definition
- `embedded` / `esp32` agent definition
- `unity` agent definition

That is reasonable for now, but it highlights which families still feel secondary.

## Improvement Opportunities

### Highest-value structural improvement

Migrate the `12` legacy skills to the newer contract:

- add `skill.json`
- split large detail into `references/`
- add helper scripts where deterministic inspection is useful
- remove older `allowed-tools` and `metadata` frontmatter

Recommended migration order:

1. `saas-turbo-bootstrap`
2. `stripe-payments-integration`
3. `nextjs-project-init`
4. `react-ui-shadcn-tailwind`
5. `react-project-init`
6. `react-debugging-advanced`
7. `unity-scripting-advanced`
8. `unity-debug-workflow`
9. `unity-project-setup`
10. `esp32-project-init`
11. `esp32-wifi-setup`

### Skills that should stay separate

Do not merge these current families:

- `maestro-qa-report` + `maestro-qa` + `react-native-expo-release-readiness`
- `expo-build-validation` + `expo-build-submit`
- `nextjs-cloudflare-opennext` + `cloudflare-workers-bindings-local-dev` + `cloudflare-d1-development` + `vinext-cloudflare-hardening`

These already form a good diagnostic-to-orchestration ladder.

### Skills that are too large and should be decomposed

#### `saas-turbo-bootstrap`

Best future shape:

- keep a thin orchestration skill
- move implementation detail into references
- rely on existing narrower skills for auth, billing, analytics, and monitoring

#### `stripe-payments-integration`

Best future shape:

- split by concern:
  - checkout and billing
  - webhook handling
  - customer portal / subscription lifecycle
  - Expo or mobile purchase boundary if still needed

#### React trio

- `react-project-init`
- `react-ui-shadcn-tailwind`
- `react-debugging-advanced`

These should remain distinct, but the init and UI skills should be much tighter and more modern in style.

## Candidate Composite Skills

### 1. `nextjs-saas-foundation`

Purpose:

- orchestration skill for new SaaS apps using the existing stack pieces

Would compose:

- `nextjs-project-init`
- `stripe-payments-integration`
- `posthog-product-instrumentation`
- `sentry-release-triage`

Why it should exist:

- it replaces the current “everything bagel” role of `saas-turbo-bootstrap`
- it can stay thin and route into narrower skills
- it should target a provider-neutral or better-auth-style auth layer instead of restoring vendor-specific coupling

### 2. `saas-stack-hardening`

Purpose:

- post-bootstrap review skill for auth, billing, analytics, and monitoring coverage

Would compose:

- `stripe-payments-integration`
- `posthog-product-instrumentation`
- `sentry-release-triage`

Why it should exist:

- there is currently no public skill that reviews whether the core SaaS stack is coherent after initial setup

### 3. `cloudflare-app-platform-readiness`

Purpose:

- orchestration skill above the current Cloudflare quartet

Would compose:

- `nextjs-cloudflare-opennext`
- `cloudflare-workers-bindings-local-dev`
- `cloudflare-d1-development`
- `vinext-cloudflare-hardening`

Why it should exist:

- the component skills are good, but there is no top-level “what does this repo need to ship on Cloudflare” skill yet

Note:

- this is probably the future architecture skill you already expect, so it should wait until the lower-level skills are exercised more.

### 4. `domain-to-host-cutover`

Purpose:

- plan DNS, domain, and infrastructure cutovers cleanly

Would compose:

- `namecheap-domain-dns-ops`
- `hetzner-cloud-ops`

Why it should exist:

- this is a real deployment workflow boundary
- it is narrower and more useful than a generic “infra” umbrella skill

### 5. `agent-skills-repo-evolution`

Purpose:

- turn retrospective findings into catalog changes and actual skill backlog proposals

Would compose:

- `llm-session-retrospective`
- `agent-skills-catalog-maintenance`
- `local-agent-context-discovery`

Why it should exist:

- these skills already act like a family
- there is still no explicit top-level “harvest and evolve the skills repo” orchestrator

## Keep-Local or Later

These are good candidates, but not yet clearly worth publicization:

- app-specific controlsfoundry workflows
- Level Forge content/release workflows
- ForgeGraph worker or graph operations
- broader Cloudflare architecture decision skills

They likely need one more pass of real use before becoming public skills.

## Recommended Next Actions

### Immediate

1. migrate one legacy cluster instead of random individual skills
2. start with the Next / SaaS cluster
3. replace `saas-turbo-bootstrap` with a thin orchestrator instead of expanding it further

### Near-Term

1. add `skill.json` to every remaining legacy skill
2. split long inline examples into `references/`
3. add scripts only where inventory or validation is deterministic and repeatable

### Best next composite skill

If only one new composite skill should be created next, it should be:

- `nextjs-saas-foundation`

That is the clearest place where the current repo has multiple strong components but still relies on one oversized legacy skill to cover the combined workflow.
