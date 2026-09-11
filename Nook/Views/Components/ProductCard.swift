import SwiftUI

struct ProductCard: View {
    @Environment(ShopStore.self) private var store
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProductArt(product: product)
                .overlay(alignment: .topTrailing) {
                    Button {
                        withAnimation(.bouncy) { store.toggleFavorite(product) }
                    } label: {
                        Image(systemName: store.isFavorite(product) ? "heart.fill" : "heart")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(store.isFavorite(product) ? Theme.clay : .secondary)
                            .padding(8)
                            .background(.thinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(product.maker)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Text(product.priceLabel)
                        .font(.subheadline.weight(.bold))
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text(product.rating, format: .number.precision(.fractionLength(1)))
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 4)
        }
    }
}

struct RatingStars: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: Double(i) <= rating.rounded() ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.85, green: 0.66, blue: 0.30))
            }
        }
    }
}
