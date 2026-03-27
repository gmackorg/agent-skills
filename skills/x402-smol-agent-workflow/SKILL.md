---
name: x402-smol-agent-workflow
description: Use when working on the x402 challenge, `smol-agent`, or adjacent agent-economics demos where the task involves turning a small agent system into a credible product or challenge submission. Guides repo mapping, milestone shaping, demo-path prioritization, and what should become a reusable skill versus local glue.
---

# X402 Smol Agent Workflow

## Overview

Treat x402 and `smol-agent` work as a product-and-demo system, not just a codebase.

Prioritize the shortest path to a convincing end-to-end story:

- what the agent does
- why it matters
- how it gets paid or gated
- what the demo path looks like

## Default Workflow

### 1. Map the repo before editing

Identify:

- runtime entrypoints
- challenge-specific surfaces
- payment or access control points
- evaluation or demo scripts
- local glue that should stay local
- repeated patterns that should become reusable skills

### 2. Shape work as milestones

Break work into:

- demo-path critical
- infrastructure support
- polish
- reusable skill extraction

If a task does not improve the demo path, remove it or defer it.

### 3. Prefer reusable abstractions only when repeated

Promote work into a shared skill when:

- the pattern appears outside x402
- the pattern is not challenge-specific
- another repo would benefit from the same instructions

Otherwise keep it local to `smol-agent`.

### 4. Preserve the challenge story

Every major change should make at least one of these clearer:

- onboarding
- challenge objective
- payment or x402 mechanism
- agent behavior
- proof of success

## Quick Reference

| Need | Default action |
| --- | --- |
| unclear repo shape | map entrypoints and demo surfaces first |
| too many ideas | rank by demo impact |
| repeated pattern | consider a public skill |
| challenge-specific glue | keep local |

## Common Mistakes

- optimizing internals before the demo path works
- extracting public skills too early
- conflating challenge-specific rules with general-purpose workflows
- shipping a clever system without a legible story

## Example

If the task is:

`help us make smol-agent stronger for the x402 challenge`

start by:

1. mapping the runtime and demo path
2. identifying the critical payment or access flow
3. ranking the smallest set of improvements that make the challenge story stronger
4. listing any repeated patterns that should later become public skills
