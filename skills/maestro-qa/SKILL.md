---
name: maestro-qa
description: Use when a React Native or Expo app needs local mobile QA with Maestro plus targeted fixes. Starts with a report-only Maestro pass, isolates one verified failure at a time, maps it back to app or flow code, applies the smallest fix, and reruns the narrowest failing flow before broadening back out.
---

# Maestro QA

## Overview

Use Maestro to verify mobile behavior, fix verified issues, and rerun the smallest useful surface.

This skill extends [maestro-qa-report](../maestro-qa-report/SKILL.md). Start with the report-only pass to prove failures and collect artifacts. Then move through a strict fix loop: one verified issue, one scoped change, one targeted rerun.

## Default Workflow

### 1. Start with a report-only run

Before changing code, run the report-only workflow:

```bash
skills/maestro-qa/scripts/run-maestro-qa.sh \
  --repo /path/to/app \
  --flow-path .maestro \
  --output-dir build/maestro-results \
  --report-format html-detailed \
  --report-file build/maestro-report.html
```

This delegates to the report helper and preserves the same artifact layout.

### 2. Choose one verified failure

Pick one issue using this order:

1. blocker on a critical flow
2. major issue with a release-significant path
3. minor issue that is isolated and easy to confirm

Do not batch unrelated fixes. If multiple flows fail, choose one and ignore the rest until the first fix is verified.

### 3. Map the failure to the right owner

Classify the failure before editing:

- app bug
- broken or stale Maestro flow
- environment or seed-data problem
- backend dependency or flaky service

Only fix what is actually broken. Do not patch app code to compensate for a bad flow. Do not patch a flow to hide a real product bug.

### 4. Apply the smallest fix

Prefer:

- stable selectors or accessibility labels over text-only selectors
- the smallest code change that restores the intended user path
- targeted test data or environment fixes when the app code is not at fault

Keep notes on:

- the failing flow and step
- the file you changed
- why the change matches the verified failure

### 5. Rerun the narrowest surface

After each fix:

1. rerun the single failing flow or tagged subset
2. if that passes, rerun the local smoke set
3. only then broaden back to the larger suite if needed

Do not rerun the entire suite after every edit unless the scope is already tiny.

### 6. End with a QA summary

Report:

- issues fixed
- issues still failing
- flows rerun
- artifact and report paths
- remaining risk before release or handoff

## Fix Loop Rules

| Rule | Why |
| --- | --- |
| prove the failure first | avoids speculative fixes |
| fix one issue at a time | keeps causality clear |
| rerun the smallest surface first | reduces feedback time |
| preserve report artifacts | keeps evidence for later review |
| separate app bugs from flow bugs | prevents false confidence |

## Helper Usage

Use the bundled helper to keep the run shape consistent:

```bash
skills/maestro-qa/scripts/run-maestro-qa.sh \
  --repo /path/to/app \
  --flow-path .maestro/login.yaml \
  --include-tags smoke
```

For a non-executing preview:

```bash
skills/maestro-qa/scripts/run-maestro-qa.sh \
  --repo /path/to/app \
  --flow-path .maestro \
  --dry-run
```

## Common Mistakes

- editing code before proving the Maestro failure
- fixing multiple failures in one pass
- widening the rerun scope too early
- changing flows to hide a real product regression
- stopping after one flow passes without checking the adjacent smoke surface

## Example

If the user asks:

`run maestro qa, fix the broken onboarding flow, and verify it`

do this:

1. run the report-only pass and capture artifacts
2. isolate the onboarding failure to one step and one likely owner
3. make the smallest fix
4. rerun the onboarding flow
5. rerun the nearby smoke flows
6. report what was fixed, what still fails, and where the artifacts live
