import Foundation
import SwiftData
import AppIntents
import SwiftUI

@Model
final class ShoppingList {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var items: [Item]
    var dateCreated: Date
    var isShared: Bool
    var sharedWith: [String]?
    var category: ListCategory
    var isTemplate: Bool
    var lastModified: Date
    var budget: Double?
    var location: Location?
    
    static let commonUnits = [
        "", // None
        "kg",
        "g",
        "lb",
        "oz",
        "l",
        "ml",
        "gal",
        "qt",
        "pt",
        "cup",
        "tbsp",
        "tsp",
        "piece",
        "dozen",
        "box",
        "pack",
        "bottle",
        "can",
        "jar",
        "bag"
    ]
    
    init(id: UUID = UUID(), 
         name: String, 
         items: [Item] = [], 
         dateCreated: Date = Date(),
         isShared: Bool = false,
         category: ListCategory = .personal,
         isTemplate: Bool = false,
         budget: Double? = nil,
         location: Location? = nil) {
        self.id = id
        self.name = name
        self.items = items
        self.dateCreated = dateCreated
        self.isShared = isShared
        self.category = category
        self.isTemplate = isTemplate
        self.lastModified = dateCreated
        self.budget = budget
        self.location = location
    }
    
    var completedItems: [Item] {
        items.filter { $0.isCompleted }
    }
    
    var pendingItems: [Item] {
        items.filter { !$0.isCompleted }
    }
    
    var itemsByCategory: [ItemCategory: [Item]] {
        Dictionary(grouping: items) { $0.category }
    }
    
    private func calculateItemTotal(_ item: Item) -> Double {
        let price = item.estimatedPrice ?? 0
        let quantity = item.quantity
        return Double(truncating: (price * quantity) as NSDecimalNumber)
    }
    
    var estimatedTotal: Double {
        items.reduce(0) { total, item in
            total + calculateItemTotal(item)
        }
    }
    
    var totalEstimatedCost: Double {
        items.reduce(0) { total, item in
            total + calculateItemTotal(item)
        }
    }
    
    func addItem(_ item: Item) {
        items.append(item)
        lastModified = Date()
    }
    
    func removeItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
        lastModified = Date()
    }
    
    func toggleItemCompletion(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            lastModified = Date()
        }
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            lastModified = Date()
        }
    }
    
    func reorderItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        lastModified = Date()
    }
}

enum ListCategory: String, Codable, CaseIterable, AppEnum, Comparable {
    // Shopping Categories
    case groceries = "Groceries"
    case household = "Household"
    case personalCare = "Personal Care"
    case health = "Health & Pharmacy"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case office = "Office Supplies"
    case pet = "Pet Supplies"
    case baby = "Baby & Kids"
    case automotive = "Automotive"
    case homeImprovement = "Home Improvement"
    case garden = "Garden & Outdoors"
    
    // Special Occasions
    case gifts = "Gifts"
    case party = "Party Supplies"
    case holiday = "Holiday Shopping"
    
    // Travel
    case travel = "Travel"
    case vacation = "Vacation"
    
    // Work & Business
    case work = "Work"
    case business = "Business"
    
    // Other
    case personal = "Personal"
    case other = "Other"
    
    var color: Color {
        switch self {
        case .groceries:
            return .green
        case .household:
            return .blue
        case .personalCare:
            return .pink
        case .health:
            return .red
        case .electronics:
            return .purple
        case .clothing:
            return .orange
        case .office:
            return .gray
        case .pet:
            return .brown
        case .baby:
            return .mint
        case .automotive:
            return .indigo
        case .homeImprovement:
            return .teal
        case .garden:
            return .green
        case .gifts:
            return .pink
        case .party:
            return .purple
        case .holiday:
            return .red
        case .travel:
            return .blue
        case .vacation:
            return .cyan
        case .work:
            return .gray
        case .business:
            return .indigo
        case .personal:
            return .mint
        case .other:
            return .gray
        }
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "List Category"
    
    static let caseDisplayRepresentations: [ListCategory: DisplayRepresentation] = [
        .automotive: DisplayRepresentation(stringLiteral: "Automotive"),
        .baby: DisplayRepresentation(stringLiteral: "Baby & Kids"),
        .business: DisplayRepresentation(stringLiteral: "Business"),
        .clothing: DisplayRepresentation(stringLiteral: "Clothing"),
        .electronics: DisplayRepresentation(stringLiteral: "Electronics"),
        .garden: DisplayRepresentation(stringLiteral: "Garden & Outdoors"),
        .gifts: DisplayRepresentation(stringLiteral: "Gifts"),
        .groceries: DisplayRepresentation(stringLiteral: "Groceries"),
        .health: DisplayRepresentation(stringLiteral: "Health & Pharmacy"),
        .holiday: DisplayRepresentation(stringLiteral: "Holiday Shopping"),
        .homeImprovement: DisplayRepresentation(stringLiteral: "Home Improvement"),
        .household: DisplayRepresentation(stringLiteral: "Household"),
        .office: DisplayRepresentation(stringLiteral: "Office Supplies"),
        .party: DisplayRepresentation(stringLiteral: "Party Supplies"),
        .personal: DisplayRepresentation(stringLiteral: "Personal"),
        .personalCare: DisplayRepresentation(stringLiteral: "Personal Care"),
        .pet: DisplayRepresentation(stringLiteral: "Pet Supplies"),
        .travel: DisplayRepresentation(stringLiteral: "Travel"),
        .vacation: DisplayRepresentation(stringLiteral: "Vacation"),
        .work: DisplayRepresentation(stringLiteral: "Work"),
        .other: DisplayRepresentation(stringLiteral: "Other")
    ]
    
    // Make the enum Comparable for sorting
    static func < (lhs: ListCategory, rhs: ListCategory) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

@Model
final class Location {
    var name: String
    var latitude: Double
    var longitude: Double
    var radius: Double // in meters
    
    init(name: String, latitude: Double, longitude: Double, radius: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
} 