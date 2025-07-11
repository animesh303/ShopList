import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: Decimal
    var category: ItemCategory
    var isCompleted: Bool
    var notes: String?
    var dateAdded: Date
    var pricePerUnit: Decimal?
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
         pricePerUnit: Decimal? = nil,
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
        self.pricePerUnit = pricePerUnit
        self.brand = brand
        self.unit = unit
        self.lastPurchasedPrice = lastPurchasedPrice
        self.lastPurchasedDate = lastPurchasedDate
        self.imageData = imageData
        self.priority = priority
    }
}

enum ItemPriority: Int, Codable, CaseIterable {
    case low = 0
    case normal = 1
    case high = 2
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        }
    }
    
    var icon: String {
        switch self {
        case .high: return "exclamationmark.circle.fill"
        case .normal: return "circle.fill"
        case .low: return "arrow.down.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .high: return .red
        case .normal: return .blue
        case .low: return .gray
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
    var pricePerUnit: Decimal?
    
    init(id: UUID = UUID(),
         name: String,
         category: ItemCategory,
         brand: String? = nil,
         unit: String? = nil,
         lastUsedDate: Date = Date(),
         usageCount: Int = 1,
         pricePerUnit: Decimal? = nil) {
        self.id = id
        self.name = name
        self.lowercaseName = name.lowercased()
        self.category = category
        self.brand = brand
        self.unit = unit
        self.lastUsedDate = lastUsedDate
        self.usageCount = usageCount
        self.pricePerUnit = pricePerUnit
    }
} 