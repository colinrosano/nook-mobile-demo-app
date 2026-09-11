import SwiftUI

enum Theme {
    // Warm, earthy home-goods palette
    static let forest = Color(red: 0.12, green: 0.26, blue: 0.20)
    static let sage = Color(red: 0.55, green: 0.64, blue: 0.52)
    static let cream = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let clay = Color(red: 0.80, green: 0.48, blue: 0.35)
    static let sand = Color(red: 0.91, green: 0.86, blue: 0.76)
    static let ink = Color(red: 0.14, green: 0.13, blue: 0.11)

    static func serif(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}

extension View {
    func cardBackground() -> some View {
        background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}
