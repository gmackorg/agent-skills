---
name: llm-session-retrospective
description: Use when reviewing recent Codex, Claude Code, or repo planning work to extract reusable patterns, mistakes, and candidate skills. Automatically searches the current repo, nearby repos, and home skill/session directories, then writes a retrospective report, proposed skill ideas, or scaffolds depending on the request.
---

# LLM Session Retrospective

## Overview

Turn recent agent work into reusable engineering knowledge.

Default to discovery first. Search the current repo, nearby working repos, and local agent directories before asking the user to paste context. Write results into the current repo unless the user explicitly wants research harvested into `agent-skills`.

## Default Behavior

Infer the operating mode from the request:

| Mode | Trigger | Output |
| --- | --- | --- |
| `report` | review, reflect, summarize, retrospective | retrospective only |
| `propose` | what skills should we make, what patterns are emerging | retrospective plus skill candidates |
| `scaffold` | turn this into skills, start creating skills, write stubs | retrospective plus skill candidates plus starter stubs |

If unclear, default to `propose`.

## Discovery Workflow

### 1. Discover context automatically

Search these sources in order:

1. the current repo
2. sibling repos that look active and relevant, especially `../smol-agent`, `../tiered-router`, and `../nix-config`
3. `~/.claude`
4. `~/.codex`

Prioritize:

- `docs/`
- plans
- design notes
- review outputs
- TODO files
- skill files
- generated implementation docs

Use the local context discovery helper:

```bash
skills/local-agent-context-discovery/scripts/discover-local-agent-context.sh /path/to/repo
```

Treat transcript-like sources as "why it happened" context. Treat repo artifacts as the more stable source of truth.

### 2. Extract the reusable layer

Look for:

- decisions that repeated across sessions
- successful workflows worth codifying
- bugs or failures caused by missing process
- prompt patterns that repeatedly worked
- project-specific practices that should stay local instead of becoming public skills

Do not merely summarize chronology. Convert activity into reusable operating guidance.

### 3. Classify findings

Put each finding into one of:

- `keep local`: project-specific, belongs in the current repo
- `private skill`: useful, but sensitive or org-specific
- `public skill`: generally reusable and safe to publish
- `not a skill`: just a one-off fact or decision

### 4. Write to the current repo by default

Default output path:

```text
docs/retrospectives/YYYY-MM-DD-<topic>.md
```

If `docs/retrospectives/` does not exist, create it.

Only write to `agent-skills` if the user explicitly asks for cross-project skill-harvesting.

## Output Contract

Use the output template in [references/output-template.md](references/output-template.md).

Minimum sections:

- scope scanned
- high-signal patterns
- mistakes and friction
- candidate skills
- keep-local items
- recommended next actions

For `scaffold` mode, include a `Starter Stubs` section with:

- skill name
- one-line description
- why it should exist
- likely bundled resources

## Public Skill Heuristics

Promote a pattern into a public skill when most of these are true:

- it appeared in more than one repo or session
- it solves a repeatable problem
- it does not depend on private company context
- it teaches a workflow or decision pattern, not just a fact
- another agent would plausibly discover and use it

Keep it private when:

- it references internal services
- it exposes sensitive legal, product, or customer context
- it is tightly coupled to one team or monorepo template

## Quick Reference

### What to search

- `docs/`
- `*PLAN*.md`
- `*DESIGN*.md`
- `*REVIEW*.md`
- `*TODO*.md`
- `SKILL.md`
- `skill.md`

### What to produce

- `report`: retrospective
- `propose`: retrospective plus candidate skills
- `scaffold`: retrospective plus candidates plus stubs

### Default write location

- current repo: `docs/retrospectives/`
- `agent-skills` only if explicitly requested

## Common Mistakes

- asking the user to paste transcripts before searching locally
- writing a timeline instead of reusable conclusions
- promoting project-specific conventions into public skills
- burying the candidate skill list under too much narrative
- writing into `agent-skills` without explicit user intent

## Example

If the user asks:

`review our recent codex and claude work and tell me what skills we should create`

do this:

1. search the current repo and relevant sibling repos
2. inspect `~/.claude` and `~/.codex` for nearby context
3. write a retrospective into the current repo
4. include a ranked list of candidate skills
5. if the user asks to continue, scaffold the best one next
