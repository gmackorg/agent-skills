---
name: brand-domain-naming
description: Use when naming or renaming a product, startup, feature, or app and the work depends on brand identity, design culture, domain research, or TLD tradeoffs. This skill starts by diagnosing the product's brand character from the app itself, treats the current name as a disposable codename unless told otherwise, generates naming territories from that identity, checks `.com`, `.net`, `.ai`, and `.io`, and recommends a full brand-plus-domain direction instead of treating availability alone as success.
---

# Brand Domain Naming

## Overview

Turn product context into a naming recommendation that can survive culture fit, marketing, memorability, and domain reality.

Default to brand identity first, then name territories, then domain paths. A weak identity produces weak names. A weak name with an open domain is still weak. A strong name with no viable domain path is not ready.

## Core Workflow

### 1. Start with a brand identity deep dive

Before generating names, diagnose the product the way a strong design consultation would.

Read:
- landing pages
- in-app copy
- DESIGN.md or equivalent design system
- product plans
- onboarding or marketing copy
- screenshots or UI structure if available

Extract and state:
- who the buyer is
- what emotional state they arrive in
- what promise the product makes
- what proof makes that promise credible
- what cultural lane the product belongs to
- what it must never sound like

Write a compact identity brief before brainstorming names.

Use this shape:
- audience
- stakes
- promise
- proof
- personality
- cultural references
- anti-references
- verbal texture
- trust posture

### 2. Treat the current name as a codename by default

Do not anchor on the current product name unless the user explicitly says it must be preserved.

If a current name exists:
- note it as the current codename
- analyze what it signals
- keep its strengths only if they emerge naturally from the identity brief
- do not build derivatives just because the repo or app already uses it

This matters. Existing names create bad gravity. The point is to find the right public identity, not to rationalize the internal codename.

### 3. Ground the naming work in the product

Read the product materials before suggesting names:
- What the product actually does
- Who buys it
- Why they trust it
- What the visual system implies about tone
- Whether the company wants consumer trust, premium expertise, technical edge, or speed

Extract five short anchors:
- user
- pain
- promise
- proof
- tone

If the product has a design system, use it. Visual language often reveals the right naming lane. A utilitarian, high-trust app should not get a playful startup name unless the product strategy explicitly wants that contrast.

### 4. Choose naming territories before brainstorming names

Do not jump straight to raw ideas. Pick 3-4 territories first.

Common territories:
- outcome: what the user gets
- mechanism: how the product works
- proof: what makes the promise credible
- emotional frame: how the user wants to feel
- category bridge: familiar term plus a distinctive modifier
- cultural signal: the world the brand wants to belong to

For each territory, write one sentence explaining why it fits the product.

### 5. Generate candidates in sets, not one long list

Generate 5-8 names per territory. Favor:
- easy pronunciation
- easy spelling on first hearing
- clear emotional direction
- short names with room for future extension
- names that can plausibly support a `.com`
- names that sound native to the product's culture

Avoid:
- generic AI suffixing
- forced misspellings
- names that need explanation before they sound trustworthy
- names that read like internal codenames

### 6. Score names before checking domains

Use this scorecard:

| Dimension | Question | Weight |
|---|---|---:|
| Brand fit | Does it match the product's tone and category? | 5 |
| Culture fit | Does it feel native to the product's aesthetic and social world? | 5 |
| Clarity | Can a new user roughly infer what it is? | 4 |
| Memorability | Will someone remember and repeat it correctly? | 4 |
| Distinctiveness | Does it avoid sounding interchangeable? | 4 |
| Trust | Does it feel credible for the audience? | 5 |
| Extension room | Can the brand grow beyond one feature or market? | 3 |
| Domain path | Is there a realistic domain strategy? | 5 |

Eliminate names that fail on culture fit, trust, or memorability even if the domain looks clean.

### 7. Check domain paths

Preferred order:
1. Direct tool command: `brand-domain-tool`
2. Bundled script: `scripts/check_domains.py`
3. Domain-checker MCP, if configured later
4. Manual verification with `whois`, `dig`, browser checks, and registrar checkout

Check at minimum:
- exact `.com`
- exact `.net`
- exact `.ai`
- exact `.io`

For each domain, capture:
- likely registration status
- DNS resolution
- live website signal
- obvious collision risk

Treat script output as triage, not legal or registrar truth. Final purchase decisions require registrar confirmation and trademark review.

### 8. Make the marketing call on the TLD

Do not treat all TLDs as equivalent.

Default guidance:
- `.com`: strongest default for consumer trust, broad marketing, radio clarity, and long-term brand value
- `.net`: acceptable defensive registration, rarely the lead brand unless the name is already established there
- `.ai`: useful when AI is central to the product story or buyer expectations, weaker for mainstream consumer trust
- `.io`: strongest for developer tools, infra, and startup-native B2B products; weaker for household-facing products

