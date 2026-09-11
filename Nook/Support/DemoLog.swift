import Foundation
import os

/// Collects demo log lines so they can be shown inside the app —
/// visible regardless of whether the app was launched from Xcode.
/// Lines are also mirrored to stdout (Xcode console when attached)
/// and the unified system log (Console.app / `log stream`).
@Observable
final class DemoLog {
    static let shared = DemoLog()

    struct Entry: Identifiable {
        let id = UUID()
        let date = Date()
        let text: String
    }

    private(set) var entries: [Entry] = []

    @ObservationIgnored
    private let logger = Logger(subsystem: "com.osano.demo.Nook", category: "ConsentDemo")

    private init() {}

    func log(_ text: String) {
        print(text)
        logger.notice("\(text, privacy: .public)")
        DispatchQueue.main.async {
            self.entries.append(Entry(text: text))
            if self.entries.count > 200 {
                self.entries.removeFirst(self.entries.count - 200)
            }
        }
    }

    func clear() {
        entries.removeAll()
    }
}
