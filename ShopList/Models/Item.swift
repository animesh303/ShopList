import Foundation
import SwiftData
import AppIntents

@Model
final class Item {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: Decimal
    var category: ItemCategory
    var isCompleted: Bool
    var notes: String?
    var dateAdded: Date
    var estimatedPrice: Decimal?
    var brand: String?
    var unit: String?
    var lastPurchasedPrice: Decimal?
    var lastPurchasedDate: Date?
    var imageData: Data?
    var priority: ItemPriority
    
    init(id: UUID = UUID(), 
         name: String, 
         quantity: Decimal = 1, 
         category: ItemCategory, 
         isCompleted: Bool = false, 
         notes: String? = nil, 
         dateAdded: Date = Date(),
         estimatedPrice: Decimal? = nil,
         brand: String? = nil,
         unit: String? = nil,
         lastPurchasedPrice: Decimal? = nil,
         lastPurchasedDate: Date? = nil,
         imageData: Data? = nil,
         priority: ItemPriority = .normal) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.isCompleted = isCompleted
        self.notes = notes
        self.dateAdded = dateAdded
        self.estimatedPrice = estimatedPrice
        self.brand = brand
        self.unit = unit
        self.lastPurchasedPrice = lastPurchasedPrice
        self.lastPurchasedDate = lastPurchasedDate
        self.imageData = imageData
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

@Model
final class ItemHistory {
    @Attribute(.unique) var id: UUID
    var name: String
    var lowercaseName: String
    var category: ItemCategory
    var brand: String?
    var unit: String?
    var lastUsedDate: Date
    var usageCount: Int
    var estimatedPrice: Decimal?
    
    init(id: UUID = UUID(),
         name: String,
         category: ItemCategory,
         brand: String? = nil,
         unit: String? = nil,
         lastUsedDate: Date = Date(),
         usageCount: Int = 1,
         estimatedPrice: Decimal? = nil) {
        self.id = id
        self.name = name
        self.lowercaseName = name.lowercased()
        self.category = category
        self.brand = brand
        self.unit = unit
        self.lastUsedDate = lastUsedDate
        self.usageCount = usageCount
        self.estimatedPrice = estimatedPrice
    }
} 