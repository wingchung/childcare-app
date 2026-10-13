# Decision memo - first local milestone

## Product goal

Help a sleep-deprived parent of a baby aged 0-24 months capture the last few care events quickly and see an understandable, non-medical suggestion for the next rest window.

## Scope revision

The original brief mixes an initial beta with later-stage infrastructure: iOS and Android release readiness, partner sync, authentication, subscriptions, notifications, analytics, legal review, and store publishing. Those should not block validation of the core daily use case.

### Build now

- One local baby profile
- Timestamped feed, sleep, and diaper entries
- A same-day timeline
- A deterministic, age-banded next-rest estimate after a sleep entry
- Plain-language rationale, safety language, export, and reset

### Explicitly defer

- Production iPhone/Android packaging
- Design system, branding, widget/live activity work
- Reminders, background timers, accessibility polish beyond semantic HTML
- Advanced sleep-model calibration and real-world efficacy claims

### Not appropriate for this local prototype

- Sign-in, partner sharing, cloud backup, conflict resolution
- Subscriptions, billing, analytics, advertising
- External services, account setup, legal/store submissions

## Technical approach

This first milestone is a native SwiftUI iOS project, using only Apple frameworks and on-device `UserDefaults` storage. There are no third-party dependencies, accounts, or external services.

Why: iOS is now an explicit product outcome. SwiftUI is the smallest local-first path to an installable iPhone app, while retaining a simple, testable domain layer. Android is deliberately deferred rather than simulated. This workspace does not include Xcode or a simulator, so source-level validation is possible here but iOS compilation must occur in an existing Xcode environment.

## First end-to-end flow and definition of done

1. Parent creates a baby profile.
2. Parent records a sleep with a start time and duration.
3. The event appears in today’s timeline.
4. The app presents one next-rest time, a concise explanation, and a medical-safety disclaimer.
5. Reloading the browser preserves data locally; export produces a JSON copy; reset erases it.

Done means the flow runs on an iPhone simulator or device, stores no network data, remains understandable without onboarding, and handles an empty timeline without errors.

## Risks and open decisions

| Priority | Item | Status |
| --- | --- | --- |
| Blocking for production | Jurisdiction-specific privacy, health and store requirements | Deferred; requires current legal and platform review |
| Blocking for production | Auth and shared-caregiver conflict rules | Deferred; needs a product decision |
| High | Sleep algorithm could be interpreted as medical advice | Mitigated in prototype through deterministic rules and visible disclaimer |
| High | Two-week full beta scope is too broad | Mitigated by narrowing to one local vertical slice |
| Medium | Browser local storage is not a durable backup | Disclosed; export included |

## Implementation plan

1. Define a minimal local data model for profile and care events.
2. Build baby-profile entry and persist it locally.
3. Add quick log forms and a chronological timeline.
4. Implement deterministic, age-banded rest-window logic and its edge cases.
5. Add visible safety language, data export, and reset.
6. Manually exercise the first flow at a phone viewport.
