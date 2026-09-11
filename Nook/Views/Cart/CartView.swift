import SwiftUI

struct CartView: View {
    @Environment(ShopStore.self) private var store
    @State private var showCheckout = false

    private let shippingThreshold = 100.0

    var body: some View {
        NavigationStack {
            Group {
                if store.cart.isEmpty {
                    ContentUnavailableView(
                        "Your bag is empty",
                        systemImage: "bag",
                        description: Text("Things you add will gather here, cozily.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(store.cart) { item in
                                if let product = item.product {
                                    CartRow(item: item, product: product)
                                }
                            }
                            .onDelete { offsets in
                                for offset in offsets {
                                    store.remove(productID: store.cart[offset].id)
                                }
                            }
                        }

                        Section {
                            summaryRow("Subtotal", value: store.cartSubtotal)
                            summaryRow("Shipping", value: shippingCost)
                            summaryRow("Total", value: store.cartSubtotal + shippingCost, bold: true)
                            if store.cartSubtotal < shippingThreshold {
                                Label(String(format: "Add $%.0f more for free shipping", shippingThreshold - store.cartSubtotal),
                                      systemImage: "shippingbox")
                                    .font(.caption)
                                    .foregroundStyle(Theme.clay)
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        Button {
                            showCheckout = true
                        } label: {
                            Text("Check Out · \(String(format: "$%.2f", store.cartSubtotal + shippingCost))")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.bar)
                    }
                }
            }
            .navigationTitle("Bag")
            .sheet(isPresented: $showCheckout) {
                CheckoutView()
            }
        }
    }

    private var shippingCost: Double {
        store.cartSubtotal >= shippingThreshold || store.cart.isEmpty ? 0 : 9
    }

    private func summaryRow(_ label: String, value: Double, bold: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value == 0 && label == "Shipping" ? "Free" : String(format: "$%.2f", value))
        }
        .font(bold ? .headline : .subheadline)
        .foregroundStyle(bold ? .primary : .secondary)
    }
}

struct CartRow: View {
    @Environment(ShopStore.self) private var store
    let item: CartItem
    let product: Product

    var body: some View {
        HStack(spacing: 14) {
            ProductArt(product: product, cornerRadius: 12, showsBadge: false)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(product.maker)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "$%.2f", item.lineTotal))
                    .font(.subheadline.weight(.bold))
            }

            Spacer()

            HStack(spacing: 0) {
                quantityButton("minus") { store.setQuantity(item.quantity - 1, for: item.id) }
                Text("\(item.quantity)")
                    .font(.subheadline.weight(.semibold))
                    .frame(minWidth: 24)
                quantityButton("plus") { store.setQuantity(item.quantity + 1, for: item.id) }
            }
            .background(Capsule().fill(Color(.tertiarySystemGroupedBackground)))
        }
        .padding(.vertical, 2)
    }

    private func quantityButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
    }
}
