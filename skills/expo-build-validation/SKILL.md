---
name: expo-build-validation
description: Use when validating an Expo app before internal release, TestFlight, Play testing, or store submission. Checks project config, EAS profiles, identifiers, assets, environment handling, and build-significant drift so the app is technically ready before QA handoff or submission.
---

# Expo Build Validation

## Overview

Validate the build surface before you spend time on upload or review work.

This skill is for technical readiness, not Maestro QA and not store-policy review. Use it to find configuration drift, missing identifiers, bad asset setup, broken EAS profiles, or versioning mistakes before builds or submissions fail later.

## Default Workflow

### 1. Confirm the project shape

Check for:

- `app.json` or `app.config.*`
- `package.json`
- `eas.json`
- required asset files

Identify:

- Expo managed vs prebuild/native directories present
- target platforms
- release target: internal, preview, or production

### 2. Validate core Expo config

Review:

- app name, slug, version
- `ios.bundleIdentifier`
- `android.package`
- build-number / version-code strategy
- icons, splash, and adaptive icon paths
- permissions and platform-specific overrides

Use [references/release-validation-checklist.md](references/release-validation-checklist.md) as the canonical checklist.

### 3. Validate dependency and SDK health

Run the normal Expo health checks:

```bash
npx expo install --check
npx expo doctor
```

If the app is release-bound, flag dependency warnings that are likely to affect production builds instead of ignoring them as development noise.

### 4. Validate build-significant environment and EAS setup

Check:

- `eas.json` exists and has the expected profiles
- simulator/emulator test profiles if the team uses Maestro
- environment variables needed for release builds
- runtime/update policy if `expo-updates` is enabled

Do not assume a successful local dev run means the release profile is valid.

### 5. Report technical readiness only

Classify findings as:

- blocker
- major
- minor

Then route to the right next skill:

- product behavior issues: `maestro-qa-report` or `maestro-qa`
- iOS review risk: `app-store-review`
- upload execution: `expo-build-submit`

## Quick Reference

| Need | Action |
| --- | --- |
| check config surface | inspect Expo config, assets, and `eas.json` |
| check dependency health | run `npx expo install --check` and `npx expo doctor` |
| check release profiles | review build and submit profiles in `eas.json` |
| decide next step | route into QA, review, or submit skill |

## Common Mistakes

- treating build success as proof of product readiness
- validating only local dev config and ignoring release profiles
- skipping version/build-number checks until submission time
- mixing App Store policy review into technical validation

## Example

If the user asks:

`validate this expo app before we ship a testflight build`

do this:

1. inspect Expo config, assets, and `eas.json`
2. run Expo health checks
3. verify bundle IDs, package names, and versioning
4. report blockers and majors
5. route into Maestro QA or submission only after technical readiness is clear
