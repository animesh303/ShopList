import Foundation
import AppIntents

enum ItemCategory: String, Codable, CaseIterable, AppEnum {
    case groceries = "Groceries"
    case dairy = "Dairy"
    case bakery = "Bakery"
    case produce = "Produce"
    case meat = "Meat"
    case household = "Household"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case other = "Other"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Item Category"
    
    static var caseDisplayRepresentations: [ItemCategory: DisplayRepresentation] = [
        .groceries: "Groceries",
        .dairy: "Dairy",
        .bakery: "Bakery",
        .produce: "Produce",
        .meat: "Meat",
        .household: "Household",
        .electronics: "Electronics",
        .clothing: "Clothing",
        .other: "Other"
    ]
    
    var icon: String {
        switch self {
        case .groceries:
            return "cart.fill"
        case .dairy:
            return "milkbottle.fill"
        case .bakery:
            return "birthday.cake.fill"
        case .produce:
            return "leaf.fill"
        case .meat:
            return "fork.knife"
        case .household:
            return "house.fill"
        case .electronics:
            return "desktopcomputer"
        case .clothing:
            return "tshirt.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
} 