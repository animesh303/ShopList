import Foundation

enum ItemCategory: String, Codable, CaseIterable, Comparable, Identifiable {
    // Sorted alphabetically for better organization
    case automotive = "Automotive"
    case babyCare = "Baby Care"
    case bakery = "Bakery"
    case bathroom = "Bathroom"
    case beauty = "Beauty"
    case beverages = "Beverages"
    case cleaning = "Cleaning"
    case clothing = "Clothing"
    case dairy = "Dairy"
    case electronics = "Electronics"
    case frozenFoods = "Frozen Foods"
    case garden = "Garden"
    case groceries = "Groceries"
    case health = "Health"
    case household = "Household"
    case kitchen = "Kitchen"
    case laundry = "Laundry"
    case meat = "Meat & Seafood"
    case office = "Office"
    case other = "Other"
    case personalCare = "Personal Care"
    case petCare = "Pet Care"
    case produce = "Produce"
    case snacks = "Snacks"
    case spices = "Spices & Herbs"
    
    // Make the enum Comparable for sorting
    public static func < (lhs: ItemCategory, rhs: ItemCategory) -> Bool {
        return lhs.rawValue.localizedStandardCompare(rhs.rawValue) == .orderedAscending
    }
    

    
    var icon: String {
        switch self {
        // Food & Beverages
        case .groceries: return "cart.fill"
        case .dairy: return "drop.fill"
        case .bakery: return "birthday.cake.fill"
        case .produce: return "leaf.fill"
        case .meat: return "fish.fill"
        case .frozenFoods: return "snowflake"
        case .beverages: return "mug.fill"
        case .snacks: return "takeoutbag.and.cup.and.straw.fill"
        case .spices: return "leaf.arrow.triangle.circlepath"
            
        // Household
        case .household: return "house.fill"
        case .cleaning: return "bubbles.and.sparkles.fill"
        case .laundry: return "washer.fill"
        case .kitchen: return "fork.knife"
        case .bathroom: return "shower.fill"
        case .office: return "doc.text.fill"
            
        // Personal Care
        case .personalCare: return "heart.circle.fill"
        case .beauty: return "comb.fill"
        case .health: return "cross.case.fill"
        case .babyCare: return "heart.fill"
        case .petCare: return "pawprint.fill"
            
        // Other
        case .electronics: return "desktopcomputer"
        case .clothing: return "tshirt.fill"
        case .automotive: return "car.fill"
        case .garden: return "leaf.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var id: String { rawValue }
} 