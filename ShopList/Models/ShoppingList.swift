import Foundation
import SwiftData
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
        guard let price = item.pricePerUnit else { return 0.0 }
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
    
    var totalSpentCost: Double {
        completedItems.reduce(0) { total, item in
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
    
    /// Updates an item in the list by matching its id. If not found, does nothing.
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            lastModified = Date()
        }
    }
    
    /// Reorders items in the list using Swift's move(fromOffsets:toOffset:).
    /// This is the correct way to reorder items for SwiftUI drag-and-drop.
    func reorderItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        lastModified = Date()
    }
}

enum ListCategory: String, Codable, CaseIterable, Comparable {
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
            return DesignSystem.Colors.categoryGroceries
        case .household:
            return DesignSystem.Colors.categoryHousehold
        case .personalCare:
            return DesignSystem.Colors.categoryPersonalCare
        case .health:
            return DesignSystem.Colors.categoryHealth
        case .electronics:
            return DesignSystem.Colors.categoryElectronics
        case .clothing:
            return DesignSystem.Colors.categoryClothing
        case .office:
            return DesignSystem.Colors.categoryOffice
        case .pet:
            return DesignSystem.Colors.categoryPet
        case .baby:
            return DesignSystem.Colors.categoryBaby
        case .automotive:
            return DesignSystem.Colors.categoryAutomotive
        case .homeImprovement:
            return DesignSystem.Colors.categoryHomeImprovement
        case .garden:
            return DesignSystem.Colors.categoryGarden
        case .gifts:
            return DesignSystem.Colors.categoryGifts
        case .party:
            return DesignSystem.Colors.categoryParty
        case .holiday:
            return DesignSystem.Colors.categoryHoliday
        case .travel:
            return DesignSystem.Colors.categoryTravel
        case .vacation:
            return DesignSystem.Colors.categoryVacation
        case .work:
            return DesignSystem.Colors.categoryWork
        case .business:
            return DesignSystem.Colors.categoryBusiness
        case .personal:
            return DesignSystem.Colors.categoryPersonal
        case .other:
            return DesignSystem.Colors.categoryOther
        }
    }
    
    var icon: String {
        switch self {
        case .groceries:
            return "cart.fill"
        case .household:
            return "house.fill"
        case .personalCare:
            return "heart.circle.fill"
        case .health:
            return "cross.case.fill"
        case .electronics:
            return "desktopcomputer"
        case .clothing:
            return "tshirt.fill"
        case .office:
            return "doc.text.fill"
        case .pet:
            return "pawprint.fill"
        case .baby:
            return "heart.fill"
        case .automotive:
            return "car.fill"
        case .homeImprovement:
            return "hammer.fill"
        case .garden:
            return "leaf.fill"
        case .gifts:
            return "gift.fill"
        case .party:
            return "party.popper.fill"
        case .holiday:
            return "star.fill"
        case .travel:
            return "airplane"
        case .vacation:
            return "beach.umbrella.fill"
        case .work:
            return "briefcase.fill"
        case .business:
            return "building.2.fill"
        case .personal:
            return "person.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
    

    
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