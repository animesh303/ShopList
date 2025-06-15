import Foundation
import AppIntents

struct ShoppingList: Identifiable, Codable {
    static let commonUnits = [
        "", // Empty for none
        "Gram", "Kilogram", "Milliliter", "Liter", "Ounce", "Pound",
        "Teaspoon", "Tablespoon", "Cup", "Pint",
        "Piece", "Pieces", "Box", "Pack", "Bunch"
    ]
    let id: UUID
    var name: String
    var items: [Item]
    var dateCreated: Date
    var isShared: Bool
    var sharedWith: [String]?
    var category: ListCategory
    var isTemplate: Bool
    var lastModified: Date
    var budget: Decimal?
    var location: Location?
    
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
        // Convert Double budget to Decimal if it's valid
        if let budget = budget, !budget.isNaN && !budget.isInfinite {
            self.budget = Decimal(budget)
        } else {
            self.budget = nil
        }
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
    
    var totalEstimatedCost: Decimal {
        items.reduce(0) { $0 + (($1.estimatedPrice ?? 0) as Decimal) * $1.quantity }
    }
    
    mutating func addItem(_ item: Item) {
        items.append(item)
        lastModified = Date()
    }
    
    mutating func removeItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
        lastModified = Date()
    }
    
    mutating func toggleItemCompletion(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            lastModified = Date()
        }
    }
    
    mutating func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            lastModified = Date()
        }
    }
    
    mutating func reorderItems(from source: IndexSet, to destination: Int) {
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

struct Location: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    var radius: Double // in meters
} 