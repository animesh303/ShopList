import Foundation
import AppIntents

enum ItemCategory: String, Codable, CaseIterable, AppEnum, Comparable {
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
    
    // Make the enum Comparable
    static func < (lhs: ItemCategory, rhs: ItemCategory) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Item Category"
    
    static let caseDisplayRepresentations: [ItemCategory: DisplayRepresentation] = [
        .groceries: DisplayRepresentation(stringLiteral: "Groceries"),
        .dairy: DisplayRepresentation(stringLiteral: "Dairy"),
        .bakery: DisplayRepresentation(stringLiteral: "Bakery"),
        .produce: DisplayRepresentation(stringLiteral: "Produce"),
        .meat: DisplayRepresentation(stringLiteral: "Meat & Seafood"),
        .frozenFoods: DisplayRepresentation(stringLiteral: "Frozen Foods"),
        .beverages: DisplayRepresentation(stringLiteral: "Beverages"),
        .snacks: DisplayRepresentation(stringLiteral: "Snacks"),
        .spices: DisplayRepresentation(stringLiteral: "Spices & Herbs"),
        .household: DisplayRepresentation(stringLiteral: "Household"),
        .cleaning: DisplayRepresentation(stringLiteral: "Cleaning"),
        .laundry: DisplayRepresentation(stringLiteral: "Laundry"),
        .kitchen: DisplayRepresentation(stringLiteral: "Kitchen"),
        .bathroom: DisplayRepresentation(stringLiteral: "Bathroom"),
        .office: DisplayRepresentation(stringLiteral: "Office"),
        .personalCare: DisplayRepresentation(stringLiteral: "Personal Care"),
        .beauty: DisplayRepresentation(stringLiteral: "Beauty"),
        .health: DisplayRepresentation(stringLiteral: "Health"),
        .babyCare: DisplayRepresentation(stringLiteral: "Baby Care"),
        .petCare: DisplayRepresentation(stringLiteral: "Pet Care"),
        .electronics: DisplayRepresentation(stringLiteral: "Electronics"),
        .clothing: DisplayRepresentation(stringLiteral: "Clothing"),
        .automotive: DisplayRepresentation(stringLiteral: "Automotive"),
        .garden: DisplayRepresentation(stringLiteral: "Garden"),
        .other: DisplayRepresentation(stringLiteral: "Other")
    ]
    
    var icon: String {
        switch self {
        // Food & Beverages
        case .groceries: return "cart.fill"
        case .dairy: return "milkbottle.fill"
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
        case .personalCare: return "hand.raised.fill"
        case .beauty: return "comb.fill"
        case .health: return "cross.case.fill"
        case .babyCare: return "figure.and.baby"
        case .petCare: return "pawprint.fill"
            
        // Other
        case .electronics: return "desktopcomputer"
        case .clothing: return "tshirt.fill"
        case .automotive: return "car.fill"
        case .garden: return "leaf.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
} 