# Nestling - local iOS prototype

This is a native SwiftUI iOS app for the first milestone of a baby-tracking product. It has no third-party dependencies and stores data only in the device's local app storage.

## Open and run

Open `ios/Nestling.xcodeproj` in an existing copy of Xcode, choose an iPhone simulator or connected device, then press Run. No package installation is required.

This workspace does not have Xcode installed, so the app source is supplied but simulator compilation cannot be run here without a system-level Xcode install. The domain logic is independently checked with the Swift package below.

```sh
swift test
```

## What is included

- A local baby profile
- Quick logging for feeds, sleeps, and diapers
- A daily timeline
- A deterministic next-sleep-window estimate with plain-language reasoning and a safety note
- Export and reset controls for local data

## Intentionally excluded

Accounts, cloud backup or sync, caregiver sharing, push notifications, subscriptions, analytics, medical claims, app-store packaging, and finalized branding.

## Test notes

The predictor is intentionally a small, deterministic rule set in `ios/Nestling/Domain/Predictor.swift`. Its core cases run in the workspace-only Swift package.
