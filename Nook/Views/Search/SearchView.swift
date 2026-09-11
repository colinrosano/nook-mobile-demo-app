import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var selectedCategory: ProductCategory? = nil
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var results: [Product] {
        var items = Catalog.products
        if let selectedCategory {
            items = items.filter { $0.category == selectedCategory }
        }
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return items }
        return items.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
                || $0.maker.localizedCaseInsensitiveContains(trimmed)
                || $0.category.rawValue.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterChip(nil, label: "All")
                            ForEach(ProductCategory.allCases) { category in
                                filterChip(category, label: category.rawValue)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    if results.isEmpty {
                        ContentUnavailableView.search(text: query)
                            .padding(.top, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(results) { product in
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
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "Mugs, throws, lamps…")
            .navigationDestination(for: Product.self) { ProductDetailView(product: $0) }
        }
    }

    private func filterChip(_ category: ProductCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.snappy) { selectedCategory = category }
        } label: {
            Text(label)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(isSelected ? Theme.forest : Color(.secondarySystemGroupedBackground)))
                .foregroundStyle(isSelected ? Theme.cream : .primary)
        }
        .buttonStyle(.plain)
    }
}
