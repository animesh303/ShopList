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
    
    public var icon: String {
        switch self {
        case .nameAsc: return "textformat.abc"
        case .nameDesc: return "textformat.abc.dottedunderline"
        case .dateAsc: return "calendar"
        case .dateDesc: return "calendar.badge.clock"
        case .categoryAsc: return "square.grid.2x2"
        case .categoryDesc: return "square.grid.2x2.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .nameAsc, .nameDesc: return .blue
        case .dateAsc, .dateDesc: return .orange
        case .categoryAsc, .categoryDesc: return .purple
        }
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

    var icon: String {
        switch self {
        case .USD: return "dollarsign.circle.fill"
        case .EUR: return "eurosign.circle.fill"
        case .GBP: return "sterlingsign.circle.fill"
        case .INR: return "indianrupeesign.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .USD: return .green
        case .EUR: return .blue
        case .GBP: return .purple
        case .INR: return .orange
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
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "gear"
        }
    }
    
    var color: Color {
        switch self {
        case .light: return .orange
        case .dark: return .purple
        case .system: return .blue
        }
    }
}

enum NumberFormat: String, CaseIterable, Identifiable {
    case system = "System"
    case dot = "1.234,56"
    case comma = "1,234.56"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .system: return "gear"
        case .dot: return "circle.dotted"
        case .comma: return "circle.lefthalf.filled"
        }
    }
    
    var color: Color {
        switch self {
        case .system: return .gray
        case .dot: return .blue
        case .comma: return .green
        }
    }
    
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
    
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
    
    var color: Color {
        switch self {
        case .list: return .blue
        case .grid: return .purple
        }
    }
}

enum ItemViewStyle: String, CaseIterable, Identifiable {
    case compact = "Compact"
    case detailed = "Detailed"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .compact: return "rectangle.compress.vertical"
        case .detailed: return "rectangle.expand.vertical"
        }
    }
    
    var color: Color {
        switch self {
        case .compact: return .teal
        case .detailed: return .indigo
        }
    }
}

enum NotificationSound: String, CaseIterable, Identifiable {
    case defaultSound = "Default"
    case gentle = "Gentle"
    case urgent = "Urgent"
    case none = "None"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .defaultSound: return "bell.fill"
        case .gentle: return "bell.badge"
        case .urgent: return "exclamationmark.triangle.fill"
        case .none: return "bell.slash.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .defaultSound: return .blue
        case .gentle: return .green
        case .urgent: return .red
        case .none: return .gray
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
    
    var icon: String {
        switch self {
        case .none: return "nosign"
        case .kilogram: return "scalemass.fill"
        case .gram: return "scalemass"
        case .pound: return "scalemass"
        case .ounce: return "scalemass"
        case .liter: return "drop.fill"
        case .milliliter: return "drop"
        case .gallon: return "drop.triangle"
        case .quart: return "drop.triangle"
        case .pint: return "drop.triangle"
        case .cup: return "cup.and.saucer.fill"
        case .tablespoon: return "takeoutbag.and.cup.and.straw.fill"
        case .teaspoon: return "takeoutbag.and.cup.and.straw"
        case .piece: return "circle.fill"
        case .dozen: return "circle.grid.2x2.fill"
        case .box: return "shippingbox.fill"
        case .pack: return "cube.box.fill"
        case .bottle: return "wineglass.fill"
        case .can: return "cylinder.split.1x2.fill"
        case .jar: return "externaldrive.fill"
        case .bag: return "bag.fill"
        }
    }

    var color: Color {
        switch self {
        case .none: return .gray
        case .kilogram, .gram, .pound, .ounce: return .orange
        case .liter, .milliliter, .gallon, .quart, .pint: return .blue
        case .cup, .tablespoon, .teaspoon: return .purple
        case .piece, .dozen: return .green
        case .box, .pack: return .brown
        case .bottle: return .red
        case .can: return .teal
        case .jar: return .yellow
        case .bag: return .mint
        }
    }
    
    static var allUnits: [Unit] {
        [.none] + allCases.filter { $0 != .none }
    }
}

// MARK: - Subscription Enums

enum SubscriptionTier: String, CaseIterable, Identifiable {
    case free = "Free"
    case premium = "Premium"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        }
    }
    
    var color: Color {
        switch self {
        case .free: return .gray
        case .premium: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .free: return "person.circle"
        case .premium: return "crown.fill"
        }
    }
}

enum SubscriptionPeriod: String, CaseIterable, Identifiable {
    case monthly = "monthly"
    case yearly = "yearly"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var savings: String? {
        switch self {
        case .monthly: return nil
        case .yearly: return "Save 33%"
        }
    }
}

enum PremiumFeature: String, CaseIterable, Identifiable {
    case unlimitedLists = "Unlimited Lists"
    case allCategories = "All Categories"
    case locationReminders = "Location Reminders"
    case unlimitedNotifications = "Unlimited Notifications"
    case widgets = "iOS Widgets"
    case budgetTracking = "Budget Tracking"
    case itemImages = "Item Images"
    case exportImport = "Export/Import"
    case prioritySupport = "Priority Support"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .unlimitedLists:
            return "Create unlimited shopping lists"
        case .allCategories:
            return "Access to all 20+ categories"
        case .locationReminders:
            return "Get notified when near stores"
        case .unlimitedNotifications:
            return "Unlimited daily notifications"
        case .widgets:
            return "Home screen widgets"
        case .budgetTracking:
            return "Track spending with budgets"
        case .itemImages:
            return "Add photos to items"
        case .exportImport:
            return "Backup and restore data"
        case .prioritySupport:
            return "Priority customer support"
        }
    }
    
    var icon: String {
        switch self {
        case .unlimitedLists: return "list.bullet"
        case .allCategories: return "folder.fill"
        case .locationReminders: return "location.circle.fill"
        case .unlimitedNotifications: return "bell.fill"
        case .widgets: return "rectangle.3.group.fill"
        case .budgetTracking: return "chart.line.uptrend.xyaxis"
        case .itemImages: return "photo.fill"
        case .exportImport: return "square.and.arrow.up"
        case .prioritySupport: return "person.crop.circle.badge.questionmark"
        }
    }
    
    var isAvailableInFree: Bool {
        switch self {
        case .unlimitedLists: return false
        case .allCategories: return false
        case .locationReminders: return false
        case .unlimitedNotifications: return false
        case .widgets: return false
        case .budgetTracking: return false
        case .itemImages: return false
        case .exportImport: return false
        case .prioritySupport: return false
        }
    }
} 