import SwiftUI

/// Procedural product "photo": layered gradient + symbol, tinted per category.
struct ProductArt: View {
    let product: Product
    var cornerRadius: CGFloat = 18
    var showsBadge: Bool = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            product.category.tint.opacity(0.28),
                            product.category.tint.opacity(0.12),
                            Theme.sand.opacity(0.35),
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(product.category.tint.opacity(0.18))
                .scaleEffect(1.1)
                .offset(x: 24, y: 26)
                .blur(radius: 8)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            Image(systemName: product.symbol)
                .resizable()
                .scaledToFit()
                .padding(26)
                .foregroundStyle(product.category.tint.gradient)
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(alignment: .topLeading) {
            if product.isNew && showsBadge {
                Text("NEW")
                    .font(.caption2.weight(.heavy))
                    .tracking(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Theme.forest))
                    .foregroundStyle(.white)
                    .padding(10)
            }
        }
    }
}
