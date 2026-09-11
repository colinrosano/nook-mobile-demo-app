import UIKit
import ConsentSDK
import FakeAnalyticsSDK
import FakeMarketingSDK

/// Owns the Osano ConsentManager for the life of the app and publishes
/// the current consent state for display in the UI.
@Observable
final class OsanoService {
    static let shared = OsanoService()

    @ObservationIgnored private(set) var manager: ConsentManager?
    @ObservationIgnored private var uiBuilder: ConsentUiBuilder?

    // Current-consent readout
    private(set) var isReady = false
    private(set) var jurisdiction = "—"
    private(set) var effectiveVariant = "—"
    private(set) var hasConsented = false
    private(set) var consentedCategories: [String] = []

    /// Forces a specific banner variant ("one"..."seven") instead of the one
    /// the config serves for the detected jurisdiction. Persisted for demos;
    /// takes effect the next time the dialog is presented.
    var variantOverride: String? {
        didSet {
            UserDefaults.standard.set(variantOverride, forKey: Self.variantKey)
            if let manager {
                manager.variant = variantOverride
                refresh()
            }
        }
    }
    private static let variantKey = "osano.variantOverride"

    private init() {
        variantOverride = UserDefaults.standard.string(forKey: Self.variantKey)
    }

    // Launch sequencing: the consent UI is presented only once BOTH the ATT
    // prompt has been answered and the SDK has finished initializing.
    @ObservationIgnored private var managerReady = false
    @ObservationIgnored private var trackingResolved = false
    @ObservationIgnored private var consentUIPresented = false

    /// Call once the scene is active (ATT will not prompt from an inactive
    /// app). Safe to call repeatedly; only the first call does anything.
    func start() {
        guard manager == nil else { return }
        // Route SDK logs into the on-screen console (also mirrored to stdout).
        FakeAnalytics.shared.onLog = { DemoLog.shared.log($0) }
        FakeMarketing.shared.onLog = { DemoLog.shared.log($0) }

        // 1. App Tracking Transparency first. The SDK treats the system-level
        //    tracking decision as authoritative (a denied ATT status rewrites
        //    stored consent to essential + opt-out), so the user must answer
        //    Apple's prompt before they see Osano's dialog. The result is
        //    forwarded to the SDK by TrackingAuthorization.
        requestTrackingAuthorization { [weak self] in
            guard let self else { return }
            self.trackingResolved = true
            self.presentConsentUIWhenReady()
        }

        // 2. Initialize the SDK in parallel (config fetch); the dialog itself
        //    waits for step 1.
        manager = ConsentManager(
            customerId: "osdemosales3inc",
            configId: "cd13350f-953e-4cb8-9440-7e2429f54c61",
            consentingDomain: "www.nookapp.com",
            extUsrData: ""
        ) { [weak self] error in
            if let error {
                print("Osano init failed: \(error)")
                return
            }
            DemoLog.shared.log("🟢 Osano ConsentManager ready")
            DispatchQueue.main.async {
                guard let self, let manager = self.manager else { return }
                self.uiBuilder = ConsentUiBuilder(consentManager: manager)
                if let launchVariant = DemoDriver.variant {
                    self.variantOverride = launchVariant
                    print("Osano: variant forced to \(launchVariant) (-demo.variant)")
                } else if let stored = self.variantOverride {
                    manager.variant = stored
                }
                if DemoDriver.resetConsent {
                    manager.clearConsent()
                    DemoLog.shared.log("Osano: stored consent cleared (-demo.resetConsent)")
                }
                if DemoDriver.acceptAll {
                    manager.consent(objectCategories: [
                        OsanoCategoryObject.factory(category: .essential),
                        OsanoCategoryObject.factory(category: .analytics),
                        OsanoCategoryObject.factory(category: .marketing),
                        OsanoCategoryObject.factory(category: .personalization),
                    ])
                    DemoLog.shared.log("Osano: consent granted to all categories (-demo.acceptAll)")
                }
                self.refresh(announce: true)
                // Consent recording is asynchronous; re-read shortly after
                // launch so the gate reflects the final state.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.refresh() }
                // Demo event: dropped or sent depending on the gate above.
                FakeAnalytics.shared.track(event: "app_opened")
                FakeMarketing.shared.track(event: "app_opened")
                self.managerReady = true
                self.presentConsentUIWhenReady()
            }
        }
    }

