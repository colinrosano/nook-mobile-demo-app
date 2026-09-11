import SwiftUI

struct ProductDetailView: View {
    @Environment(ShopStore.self) private var store
    let product: Product
    @State private var quantity = 1
    @State private var justAdded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProductArt(product: product, cornerRadius: 28)
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name)
                                .font(Theme.serif(26))
                            Text("by \(product.maker)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            withAnimation(.bouncy) { store.toggleFavorite(product) }
                        } label: {
                            Image(systemName: store.isFavorite(product) ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundStyle(store.isFavorite(product) ? Theme.clay : .secondary)
                        }
                    }

                    HStack(spacing: 10) {
                        RatingStars(rating: product.rating)
                        Text("\(product.rating, format: .number.precision(.fractionLength(1))) · \(product.reviewCount) reviews")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(product.blurb)
                        .font(.body)
                        .foregroundStyle(.primary.opacity(0.85))
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Details")
                        .font(Theme.serif(19))
                    ForEach(product.details, id: \.self) { detail in
                        Label(detail, systemImage: "checkmark")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .cardBackground()
                .padding(.horizontal, 20)

                Spacer(minLength: 90)
            }
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { buyBar }
        .sensoryFeedback(.success, trigger: justAdded)
    }

    private var buyBar: some View {
        HStack(spacing: 14) {
            HStack(spacing: 0) {
                stepperButton("minus") { if quantity > 1 { quantity -= 1 } }
                Text("\(quantity)")
                    .font(.headline)
                    .frame(minWidth: 32)
                stepperButton("plus") { if quantity < 9 { quantity += 1 } }
            }
            .background(Capsule().fill(Color(.secondarySystemGroupedBackground)))

            Button {
                store.add(product, quantity: quantity)
                justAdded.toggle()
            } label: {
                HStack {
                    Image(systemName: "bag.badge.plus")
                    Text("Add · \(String(format: "$%.0f", product.price * Double(quantity)))")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func stepperButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .frame(width: 44, height: 48)
        }
        .buttonStyle(.plain)
    }
}
