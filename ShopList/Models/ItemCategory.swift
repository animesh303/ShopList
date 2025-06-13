import Foundation
import AppIntents

enum ItemCategory: String, Codable, CaseIterable, AppEnum {
    case groceries = "Groceries"
    case household = "Household"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case other = "Other"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Item Category"
    
    static var caseDisplayRepresentations: [ItemCategory: DisplayRepresentation] = [
        .groceries: "Groceries",
        .household: "Household",
        .electronics: "Electronics",
        .clothing: "Clothing",
        .other: "Other"
    ]
    
    var icon: String {
        switch self {
        case .groceries:
            return "cart.fill"
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