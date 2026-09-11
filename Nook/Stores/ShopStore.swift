import SwiftUI
import Observation
import FakeAnalyticsSDK
import FakeMarketingSDK

@Observable
final class ShopStore {
    var cart: [CartItem] = [] { didSet { persist() } }
    var favorites: Set<String> = [] { didSet { persist() } }
    var orders: [Order] = [] { didSet { persist() } }
    var hasOnboarded: Bool = false { didSet { persist() } }

    var cartCount: Int { cart.reduce(0) { $0 + $1.quantity } }
    var cartSubtotal: Double { cart.reduce(0) { $0 + $1.lineTotal } }

    private static let defaultsKey = "nook.store.v1"

    init() { restore() }

    // MARK: - Cart

    func add(_ product: Product, quantity: Int = 1) {
        FakeAnalytics.shared.track(event: "add_to_cart")
        FakeMarketing.shared.track(event: "add_to_cart")
        if let idx = cart.firstIndex(where: { $0.id == product.id }) {
            cart[idx].quantity += quantity
        } else {
            cart.append(CartItem(id: product.id, quantity: quantity))
        }
    }

    func setQuantity(_ quantity: Int, for productID: String) {
        guard let idx = cart.firstIndex(where: { $0.id == productID }) else { return }
        if quantity <= 0 {
            cart.remove(at: idx)
        } else {
            cart[idx].quantity = quantity
        }
    }

    func remove(productID: String) {
        cart.removeAll { $0.id == productID }
    }

    func placeOrder() -> Order {
        FakeAnalytics.shared.track(event: "purchase")
        FakeMarketing.shared.track(event: "purchase")
        let order = Order(id: UUID().uuidString,
                          placedAt: .now,
                          items: cart,
                          total: cartSubtotal)
        orders.insert(order, at: 0)
        cart = []
        return order
    }

    // MARK: - Favorites

    func toggleFavorite(_ product: Product) {
        if favorites.contains(product.id) {
            favorites.remove(product.id)
        } else {
            favorites.insert(product.id)
        }
    }

    func isFavorite(_ product: Product) -> Bool {
        favorites.contains(product.id)
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var cart: [CartItem]
        var favorites: Set<String>
        var orders: [Order]
        var hasOnboarded: Bool
    }

    private func persist() {
        let snap = Snapshot(cart: cart, favorites: favorites, orders: orders,
                            hasOnboarded: hasOnboarded)
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }

    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: Self.defaultsKey),
              let snap = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        cart = snap.cart
        favorites = snap.favorites
        orders = snap.orders
        hasOnboarded = snap.hasOnboarded
    }
}
