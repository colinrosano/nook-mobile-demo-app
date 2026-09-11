import UIKit
import AppTrackingTransparency

/// Owns the App Tracking Transparency (ATT) flow and bridges the result to
/// the Osano SDK.
///
/// Per Osano's guidance, the SDK does not request tracking authorization on
/// the app's behalf. The app asks the user with `ATTrackingManager`, then
/// posts the user's decision to Osano via the `com.osano.OsanoConsentUpdate`
/// notification so the SDK learns about it immediately instead of on the
/// next launch.
///
/// Docs: https://developers.osano.com/cmp/mobile-sdks/ios/apple-transparency
@Observable
final class TrackingAuthorization {
    static let shared = TrackingAuthorization()

    /// Notification name the Osano SDK observes for ATT status changes.
    static let osanoConsentUpdate = Notification.Name("com.osano.OsanoConsentUpdate")

    private(set) var status: ATTrackingManager.AuthorizationStatus = .notDetermined
    @ObservationIgnored private var requestInFlight = false

    private init() {
        refreshStatus()
    }

    /// The system prompt can only ever be shown once per install, and only
    /// while the status is still undetermined.
    var canRequest: Bool { status == .notDetermined }

    var statusLabel: String {
        switch status {
        case .notDetermined: "Not determined"
        case .restricted: "Restricted"
        case .denied: "Denied"
        case .authorized: "Authorized"
        @unknown default: "Unknown"
        }
    }

    /// Re-reads the current status (e.g. after the user changed it in Settings).
    func refreshStatus() {
        status = ATTrackingManager.trackingAuthorizationStatus
    }

    /// Shows the ATT prompt if the user has not decided yet, then notifies
    /// the Osano SDK of the result. Safe to call repeatedly; it is a no-op
    /// once the status is determined or while a request is already showing.
    func requestIfNeeded(completion: (() -> Void)? = nil) {
        refreshStatus()
        guard canRequest, !requestInFlight else {
            completion?()
            return
        }
        requestInFlight = true
        DemoLog.shared.log("🍎 ATT: requesting tracking authorization")
        request(attempt: 1, completion: completion)
    }

    private func request(attempt: Int, completion: (() -> Void)?) {
        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self else { return }
                // iOS answers `.notDetermined` WITHOUT showing the prompt when
                // the app is not yet fully active (common right at launch).
                // Back off briefly and try again instead of giving up.
                if status == .notDetermined, attempt < 6 {
                    DemoLog.shared.log("🍎 ATT: prompt not shown yet (app not active) — retrying")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.request(attempt: attempt + 1, completion: completion)
                    }
                    return
                }
                // Osano integration: tell the SDK about the decision right away.
                NotificationCenter.default.post(
                    name: Self.osanoConsentUpdate,
                    object: status
                )
                self.requestInFlight = false
                self.status = status
                DemoLog.shared.log("🍎 ATT: user chose \(self.statusLabel) — posted com.osano.OsanoConsentUpdate to Osano SDK")
                completion?()
            }
        }
    }

    /// Deep-links to the app's page in Settings, where the user can change
    /// the tracking permission after the one-time prompt has been used.
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
