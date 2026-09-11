import SwiftUI

struct ProfileView: View {
    @Environment(ShopStore.self) private var store
    @State private var consentCleared = false
    @AppStorage("sdkConsoleExpanded") private var consoleExpanded = true
    @Environment(\.scenePhase) private var scenePhase
    private var osano: OsanoService { OsanoService.shared }
    private var att: TrackingAuthorization { TrackingAuthorization.shared }

    private var categoriesLabel: String {
        guard osano.isReady, !osano.consentedCategories.isEmpty else { return "None" }
        return osano.consentedCategories
            .map { $0.replacingOccurrences(of: "_", with: " ").capitalized }
            .joined(separator: ", ")
    }

    private var variantBinding: Binding<String> {
        Binding(
            get: { OsanoService.shared.variantOverride ?? "auto" },
            set: { OsanoService.shared.variantOverride = $0 == "auto" ? nil : $0 }
        )
    }

    private var favoriteProducts: [Product] {
        Catalog.products.filter { store.favorites.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Theme.sage.opacity(0.3))
                            Text("N")
                                .font(Theme.serif(24))
                                .foregroundStyle(Theme.forest)
                        }
                        .frame(width: 56, height: 56)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nook Guest")
                                .font(.headline)
                            Text("Member since today")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Favorites") {
                    if favoriteProducts.isEmpty {
                        Text("Tap the heart on any product to save it here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(favoriteProducts) { product in
                            NavigationLink(value: product) {
                                HStack(spacing: 12) {
                                    ProductArt(product: product, cornerRadius: 10, showsBadge: false)
                                        .frame(width: 44, height: 44)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(product.name).font(.subheadline.weight(.medium))
                                        Text(product.priceLabel).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Orders") {
                    if store.orders.isEmpty {
                        Text("No orders yet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.orders) { order in
                            NavigationLink(value: order) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(order.number)
                                        .font(.subheadline.weight(.semibold))
                                    Text("\(order.placedAt, style: .date) · \(String(format: "$%.2f", order.total))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section {
                    LabeledContent("Status") {
                        Text(osano.hasConsented ? "Consented" : "Not consented")
                            .foregroundStyle(osano.hasConsented ? Theme.forest : .secondary)
                            .fontWeight(.medium)
                    }
                    LabeledContent("Jurisdiction", value: osano.isReady ? osano.jurisdiction.uppercased() : "—")
                    LabeledContent("Banner Variant", value: osano.isReady ? osano.effectiveVariant.capitalized : "—")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Consented Categories")
                        Text(categoriesLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("App Tracking (ATT)") {
                        Text(att.statusLabel)
                            .foregroundStyle(att.status == .authorized ? Theme.forest : .secondary)
                            .fontWeight(.medium)
                    }
                } header: {
                    Text("Current Consent")
                }

                Section {
                    Picker("Force Variant", selection: variantBinding) {
                        Text("Auto (by jurisdiction)").tag("auto")
                        ForEach(["one", "two", "three", "four", "five", "six", "seven"], id: \.self) {
                            Text($0.capitalized).tag($0)
                        }
                    }
                    Button {
                        OsanoService.shared.showPreferences()
                    } label: {
                        Label("Cookie Preferences", systemImage: "slider.horizontal.3")
                    }
                    if att.canRequest {
                        Button {
                            TrackingAuthorization.shared.requestIfNeeded()
                        } label: {
                            Label("Request Tracking Permission", systemImage: "hand.raised")
                        }
                    } else {
                        Button {
                            TrackingAuthorization.shared.openSettings()
                        } label: {
                            Label("Change Tracking Permission in Settings", systemImage: "gear")
                        }
                    }
                    Button(role: .destructive) {
                        OsanoService.shared.resetConsent()
                        consentCleared = true
                    } label: {
                        Label("Reset Consent", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Text("Privacy")
                } footer: {
                    if consentCleared {
                        Text("Consent cleared. Quit and reopen the app to see the consent dialog again. The App Tracking prompt is one-time per install; delete the app to see it again.")
                    } else {
                        Text("A forced variant takes effect the next time the consent dialog is shown. The App Tracking prompt is requested once at launch, before the consent dialog, and the result is forwarded to the Osano SDK.")
                    }
                }

                Section {
                    if consoleExpanded {
                        if DemoLog.shared.entries.isEmpty {
                            Text("Consent and SDK activity will appear here.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(DemoLog.shared.entries.suffix(30).reversed())) { entry in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.text)
                                        .font(.system(.caption2, design: .monospaced))
                                    Text(entry.date, style: .time)
                                        .font(.system(size: 9))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            Button("Clear Console") { DemoLog.shared.clear() }
                                .font(.caption)
                        }
                    }
                } header: {
                    Button {
                        withAnimation { consoleExpanded.toggle() }
                    } label: {
                        HStack(spacing: 6) {
                            Text("SDK Console\(DemoLog.shared.entries.isEmpty ? "" : " (\(DemoLog.shared.entries.count))")")
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .rotationEffect(.degrees(consoleExpanded ? 90 : 0))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } footer: {
                    if consoleExpanded {
                        Text("Newest first. Also mirrored to the Xcode console when the app is run from Xcode.")
                    }
                }
            }
            .navigationTitle("You")
            .onAppear {
                OsanoService.shared.refresh()
                TrackingAuthorization.shared.refreshStatus()
            }
            .onChange(of: scenePhase) { _, phase in
                // Pick up changes made in Settings > Privacy > Tracking.
                if phase == .active { TrackingAuthorization.shared.refreshStatus() }
            }
            .navigationDestination(for: Product.self) { ProductDetailView(product: $0) }
            .navigationDestination(for: Order.self) { OrderDetailView(order: $0) }
        }
    }
}

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        List {
            Section("Items") {
                ForEach(order.items) { item in
                    if let product = item.product {
                        HStack(spacing: 12) {
                            ProductArt(product: product, cornerRadius: 10, showsBadge: false)
                                .frame(width: 44, height: 44)
                            Text("\(item.quantity) × \(product.name)")
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "$%.2f", item.lineTotal))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section {
                HStack {
                    Text("Placed")
                    Spacer()
                    Text(order.placedAt, style: .date).foregroundStyle(.secondary)
                }
                HStack {
                    Text("Total").font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", order.total)).font(.headline)
                }
            }
        }
        .navigationTitle(order.number)
        .navigationBarTitleDisplayMode(.inline)
    }
}
