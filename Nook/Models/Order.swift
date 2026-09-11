import Foundation

struct CartItem: Identifiable, Hashable, Codable {
    let id: String          // product id
    var quantity: Int

    var product: Product? { Catalog.product(id: id) }
    var lineTotal: Double { (product?.price ?? 0) * Double(quantity) }
}

struct Order: Identifiable, Hashable, Codable {
    let id: String
    let placedAt: Date
    let items: [CartItem]
    let total: Double

    var number: String { "NK-" + id.prefix(6).uppercased() }
}
