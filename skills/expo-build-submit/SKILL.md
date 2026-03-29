---
name: expo-build-submit
description: Use when an Expo app is already validated and you need to build or upload it with EAS Build and EAS Submit. Handles profile selection, credential assumptions, TestFlight or Play upload flow, and submission sequencing after technical readiness and QA are already complete.
---

# Expo Build Submit

## Overview

Use this skill only after the app is already ready to ship.

It is for build and upload mechanics, not broad validation, not Maestro QA, and not App Store policy review. If readiness is still unclear, use `expo-build-validation` or `react-native-expo-release-readiness` first.

## Default Workflow

### 1. Confirm submission intent

Establish:

- platform: iOS, Android, or both
- target: TestFlight, App Store Connect handoff, Play internal, beta, or production
- build profile to use
- whether credentials and store access are already configured

For iOS, remember:

- EAS Submit uploads to App Store Connect / TestFlight
- that is not the same as App Review approval

### 2. Verify the app is ready for upload

Before running `eas build` or `eas submit`, make sure:

- technical readiness was covered by `expo-build-validation`
- product behavior was covered by `maestro-qa-report` or `maestro-qa`
- iOS review risk was covered by `app-store-review` when relevant

Do not use this skill to paper over unresolved readiness gaps.

### 3. Run the smallest necessary build and submit sequence

Typical commands:

```bash
eas build --platform ios --profile production
eas build --platform android --profile production
eas submit --platform ios --profile production
eas submit --platform android --profile production
```

Prefer explicit profiles and explicit platform-by-platform sequencing over a giant all-at-once script.

### 4. Track upload state and next handoff

After submission, record:

- build profile used
- build IDs or links
- destination track or TestFlight target
- what is still pending: review notes, external tester rollout, manual store actions, or App Review

Use [references/submission-sequence.md](references/submission-sequence.md) to keep the flow clear.

## Quick Reference

| Need | Action |
| --- | --- |
| build the release binary | `eas build --platform <platform> --profile <profile>` |
| upload to App Store Connect / TestFlight | `eas submit --platform ios --profile <profile>` |
| upload to Play | `eas submit --platform android --profile <profile>` |
| inspect build state | `eas build:list` |

## Common Mistakes

- treating `eas submit` as a substitute for readiness validation
- uploading to TestFlight before QA or App Store review prep is done
- mixing credential setup, QA, and upload into one opaque step
- running both platforms at once when one target is still blocked

## Example

If the user asks:

`submit this validated expo app to testflight`

do this:

1. confirm the right iOS profile and credentials exist
2. build with the explicit production or preview profile
3. submit with the matching profile
4. report the resulting build/upload state and any remaining review handoff
