import Foundation
import SwiftUI

public enum ListSortOrder: String, CaseIterable, Identifiable {
    case nameAsc = "Name (A-Z)"
    case nameDesc = "Name (Z-A)"
    case dateAsc = "Date (Oldest)"
    case dateDesc = "Date (Newest)"
    case categoryAsc = "Category (A-Z)"
    case categoryDesc = "Category (Z-A)"
    
    public var id: String { rawValue }
    
    public var displayName: String { rawValue }
}

enum Currency: String, CaseIterable, Identifiable {
    case USD = "USD"
    case EUR = "EUR"
    case GBP = "GBP"
    case INR = "INR"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .INR: return "₹"
        }
    }
    
    var name: String {
        switch self {
        case .USD: return "US Dollar"
        case .EUR: return "Euro"
        case .GBP: return "British Pound"
        case .INR: return "Indian Rupee"
        }
    }
}

enum Appearance: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

enum NumberFormat: String, CaseIterable, Identifiable {
    case system = "System"
    case dot = "1.234,56"
    case comma = "1,234.56"
    
    var id: String { rawValue }
    
    var decimalSeparator: String {
        switch self {
        case .system:
            return Locale.current.decimalSeparator ?? "."
        case .dot: return ","
        case .comma: return "."
        }
    }
    
    var groupingSeparator: String {
        switch self {
        case .system:
            return Locale.current.groupingSeparator ?? ","
        case .dot: return "."
        case .comma: return ","
        }
    }
}

enum ListViewStyle: String, CaseIterable, Identifiable {
    case list = "List"
    case grid = "Grid"
    
    var id: String { rawValue }
}

enum ItemViewStyle: String, CaseIterable, Identifiable {
    case compact = "Compact"
    case detailed = "Detailed"
    
    var id: String { rawValue }
}

enum NotificationSound: String, CaseIterable, Identifiable {
    case defaultSound = "Default"
    case gentle = "Gentle"
    case urgent = "Urgent"
    case none = "None"
    
    var id: String { rawValue }
}

enum Unit: String, CaseIterable, Identifiable {
    case none = ""
    case kilogram = "kg"
    case gram = "g"
    case pound = "lb"
    case ounce = "oz"
    case liter = "l"
    case milliliter = "ml"
    case gallon = "gal"
    case quart = "qt"
    case pint = "pt"
    case cup = "cup"
    case tablespoon = "tbsp"
    case teaspoon = "tsp"
    case piece = "piece"
    case dozen = "dozen"
    case box = "box"
    case pack = "pack"
    case bottle = "bottle"
    case can = "can"
    case jar = "jar"
    case bag = "bag"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .kilogram: return "Kilogram"
        case .gram: return "Gram"
        case .pound: return "Pound"
        case .ounce: return "Ounce"
        case .liter: return "Liter"
        case .milliliter: return "Milliliter"
        case .gallon: return "Gallon"
        case .quart: return "Quart"
        case .pint: return "Pint"
        case .cup: return "Cup"
        case .tablespoon: return "Tablespoon"
        case .teaspoon: return "Teaspoon"
        case .piece: return "Piece"
        case .dozen: return "Dozen"
        case .box: return "Box"
        case .pack: return "Pack"
        case .bottle: return "Bottle"
        case .can: return "Can"
        case .jar: return "Jar"
        case .bag: return "Bag"
        }
    }
    
    static var allUnits: [Unit] {
        [.none] + allCases.filter { $0 != .none }
    }
} 