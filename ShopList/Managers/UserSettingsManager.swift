import Foundation
import SwiftUI

// Remove all @_exported imports since they're not needed
// The enums are already available in the module

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
    
    @Published var defaultListSortOrder: ListSortOrder {
        didSet {
            UserDefaults.standard.set(defaultListSortOrder.rawValue, forKey: "defaultListSortOrder")
        }
    }
    
    @Published var defaultListViewStyle: ListViewStyle {
        didSet {
            UserDefaults.standard.set(defaultListViewStyle.rawValue, forKey: "defaultListViewStyle")
        }
    }
    
    @Published var showCompletedItemsByDefault: Bool {
        didSet {
            UserDefaults.standard.set(showCompletedItemsByDefault, forKey: "showCompletedItemsByDefault")
        }
    }
    
    @Published var showItemImagesByDefault: Bool {
        didSet {
            UserDefaults.standard.set(showItemImagesByDefault, forKey: "showItemImagesByDefault")
        }
    }
    
    @Published var showItemNotesByDefault: Bool {
        didSet {
            UserDefaults.standard.set(showItemNotesByDefault, forKey: "showItemNotesByDefault")
        }
    }
    
    @Published var defaultItemViewStyle: ItemViewStyle {
        didSet {
            UserDefaults.standard.set(defaultItemViewStyle.rawValue, forKey: "defaultItemViewStyle")
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var defaultReminderTime: Date {
        didSet {
            UserDefaults.standard.set(defaultReminderTime, forKey: "defaultReminderTime")
        }
    }
    
    @Published var notificationSound: NotificationSound {
        didSet {
            UserDefaults.standard.set(notificationSound.rawValue, forKey: "notificationSound")
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
        
        // New List View Preferences initialization
        let savedListSortOrder = UserDefaults.standard.string(forKey: "defaultListSortOrder") ?? ListSortOrder.dateDesc.rawValue
        self.defaultListSortOrder = ListSortOrder(rawValue: savedListSortOrder) ?? .dateDesc
        
        let savedListViewStyle = UserDefaults.standard.string(forKey: "defaultListViewStyle") ?? ListViewStyle.list.rawValue
        self.defaultListViewStyle = ListViewStyle(rawValue: savedListViewStyle) ?? .list
        
        self.showCompletedItemsByDefault = UserDefaults.standard.bool(forKey: "showCompletedItemsByDefault")
        
        // New Item Display Preferences initialization
        self.showItemImagesByDefault = UserDefaults.standard.bool(forKey: "showItemImagesByDefault")
        self.showItemNotesByDefault = UserDefaults.standard.bool(forKey: "showItemNotesByDefault")
        
        let savedItemViewStyle = UserDefaults.standard.string(forKey: "defaultItemViewStyle") ?? ItemViewStyle.compact.rawValue
        self.defaultItemViewStyle = ItemViewStyle(rawValue: savedItemViewStyle) ?? .compact
        
        // New Notification Preferences initialization
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        if let savedReminderTime = UserDefaults.standard.object(forKey: "defaultReminderTime") as? Date {
            self.defaultReminderTime = savedReminderTime
        } else {
            // Default to 9:00 AM
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            self.defaultReminderTime = Calendar.current.date(from: components) ?? Date()
        }
        
        let savedNotificationSound = UserDefaults.standard.string(forKey: "notificationSound") ?? NotificationSound.defaultSound.rawValue
        self.notificationSound = NotificationSound(rawValue: savedNotificationSound) ?? .defaultSound
    }
} 