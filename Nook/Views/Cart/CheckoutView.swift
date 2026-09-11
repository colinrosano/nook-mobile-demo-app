import SwiftUI

struct CheckoutView: View {
    @Environment(ShopStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var address = ""
    @State private var city = ""
    @State private var placing = false
    @State private var placedOrder: Order? = nil

    private var canPlace: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !address.trimmingCharacters(in: .whitespaces).isEmpty
            && !city.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            if let order = placedOrder {
                confirmation(order)
            } else {
                form
            }
        }
        .presentationDetents([.large])
    }

    private var form: some View {
        Form {
            Section("Shipping Address") {
                TextField("Full name", text: $name)
                    .textContentType(.name)
                TextField("Street address", text: $address)
                    .textContentType(.streetAddressLine1)
                TextField("City, State ZIP", text: $city)
            }

            Section("Payment") {
                Label("Demo checkout — no payment is collected", systemImage: "creditcard")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Order Summary") {
                ForEach(store.cart) { item in
                    if let product = item.product {
                        HStack {
                            Text("\(item.quantity) × \(product.name)")
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "$%.2f", item.lineTotal))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                HStack {
                    Text("Total").font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", store.cartSubtotal)).font(.headline)
                }
            }

            Section {
                Button {
                    placeOrder()
                } label: {
                    if placing {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Place Order")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!canPlace || placing)
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private func placeOrder() {
        placing = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            placedOrder = store.placeOrder()
            placing = false
        }
    }

    private func confirmation(_ order: Order) -> some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.forest)
                .symbolEffect(.bounce, value: placedOrder)
            Text("Order placed!")
                .font(Theme.serif(28))
            Text("Order \(order.number) is on its way to becoming part of your home.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }
}
