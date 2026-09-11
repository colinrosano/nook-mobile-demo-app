# Nook — iOS Demo Shopping App

A curated home-goods e-commerce app built with SwiftUI. Fully self-contained: no backend, no dependencies, no image assets — product art is generated procedurally from SF Symbols and gradients.

## Features

- **Shop** — hero collection banner, new arrivals rail, category chips, full product grid
- **Product detail** — ratings, details, favorites, quantity stepper, add-to-bag with haptics
- **Search** — live text search plus category filter chips
- **Bag & checkout** — quantity editing, swipe-to-delete, free-shipping threshold, mock checkout with order confirmation
- **Profile** — favorites, order history with detail views
- **Persistence** — cart, favorites, and orders survive relaunch (UserDefaults + Codable)

> Consent is handled by the Osano CMP SDK (initialized in `Nook/Support/OsanoService.swift`; the dialog variant and jurisdiction behavior come from the published Osano config). The You tab shows the live consent state (status, jurisdiction, variant, categories, App Tracking status) plus Cookie Preferences (opens the Osano categories drawer), a Force Variant picker for demoing banner variants, a Request Tracking Permission button, and Reset Consent (clears stored consent so the dialog shows on next launch). The SDK is installed via Swift Package Manager (`ConsentSDK` from https://github.com/osano/cocoapods-specs.git, tracking `main`).
>
> **App Tracking Transparency:** at launch the app first requests ATT permission via `ATTrackingManager`, forwards the result to the SDK, and only then presents the Osano consent dialog. The SDK treats the system-level tracking decision as authoritative (a denied ATT status rewrites stored consent to essential + opt-out), so Apple's prompt comes first. The result is forwarded by posting the `com.osano.OsanoConsentUpdate` notification, per [Osano's ATT guide](https://developers.osano.com/cmp/mobile-sdks/ios/apple-transparency). See `Nook/Support/TrackingAuthorization.swift`.

## Requirements

- Xcode 26+, iOS 18+ (built against the iOS 26.5 simulator)

## Run it

```
open Nook.xcodeproj
```

Pick an iPhone simulator and hit Run. Or from the CLI:

```
xcodebuild -project Nook.xcodeproj -scheme Nook \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## Debug launch arguments

DEBUG-only hooks for driving the app headlessly (screenshots, demos):

| Argument | Effect |
|---|---|
| `-demo.tab search\|cart\|profile` | Opens on a specific tab |
| `-demo.product p1…p12` | Deep-opens a product detail page |
| `-demo.seedCart` | Seeds the bag with sample items |
| `-demo.resetConsent` | Clears stored Osano consent so the notice shows again |
| `-demo.openPrefs` | Opens the Osano cookie-preferences drawer on launch |
| `-demo.acceptAll` | Programmatically grants consent to all categories at launch |
| `-demo.variant one…seven` | Forces an Osano banner variant (persists until changed in the You tab) |
| `-demo.skipATT` | Suppresses the App Tracking Transparency prompt (useful for scripted screenshots) |

Example:

```
xcrun simctl launch booted com.osano.demo.Nook -demo.tab cart -demo.seedCart
```

## Structure

```
Nook/
├── NookApp.swift            # entry point
├── Models/                  # Product catalog, orders
├── Stores/ShopStore.swift   # @Observable app state + persistence + consent
├── Support/                 # OsanoService, ConsentGate, TrackingAuthorization (ATT), DemoLog, Theme, demo driver
└── Views/
    ├── RootView.swift       # tab bar + consent gate
    ├── Shop/                # home, category, product detail
    ├── Search/
    ├── Cart/                # bag + checkout
    ├── Profile/             # profile, orders
    └── Components/          # product cards, procedural product art
```
