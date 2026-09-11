import Foundation
import FakeAnalyticsSDK
import FakeMarketingSDK

/// Single chokepoint that starts or stops third-party SDKs based on the
/// user's Osano consent categories (per Osano's guidance: only initialize
/// an SDK when its category appears in userConsentedCategories()).
///
///   ANALYTICS  → FakeAnalytics
///   MARKETING  → FakeMarketing
///
/// Runs at launch once consent resolves and after every consent change.
/// `announce: true` (used for explicit consent events — dialog decision,
/// preferences save, reset, launch) also logs each SDK's resulting status
/// even when nothing changed, so every consent action produces output.
enum ConsentGate {
    static func apply(consentedCategories: [String], announce: Bool = false) {
        let granted = Set(consentedCategories.map { $0.uppercased() })
        let analyticsChanging = granted.contains("ANALYTICS") != FakeAnalytics.shared.isInitialized
        let marketingChanging = granted.contains("MARKETING") != FakeMarketing.shared.isInitialized

        if announce || analyticsChanging || marketingChanging {
            DemoLog.shared.log("🚦 [ConsentGate] consent applied: [\(granted.sorted().joined(separator: ", "))]")
        }

        setAnalytics(granted: granted.contains("ANALYTICS"))
        setMarketing(granted: granted.contains("MARKETING"))

        if announce {
            DemoLog.shared.log(FakeAnalytics.shared.isInitialized
                ? "📊 [FakeAnalytics] status: ACTIVE — analytics consent granted"
                : "📊 [FakeAnalytics] status: SUPPRESSED — analytics consent not granted")
            DemoLog.shared.log(FakeMarketing.shared.isInitialized
                ? "📣 [FakeMarketing] status: ACTIVE — marketing consent granted"
                : "📣 [FakeMarketing] status: SUPPRESSED — marketing consent not granted")
        }
    }

    private static func setAnalytics(granted: Bool) {
        if granted, !FakeAnalytics.shared.isInitialized {
            FakeAnalytics.shared.initialize(apiKey: "demo-analytics-key")
        } else if !granted, FakeAnalytics.shared.isInitialized {
            FakeAnalytics.shared.shutdown()
        }
    }

    private static func setMarketing(granted: Bool) {
        if granted, !FakeMarketing.shared.isInitialized {
            FakeMarketing.shared.initialize(apiKey: "demo-marketing-key")
        } else if !granted, FakeMarketing.shared.isInitialized {
            FakeMarketing.shared.shutdown()
        }
    }
}
