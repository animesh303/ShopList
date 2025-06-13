import Foundation

enum ItemCategory: String, Codable, CaseIterable {
    case groceries = "Groceries"
    case household = "Household"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case other = "Other"
    
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