import Foundation

/// Debug-only launch-argument hooks so the app can be driven headlessly
/// from `simctl launch` (e.g. screenshots of specific screens in CI).
enum DemoDriver {
    #if DEBUG
    static var initialTab: String? {
        UserDefaults.standard.string(forKey: "demo.tab")
    }
    static var openProductID: String? {
        UserDefaults.standard.string(forKey: "demo.product")
    }
    static var resetConsent: Bool {
        ProcessInfo.processInfo.arguments.contains("-demo.resetConsent")
    }

    static var openPrefs: Bool {
        ProcessInfo.processInfo.arguments.contains("-demo.openPrefs")
    }

    static var seedCart: Bool {
        ProcessInfo.processInfo.arguments.contains("-demo.seedCart")
    }
    static var variant: String? {
        UserDefaults.standard.string(forKey: "demo.variant")
    }
    static var acceptAll: Bool {
        ProcessInfo.processInfo.arguments.contains("-demo.acceptAll")
    }
    static var skipATT: Bool {
        ProcessInfo.processInfo.arguments.contains("-demo.skipATT")
    }
    #else
    static let initialTab: String? = nil
    static let openProductID: String? = nil
    static let seedCart = false
    static let resetConsent = false
    static let openPrefs = false
    static let variant: String? = nil
    static let acceptAll = false
    static let skipATT = false
    #endif
}
