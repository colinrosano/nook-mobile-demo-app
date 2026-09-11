import SwiftUI

struct CategoryView: View {
    let category: ProductCategory
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var products: [Product] {
        Catalog.products.filter { $0.category == category }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(products) { product in
                    NavigationLink(value: product) {
                        ProductCard(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.large)
    }
}
