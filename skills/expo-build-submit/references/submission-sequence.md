# EAS Submission Sequence

## Preconditions

- `expo-build-validation` complete
- product QA complete
- iOS review prep complete when applicable

## Core Commands

```bash
eas build --platform ios --profile production
eas build --platform android --profile production
eas submit --platform ios --profile production
eas submit --platform android --profile production
```

## iOS Notes

- upload goes to App Store Connect / TestFlight
- review approval is a later step
- review notes, demo accounts, and submission metadata may still be pending outside EAS

## Android Notes

- choose the correct Play track deliberately
- keep internal, beta, and production uploads distinct in reporting

## Report Back

- platform
- build profile
- build ID or link
- upload target
- remaining manual actions
