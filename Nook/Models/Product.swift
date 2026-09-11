import SwiftUI

enum ProductCategory: String, CaseIterable, Identifiable, Codable {
    case ceramics = "Ceramics"
    case textiles = "Textiles"
    case lighting = "Lighting"
    case botanical = "Botanical"
    case woodcraft = "Woodcraft"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .ceramics: "cup.and.saucer.fill"
        case .textiles: "square.grid.3x3.topleft.filled"
        case .lighting: "lamp.table.fill"
        case .botanical: "leaf.fill"
        case .woodcraft: "archivebox.fill"
        }
    }

    var tint: Color {
        switch self {
        case .ceramics: Theme.clay
        case .textiles: Color(red: 0.45, green: 0.42, blue: 0.60)
        case .lighting: Color(red: 0.85, green: 0.66, blue: 0.30)
        case .botanical: Theme.sage
        case .woodcraft: Color(red: 0.55, green: 0.40, blue: 0.28)
        }
    }
}

struct Product: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let maker: String
    let price: Double
    let category: ProductCategory
    let blurb: String
    let details: [String]
    let rating: Double
    let reviewCount: Int
    let symbol: String
    var isNew: Bool = false

    var priceLabel: String { String(format: "$%.0f", price) }
}

enum Catalog {
    static let products: [Product] = [
        Product(id: "p1", name: "Alta Stoneware Mug", maker: "Kiln & Co.", price: 34,
                category: .ceramics,
                blurb: "Hand-thrown stoneware with a speckled glaze that pools beautifully at the base. Holds 12 oz of whatever gets you going.",
                details: ["Hand-thrown stoneware", "Dishwasher & microwave safe", "12 oz capacity", "Made in Asheville, NC"],
                rating: 4.8, reviewCount: 212, symbol: "cup.and.saucer.fill", isNew: true),
        Product(id: "p2", name: "Meridian Bud Vase", maker: "Kiln & Co.", price: 48,
                category: .ceramics,
                blurb: "A sculptural bud vase with an off-center neck. Happiest holding a single stem of something wild.",
                details: ["Matte porcelain body", "Water-sealed interior", "5.5\" tall", "Each piece is unique"],
                rating: 4.6, reviewCount: 87, symbol: "laurel.leading"),
        Product(id: "p3", name: "Ojai Serving Bowl", maker: "Terra Studio", price: 76,
                category: .ceramics,
                blurb: "Wide and shallow with a raw clay rim. Built for grain salads, citrus piles, and looking good empty.",
                details: ["Food-safe glaze", "11\" diameter", "Hand-wash recommended", "Small-batch fired"],
                rating: 4.9, reviewCount: 143, symbol: "circle.circle.fill"),
        Product(id: "p4", name: "Harbor Throw Blanket", maker: "Loom House", price: 128,
                category: .textiles,
                blurb: "Chunky wool-blend throw in undyed oatmeal. Heavy enough to mean it, soft enough to nap under.",
                details: ["80% wool, 20% cotton", "50\" x 70\"", "Undyed natural fibers", "Woven in Maine"],
                rating: 4.7, reviewCount: 324, symbol: "square.grid.3x3.topleft.filled", isNew: true),
        Product(id: "p5", name: "Sur Linen Napkins", maker: "Loom House", price: 42,
                category: .textiles,
                blurb: "Set of four stonewashed linen napkins that get softer with every wash. Wrinkles are the point.",
                details: ["100% European flax", "Set of 4", "18\" square", "Machine washable"],
                rating: 4.5, reviewCount: 96, symbol: "square.stack.fill"),
        Product(id: "p6", name: "Dune Lumbar Pillow", maker: "Field Textile", price: 68,
                category: .textiles,
                blurb: "Hand-blocked lumbar pillow in a faded terracotta stripe. Insert included, opinions optional.",
                details: ["Cotton canvas cover", "Feather-down insert", "14\" x 24\"", "Hidden zipper"],
                rating: 4.6, reviewCount: 158, symbol: "rectangle.fill.on.rectangle.fill"),
        Product(id: "p7", name: "Vesper Table Lamp", maker: "North Light", price: 189,
                category: .lighting,
                blurb: "A cast-ceramic base with a washed-paper shade. Throws the kind of light that makes everyone look rested.",
                details: ["Ceramic base, paper shade", "Full-range dimmer", "18\" tall", "E26 bulb included"],
                rating: 4.9, reviewCount: 267, symbol: "lamp.table.fill", isNew: true),
        Product(id: "p8", name: "Ember Candle Trio", maker: "North Light", price: 54,
                category: .lighting,
                blurb: "Three hand-poured candles — cedar, fig, and beeswax. Burn one at a time or commit to the full campfire.",
                details: ["Soy-beeswax blend", "40-hour burn each", "Cotton wicks", "Reusable amber jars"],
                rating: 4.4, reviewCount: 189, symbol: "flame.fill"),
        Product(id: "p9", name: "Fern Stand, Walnut", maker: "Grain Works", price: 145,
                category: .botanical,
                blurb: "A three-legged plant stand in oiled walnut. Elevates your ferns literally and socially.",
                details: ["Solid walnut", "Fits pots up to 10\"", "22\" tall", "Danish oil finish"],
                rating: 4.8, reviewCount: 74, symbol: "leaf.fill"),
        Product(id: "p10", name: "Meadow Seed Kit", maker: "Field & Flora", price: 28,
                category: .botanical,
                blurb: "Everything to grow a windowsill meadow: native wildflower seeds, coir pots, and instructions you'll actually read.",
                details: ["6 native species", "Biodegradable pots", "Grow guide included", "Zone 4-9 friendly"],
                rating: 4.3, reviewCount: 341, symbol: "sparkles", isNew: true),
        Product(id: "p11", name: "Arbor Cutting Board", maker: "Grain Works", price: 92,
                category: .woodcraft,
                blurb: "End-grain maple board that's kind to knives and unbothered by decades of use. Gets better looking as it ages.",
                details: ["End-grain hard maple", "16\" x 12\" x 1.5\"", "Food-safe mineral oil finish", "Juice groove"],
                rating: 4.9, reviewCount: 412, symbol: "archivebox.fill"),
        Product(id: "p12", name: "Cove Catch-All Tray", maker: "Grain Works", price: 38,
                category: .woodcraft,
                blurb: "A carved white-oak tray for keys, rings, and the pocket archaeology of daily life.",
                details: ["Solid white oak", "8\" x 5\"", "Hand-carved wells", "Natural wax finish"],
                rating: 4.5, reviewCount: 66, symbol: "tray.fill"),
    ]

    static func product(id: String) -> Product? {
        products.first { $0.id == id }
    }
}
