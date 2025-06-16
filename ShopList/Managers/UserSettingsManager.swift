import Foundation
import SwiftUI

class UserSettingsManager: ObservableObject {
    static let shared = UserSettingsManager()
    
    @Published var currency: Currency {
        didSet {
            UserDefaults.standard.set(currency.rawValue, forKey: "selectedCurrency")
        }
    }
    
    @Published var appearance: Appearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: "selectedAppearance")
        }
    }
    
    @Published var defaultListCategory: ListCategory {
        didSet {
            UserDefaults.standard.set(defaultListCategory.rawValue, forKey: "defaultListCategory")
        }
    }
    
    @Published var defaultItemPriority: ItemPriority {
        didSet {
            UserDefaults.standard.set(String(defaultItemPriority.rawValue), forKey: "defaultItemPriority")
        }
    }
    
    @Published var defaultUnit: String {
        didSet {
            UserDefaults.standard.set(defaultUnit, forKey: "defaultUnit")
        }
    }
    
    @Published var numberFormat: NumberFormat {
        didSet {
            UserDefaults.standard.set(numberFormat.rawValue, forKey: "numberFormat")
        }
    }
    
    private init() {
        // Default to USD if no currency is set
        let savedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? Currency.USD.rawValue
        self.currency = Currency(rawValue: savedCurrency) ?? .USD
        
        // Default to system appearance
        let savedAppearance = UserDefaults.standard.string(forKey: "selectedAppearance") ?? Appearance.system.rawValue
        self.appearance = Appearance(rawValue: savedAppearance) ?? .system
        
        // Default to personal category
        let savedListCategory = UserDefaults.standard.string(forKey: "defaultListCategory") ?? ListCategory.personal.rawValue
        self.defaultListCategory = ListCategory(rawValue: savedListCategory) ?? .personal
        
        // Default to normal priority
        let savedItemPriority = UserDefaults.standard.string(forKey: "defaultItemPriority") ?? String(ItemPriority.normal.rawValue)
        self.defaultItemPriority = ItemPriority(rawValue: Int(savedItemPriority) ?? ItemPriority.normal.rawValue) ?? .normal
        
        // Default to empty unit
        self.defaultUnit = UserDefaults.standard.string(forKey: "defaultUnit") ?? ""
        
        // Default to system number format
        let savedNumberFormat = UserDefaults.standard.string(forKey: "numberFormat") ?? NumberFormat.system.rawValue
        self.numberFormat = NumberFormat(rawValue: savedNumberFormat) ?? .system
    }
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