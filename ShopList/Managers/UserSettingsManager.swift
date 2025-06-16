import Foundation

class UserSettingsManager: ObservableObject {
    static let shared = UserSettingsManager()
    
    @Published var currency: Currency {
        didSet {
            UserDefaults.standard.set(currency.rawValue, forKey: "selectedCurrency")
        }
    }
    
    private init() {
        // Default to USD if no currency is set
        let savedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? Currency.USD.rawValue
        self.currency = Currency(rawValue: savedCurrency) ?? .USD
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