    /// Presents the Osano dialog (or the preferences drawer for -demo.openPrefs)
    /// once the ATT prompt has been answered and the SDK is ready, whichever
    /// comes last. Runs exactly once per launch.
    private func presentConsentUIWhenReady() {
        guard managerReady, trackingResolved, !consentUIPresented else { return }
        consentUIPresented = true
        // Re-read state first: the SDK may have rewritten stored consent in
        // response to the ATT status (e.g. denied → essential + opt-out).
        refresh()
        // Small delay lets the system ATT alert finish dismissing.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            if DemoDriver.openPrefs {
                self.showPreferences()
            } else {
                self.presentDialogIfNeeded()
            }
        }
    }

    /// Re-reads consent state from the SDK and applies it to the
    /// third-party SDKs via the ConsentGate. `announce: true` also logs
    /// each SDK's resulting status even if nothing changed.
    func refresh(announce: Bool = false) {
        guard let manager else { return }
        isReady = true
        jurisdiction = manager.jurisdiction
        effectiveVariant = manager.getEffectiveVariant()
        hasConsented = manager.userConsent()
        consentedCategories = (manager.userConsentedCategories() as? [String]) ?? []
        ConsentGate.apply(consentedCategories: consentedCategories, announce: announce)
    }

    func presentDialogIfNeeded() {
        guard let manager, let uiBuilder else { return }
        guard !manager.userConsent() else {
            let cats = ((manager.userConsentedCategories() as? [String]) ?? []).sorted().joined(separator: ", ")
            DemoLog.shared.log("Osano: consent already recorded [\(cats)] — skipping dialog")
            return
        }
        guard let root = Self.rootViewController() else { return }
        uiBuilder.showDialogViewController(
            presenterViewController: root,
            type: .modal
        ) { [weak self] categories in
            DemoLog.shared.log("✅ Osano dialog: consent given")
            DispatchQueue.main.async { self?.applyConsent(categories: categories) }
        } deny: { [weak self] in
            DemoLog.shared.log("⛔️ Osano dialog: consent denied — essential only")
            DispatchQueue.main.async { self?.applyConsent(categories: ["ESSENTIAL"]) }
        }
    }

    /// Asks for App Tracking Transparency permission (no-op once the status
    /// is determined) and calls `completion` when the answer is known.
    /// `TrackingAuthorization` forwards the result to the SDK.
    private func requestTrackingAuthorization(completion: @escaping () -> Void) {
        if DemoDriver.skipATT {
            DemoLog.shared.log("🍎 ATT: prompt skipped (-demo.skipATT)")
            completion()
            return
        }
        TrackingAuthorization.shared.requestIfNeeded(completion: completion)
    }

    /// Opens the Osano preferences drawer (the categories view controller).
    /// The drawer UI loads asynchronously, so retry briefly until it is ready.
    /// Note: ConsentUiBuilder.showDrawerViewController() cannot find the window
    /// in a scene-based SwiftUI app, so we present the drawer ourselves.
    func showPreferences(retries: Int = 10) {
        guard let uiBuilder else {
            print("Osano: UI builder not ready yet")
            return
        }
        guard uiBuilder.isUiReady(), let categoriesVC = uiBuilder.categoriesViewController else {
            if retries > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.showPreferences(retries: retries - 1)
                }
            } else {
                print("Osano: preferences UI never became ready")
            }
            return
        }
        guard let root = Self.rootViewController() else { return }
        categoriesVC.consentedCategoriesCallBack { [weak self] categories in
            DemoLog.shared.log("💾 Osano preferences saved")
            DispatchQueue.main.async { self?.applyConsent(categories: categories) }
        }
        categoriesVC.deny = { [weak self] in
            DemoLog.shared.log("⛔️ Osano preferences: denied — essential only")
            DispatchQueue.main.async { self?.applyConsent(categories: ["ESSENTIAL"]) }
        }
        var presenter = root
        while let presented = presenter.presentedViewController { presenter = presented }
        presenter.present(categoriesVC, animated: true)
        watchDrawerDismiss(categoriesVC)
    }

    /// Clears stored consent; the dialog will show again on next launch.
    func resetConsent() {
        DemoLog.shared.log("🔄 Osano: consent cleared — relaunch the app to see the dialog again")
        manager?.clearConsent()
        refresh(announce: true)
        settleRefresh()
    }

    /// Applies consent categories delivered by an Osano UI callback.
    /// The SDK records consent asynchronously, so the callback payload is the
    /// authoritative immediate state; a settle-poll then reconciles the
    /// readout with what the SDK actually stored.
    private func applyConsent(categories: NSArray) {
        let names = categories.compactMap { $0 as? String }
        consentedCategories = names
        hasConsented = true
        ConsentGate.apply(consentedCategories: names, announce: true)
        settleRefresh()
    }

    /// Re-reads SDK state after async consent recording has had time to land.
    private func settleRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in self?.refresh() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in self?.refresh() }
    }

    /// Watches a presented drawer and re-reads consent once it is dismissed
    /// (covers closing the drawer via the X or a swipe, where no callback fires).
    private func watchDrawerDismiss(_ vc: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self, weak vc] in
            guard let self else { return }
            if let vc, vc.presentingViewController != nil {
                self.watchDrawerDismiss(vc)
            } else {
                self.refresh()
                self.settleRefresh()
            }
        }
    }

    private static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}
