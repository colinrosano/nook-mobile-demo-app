import SwiftUI

struct RootView: View {
    @Environment(ShopStore.self) private var store
    @State private var selection: Tab = .shop
    @State private var pathProduct: Product? = nil

    enum Tab: Hashable { case shop, search, cart, profile }

    var body: some View {
        TabView(selection: $selection) {
            SwiftUI.Tab("Shop", systemImage: "storefront.fill", value: Tab.shop) {
                HomeView()
            }
            SwiftUI.Tab("Search", systemImage: "magnifyingglass", value: Tab.search) {
                SearchView()
            }
            SwiftUI.Tab("Cart", systemImage: "bag.fill", value: Tab.cart) {
                CartView()
            }
            .badge(store.cartCount)
            SwiftUI.Tab("You", systemImage: "person.crop.circle.fill", value: Tab.profile) {
                ProfileView()
            }
        }
        .onAppear(perform: applyDemoDriver)
    }

    private func applyDemoDriver() {
        switch DemoDriver.initialTab {
        case "search": selection = .search
        case "cart": selection = .cart
        case "profile": selection = .profile
        default: break
        }
        if DemoDriver.seedCart, store.cart.isEmpty {
            store.add(Catalog.products[0], quantity: 2)
            store.add(Catalog.products[6])
        }
    }
}
