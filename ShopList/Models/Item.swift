import Foundation
import AppIntents

struct Item: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
    var category: ItemCategory
    var isCompleted: Bool
    var notes: String?
    var dateAdded: Date
    var estimatedPrice: Double?
    var barcode: String?
    var brand: String?
    var unit: String?
    var lastPurchasedPrice: Double?
    var lastPurchasedDate: Date?
    var imageURL: URL?
    var priority: ItemPriority
    
    init(id: UUID = UUID(), 
         name: String, 
         quantity: Int, 
         category: ItemCategory, 
         isCompleted: Bool = false, 
         notes: String? = nil, 
         dateAdded: Date = Date(),
         estimatedPrice: Double? = nil,
         barcode: String? = nil,
         brand: String? = nil,
         unit: String? = nil,
         lastPurchasedPrice: Double? = nil,
         lastPurchasedDate: Date? = nil,
         imageURL: URL? = nil,
         priority: ItemPriority = .normal) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.isCompleted = isCompleted
        self.notes = notes
        self.dateAdded = dateAdded
        self.estimatedPrice = estimatedPrice
        self.barcode = barcode
        self.brand = brand
        self.unit = unit
        self.lastPurchasedPrice = lastPurchasedPrice
        self.lastPurchasedDate = lastPurchasedDate
        self.imageURL = imageURL
        self.priority = priority
    }
}

enum ItemPriority: Int, Codable, CaseIterable, AppEnum {
    case low = 0
    case normal = 1
    case high = 2
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Item Priority"
    
    static var caseDisplayRepresentations: [ItemPriority: DisplayRepresentation] = [
        .low: "Low",
        .normal: "Normal",
        .high: "High"
    ]
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "gray"
        case .normal: return "blue"
        case .high: return "red"
        }
    }
} 