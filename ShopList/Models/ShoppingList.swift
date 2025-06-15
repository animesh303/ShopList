import Foundation
import AppIntents

struct ShoppingList: Identifiable, Codable {
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

enum ListCategory: String, Codable, CaseIterable, AppEnum {
    case personal = "Personal"
    case household = "Household"
    case groceries = "Groceries"
    case gifts = "Gifts"
    case other = "Other"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "List Category"
    
    static var caseDisplayRepresentations: [ListCategory: DisplayRepresentation] = [
        .personal: "Personal",
        .household: "Household",
        .groceries: "Groceries",
        .gifts: "Gifts",
        .other: "Other"
    ]
}

struct Location: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    var radius: Double // in meters
} 