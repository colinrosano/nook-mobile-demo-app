# Nook — Setup Guide

Nook is a small SwiftUI e-commerce demo app that hosts the **Osano CMP Consent SDK**. This guide gets you from the zip to a running simulator build.

## Requirements

- A Mac with **Xcode 16 or newer** (the project was built with Xcode 26.6). Free from the Mac App Store.
- iOS **18.0+** simulator runtime (installed with Xcode by default).
- Internet access on first open — Xcode downloads the Osano SDK automatically.

No CocoaPods, no `pod install`, no other tooling. The Osano SDK is a Swift Package dependency that Xcode resolves on its own.

## Steps

1. Unzip the project folder.
2. Open **`Nook.xcodeproj`** in Xcode (double-click it, or File → Open).
3. Wait ~30 seconds for **package resolution** — the status bar shows Xcode fetching `cocoapods-specs` (that's the Osano SDK; despite the repo name it is consumed via Swift Package Manager). It downloads a binary framework from `libraries.osano.com`.
4. At the top of the window, make sure the **Nook** scheme is selected and pick any **iPhone simulator** (e.g. iPhone 17 Pro).
5. Press **⌘R** (Run).

That's it. No signing setup is needed for the simulator. To run on a physical iPhone you'd additionally select your own team under *Signing & Capabilities*.

## What you should see

- The app launches into the Nook shop.
- The **Osano consent dialog** appears over it on first launch. Which variant you see depends on your geo-detected jurisdiction (US regions typically get the notice-only banner; opt-in regions get the full Accept/Reject dialog).
- The **You** tab has a privacy toolkit:
  - **Current Consent** — live status, jurisdiction, banner variant, and consented categories straight from the SDK.
  - **Force Variant** — override the banner variant (`One`–`Seven`) to demo different dialog styles regardless of your location. Takes effect the next time the dialog shows.
  - **Cookie Preferences** — opens the Osano preferences drawer at any time.
  - **Reset Consent** — clears stored consent; quit and relaunch the app to get the dialog again.

A typical demo loop: **You tab → pick a Force Variant → Reset Consent → relaunch the app.**

## Consent-based SDK suppression demo

The repo contains two **fake third-party SDKs** as local Swift packages (`Packages/FakeAnalyticsSDK` 📊 and `Packages/FakeMarketingSDK` 📣). `Nook/Support/ConsentGate.swift` initializes or shuts them down from the Osano consent state — the `analytics` category gates FakeAnalytics, `marketing` gates FakeMarketing — at launch and on every consent change.

Watch the **SDK Console** section at the bottom of the You tab (newest first): emoji-prefixed logs show each SDK initializing (`📊 Initialized — tracking active`), tracking events with real HTTP requests when consent is granted, dropping events with **no network request** when it isn't (`🚫 track("add_to_cart") dropped`), shutting down live when consent is revoked, and an explicit ACTIVE/SUPPRESSED status line for both SDKs after every consent decision. Events fire on app open, add-to-cart, and checkout.

The same lines go to the Xcode console — but note that Xcode only shows them when the app was **launched via Xcode's Run**. If you relaunch the app by tapping its icon in the simulator, use the in-app SDK Console (or `xcrun simctl spawn booted log stream --predicate 'subsystem == "com.osano.demo.Nook"' --style compact` in a terminal).

## App Tracking Transparency (ATT)

The app also integrates Apple's **App Tracking Transparency** framework following [Osano's ATT guide](https://developers.osano.com/cmp/mobile-sdks/ios/apple-transparency). The Osano SDK does not request tracking authorization itself, so the app does it in `Nook/Support/TrackingAuthorization.swift`:

1. As soon as the app is active, it calls `ATTrackingManager.requestTrackingAuthorization` — **before** the Osano dialog. The SDK treats the system-level tracking decision as authoritative: a denied ATT status rewrites stored consent to `ESSENTIAL` + `OPT_OUT`, so asking Apple's question first avoids a user tapping *Accept* only to be opted out seconds later.
2. The user's choice is posted to the SDK as the `com.osano.OsanoConsentUpdate` notification, so Osano learns about it immediately rather than on the next launch. The Osano dialog is presented once both the ATT answer and SDK initialization are done.
3. The **You** tab shows the live ATT status under *Current Consent* and offers **Request Tracking Permission** (while undetermined) or **Change Tracking Permission in Settings** (afterwards). Every step is logged to the SDK Console with a 🍎 prefix.

The usage string shown in the system prompt is `NSUserTrackingUsageDescription` in the target's Info settings. iOS only ever shows the ATT prompt **once per install**: to see it again, delete the app from the simulator and reinstall (`xcrun simctl uninstall booted com.osano.demo.Nook`). If the prompt never appears, check *Settings → Privacy & Security → Tracking → Allow Apps to Request to Track* on the simulator. Pass `-demo.skipATT` to suppress the prompt during scripted runs.

## Osano configuration

The SDK is initialized in `Nook/Support/OsanoService.swift` with a demo `customerId` / `configId`. To point it at your own Osano account, replace those two values (and the `consentingDomain`) with the ones from your published Cookie Consent configuration.

## Optional: launch arguments (for scripted demos)

Set these under *Product → Scheme → Edit Scheme → Run → Arguments*, or via `xcrun simctl launch`:

| Argument | Effect |
|---|---|
| `-demo.resetConsent` | Clears stored consent at launch, so the dialog always shows |
| `-demo.variant two` | Forces a banner variant (`one`…`seven`); persists until changed in the You tab |
| `-demo.openPrefs` | Opens the cookie-preferences drawer at launch |
| `-demo.acceptAll` | Programmatically grants consent to all categories at launch |
| `-demo.skipATT` | Suppresses the App Tracking Transparency prompt |
| `-demo.tab profile` | Opens on a specific tab (`search` / `cart` / `profile`) |
| `-demo.seedCart` | Seeds the bag with sample items |

## Troubleshooting

- **"Could not resolve package dependencies"** — File → Packages → *Reset Package Caches*, then wait for re-resolution. Your network must allow `github.com` and `libraries.osano.com`.
- **Why does the package track a branch instead of a version?** Osano's repo tags stop at 3.6.10 while the latest SDK is 3.6.14, so the dependency intentionally tracks `main`. This is expected — don't "fix" it back to a version rule.
- **Consent dialog doesn't appear** — you've already consented on that simulator. Use **You → Reset Consent** and relaunch, or launch with `-demo.resetConsent`.
- **Dialog has no Accept/Reject buttons** — that's the notice-only variant your jurisdiction gets. Use **Force Variant** to see the others.
