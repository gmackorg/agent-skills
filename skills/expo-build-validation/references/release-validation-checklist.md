# Expo Release Validation Checklist

## Core Files

- `package.json`
- `app.json` or `app.config.*`
- `eas.json`
- platform asset files

## Config Surface

- `expo.name`
- `expo.slug`
- `expo.version`
- `expo.platforms`
- `expo.icon`
- splash configuration
- `ios.bundleIdentifier`
- `ios.buildNumber`
- `android.package`
- `android.versionCode`

## EAS Surface

- build profiles exist for the intended target
- simulator/emulator profile exists when Maestro is part of the workflow
- submit profile exists when store upload is in scope

## Commands

```bash
npx expo install --check
npx expo doctor
```

## Release-Significant Checks

- release env vars available to the target profile
- update / runtime version strategy is intentional
- permissions and purpose strings match actual release behavior
- asset paths resolve and are production-ready

## Routing

- app behavior uncertain: `maestro-qa-report` or `maestro-qa`
- iOS review risk: `app-store-review`
- upload mechanics: `expo-build-submit`
