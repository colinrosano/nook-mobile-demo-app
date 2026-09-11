import SwiftUI

struct HomeView: View {
    @Environment(ShopStore.self) private var store
    @State private var path: [Product] = []
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var newArrivals: [Product] { Catalog.products.filter(\.isNew) }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    hero

                    section("New Arrivals") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(newArrivals) { product in
                                    NavigationLink(value: product) {
                                        ProductCard(product: product)
                                            .frame(width: 168)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    section("Browse by Room") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(ProductCategory.allCases) { category in
                                    NavigationLink(value: category) {
                                        CategoryChip(category: category)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    section("The Collection") {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(Catalog.products) { product in
                                NavigationLink(value: product) {
                                    ProductCard(product: product)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Nook")
            .navigationDestination(for: Product.self) { ProductDetailView(product: $0) }
            .navigationDestination(for: ProductCategory.self) { CategoryView(category: $0) }
            .onAppear {
                if let id = DemoDriver.openProductID, let product = Catalog.product(id: id), path.isEmpty {
                    path = [product]
                }
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Theme.forest, Theme.forest.opacity(0.75)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "sofa.fill")
                .resizable().scaledToFit()
                .frame(width: 150)
                .foregroundStyle(.white.opacity(0.08))
                .offset(x: 190, y: -10)
            VStack(alignment: .leading, spacing: 6) {
                Text("The Autumn Edit")
                    .font(Theme.serif(28))
                Text("Warm layers and low light for shorter days.")
                    .font(.subheadline)
                    .opacity(0.85)
            }
            .foregroundStyle(Theme.cream)
            .padding(22)
        }
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 20)
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.serif(22))
                .padding(.horizontal, 20)
            content()
        }
    }
}

struct CategoryChip: View {
    let category: ProductCategory

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category.symbol)
                .font(.subheadline)
                .foregroundStyle(category.tint)
            Text(category.rawValue)
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Capsule().fill(Color(.secondarySystemGroupedBackground)))
        .overlay(Capsule().strokeBorder(category.tint.opacity(0.25)))
    }
}