If the product serves homeowners, families, healthcare patients, or other mainstream consumers, `.com` should usually dominate the decision.

### 9. Build the product identity recommendation

Do not stop at a list of names. Recommend a full identity direction:
- the best naming territory
- the best 3 candidate names
- the best lead domain path for each
- the product voice each one implies
- what the homepage tone and brand story would become under that name

The recommendation should read like a brand decision, not a registrar report.

### 10. Screen for brand collisions

Do a lightweight collision pass:
- search the exact name
- search the exact name plus the category
- check whether another company in the same space already owns the narrative
- note obvious trademark or company-name conflicts

This is not legal clearance. It is early risk screening.

### 11. Produce a recommendation, not just options

Finish with:
- identity brief
- naming territories considered
- top 3 names
- domain notes for each
- recommended direction
- rejected directions and why
- next purchase or legal steps

## Quick Reference

### TLD recommendation by product type

| Product type | Preferred TLD | Secondary | Usually weak |
|---|---|---|---|
| Consumer app | `.com` | `.ai` only if core story is AI | `.io`, `.net` |
| Local services | `.com` | `.net` defensively | `.io` |
| B2B SaaS | `.com` | `.io`, `.ai` depending on buyer | `.net` |
| AI-native workflow tool | `.com` or `.ai` | the other one | `.net` |
| Developer tool | `.io` or `.com` | `.ai` if relevant | `.net` |

### Output format

Use a table like this:

| Name | Territory | Brand read | Best domain path | Risks | Verdict |
|---|---|---|---|---|---|
| Example | Proof | credible, precise | `example.com` taken, `example.ai` open | adjacent trademark | hold |

### Identity brief format

Use a section like this before any name list:

| Field | Notes |
|---|---|
| Audience | who this is for |
| Stakes | what feels expensive or urgent |
| Promise | what transformation the product offers |
| Proof | why users should believe it |
| Personality | 3-5 adjectives |
| Cultural lane | what kind of company this feels like |
| Anti-lane | what it must avoid sounding like |
| Verbal texture | crisp, friendly, technical, elegant, etc. |

## Tooling

Run:

```bash
brand-domain-tool truecomps taxspring
```

Or call the canonical script directly:

```bash
python3 ~/.codex/skills/brand-domain-naming/scripts/check_domains.py truecomps taxspring
```

Optional JSON output:

```bash
brand-domain-tool --json truecomps taxspring
```

The tool checks `.com`, `.net`, `.ai`, and `.io` by default and prints either a markdown table or JSON.

## Cross-Agent Install

Keep one canonical copy of this skill in `~/.codex/skills/brand-domain-naming`.

For Claude, expose the same folder through a symlink:

```bash
ln -sfn ~/.codex/skills/brand-domain-naming ~/.claude/skills/brand-domain-naming
```

Keep the executable wrapper in `~/bin/brand-domain-tool` so both Claude and Codex can run the same command in any session.

## Example

For a homeowner-facing property tax appeal app:
- trust matters more than novelty
- savings matters more than AI theater
- proof matters more than abstract lifestyle branding
- culture fit matters more than sounding like a VC-backed dev tool

That usually favors names in the outcome, proof, or fairness territories and pushes the decision toward `.com`.

## Rationalization Table

| Excuse | Reality |
|---|---|
| "The `.ai` is open, so the name works." | An open domain does not fix weak positioning. |
| "We can just add AI to make it modern." | Artificial AI-signaling often reduces trust outside technical audiences. |
| "The name is clear enough if we explain it." | If it needs explanation to feel trustworthy, it is already weak. |
| "The repo already uses this codename, so we should stay close to it." | Internal naming is implementation residue, not a brand strategy. |
| "The `.com` is taken, but `.io` is fine for everyone." | `.io` is not neutral. It changes how the market reads the company. |
| "No live site means the domain is available." | Dormant domains are often still owned and expensive. |
| "Trademark review can wait until after branding." | Early collision screening is cheap and avoids wasted attachment. |

## Red Flags

Stop and re-evaluate if any of these happen:
- using the current repo or product name as a creative anchor without permission
- brainstorming before writing the identity brief
- brainstorming names before reading the product context
- treating domain availability as the primary success metric
- defaulting to `.ai` or `.io` without audience justification
- ignoring pronunciation or spelling friction
- skipping collision screening because the domain script looks clean
- recommending a single winner without alternatives

## Common Mistakes

- Over-indexing on cleverness when the product needs trust
- Letting the codename contaminate the naming space
- Picking names that describe the backend instead of the customer outcome
- Mistaking DNS inactivity for domain availability
- Assuming `.net` is a safe substitute for `.com`
- Treating a strong internal codename as a public brand

## References

Load these only when needed:
- `references/brand-identity-deep-dive.md` for the design-and-culture diagnosis workflow
- `references/tld-positioning.md` for a fuller brand and TLD decision rubric
- `references/domain-checker-mcp.md` for the optional future MCP contract
