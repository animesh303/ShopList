import Foundation
import SwiftUI
import CoreLocation

// MARK: - UserSettingsManager
/// Manages user preferences and settings with premium feature validation
/// 
/// FIXED: Premium-only settings (like showItemImagesByDefault) now properly respect
/// subscription status and are automatically reset when premium access is lost.
/// This prevents non-premium users from having premium features enabled by default.
///
/// FIXED: Added @MainActor to resolve Swift 6 concurrency issues when accessing
/// SubscriptionManager.shared and other main actor-isolated properties.

// Remove all @_exported imports since they're not needed
// The enums are already available in the module

@MainActor
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
    
    @Published var defaultItemCategory: ItemCategory {
        didSet {
            // Ensure the default category is always available for free users
            if !SubscriptionManager.shared.canUseItemCategory(defaultItemCategory) {
                // Reset to a free category
                defaultItemCategory = SubscriptionManager.shared.getAvailableItemCategories().first ?? .other
            }
            UserDefaults.standard.set(defaultItemCategory.rawValue, forKey: "defaultItemCategory")
        }
    }
    
    @Published var defaultUnit: String {
        didSet {
            // Ensure the default unit is always available for free users
            if let unitEnum = Unit(rawValue: defaultUnit), !SubscriptionManager.shared.canUseUnit(unitEnum) {
                // Reset to a free unit
                defaultUnit = SubscriptionManager.shared.getAvailableUnits().first?.rawValue ?? ""
            }
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
            // Only allow setting to true if user has premium access
            if showItemImagesByDefault && !SubscriptionManager.shared.canUseItemImages() {
                // Revert the change if user doesn't have premium
                showItemImagesByDefault = false
                return
            }
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
            
            // Handle notification permission when setting is toggled
            if notificationsEnabled {
                Task {
                    let granted = await NotificationManager.shared.requestNotificationPermission()
                    if !granted {
                        // If permission denied, revert the setting
                        await MainActor.run {
                            self.notificationsEnabled = false
                        }
                    }
                }
            }
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
    
    @Published var notificationBannerStyle: NotificationBannerStyle {
        didSet {
            UserDefaults.standard.set(notificationBannerStyle.rawValue, forKey: "notificationBannerStyle")
        }
    }
    
    @Published var restrictSearchToLocality: Bool {
        didSet {
            UserDefaults.standard.set(restrictSearchToLocality, forKey: "restrictSearchToLocality")
        }
    }
    
    @Published var searchRadius: Double {
        didSet {
            UserDefaults.standard.set(searchRadius, forKey: "searchRadius")
        }
    }
    
    @Published var useCurrentLocationForSearch: Bool {
        didSet {
            UserDefaults.standard.set(useCurrentLocationForSearch, forKey: "useCurrentLocationForSearch")
        }
    }
    
    @Published var savedSearchLocation: CLLocationCoordinate2D? {
        didSet {
            if let location = savedSearchLocation {
                UserDefaults.standard.set(location.latitude, forKey: "savedSearchLocationLatitude")
                UserDefaults.standard.set(location.longitude, forKey: "savedSearchLocationLongitude")
            } else {
                UserDefaults.standard.removeObject(forKey: "savedSearchLocationLatitude")
                UserDefaults.standard.removeObject(forKey: "savedSearchLocationLongitude")
            }
        }
    }
    
    private init() {
        // Default to USD if no currency is set
        let savedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? Currency.USD.rawValue
        self.currency = Currency(rawValue: savedCurrency) ?? .USD
        
        // Default to system appearance
        let savedAppearance = UserDefaults.standard.string(forKey: "selectedAppearance") ?? Appearance.system.rawValue
        self.appearance = Appearance(rawValue: savedAppearance) ?? .system
        
        // Default to groceries category
        let savedListCategory = UserDefaults.standard.string(forKey: "defaultListCategory") ?? ListCategory.groceries.rawValue
        self.defaultListCategory = ListCategory(rawValue: savedListCategory) ?? .groceries
        
        // Default to normal priority
        let savedItemPriority = UserDefaults.standard.string(forKey: "defaultItemPriority") ?? String(ItemPriority.normal.rawValue)
        self.defaultItemPriority = ItemPriority(rawValue: Int(savedItemPriority) ?? ItemPriority.normal.rawValue) ?? .normal
        
        // Default to groceries category for items
        let savedItemCategory = UserDefaults.standard.string(forKey: "defaultItemCategory") ?? ItemCategory.groceries.rawValue
        let initialCategory = ItemCategory(rawValue: savedItemCategory) ?? .groceries
        
        // Ensure the default category is available for free users
        if SubscriptionManager.shared.canUseItemCategory(initialCategory) {
            self.defaultItemCategory = initialCategory
        } else {
            self.defaultItemCategory = SubscriptionManager.shared.getAvailableItemCategories().first ?? .other
        }
        
        // Default to kilogram unit
        let savedUnit = UserDefaults.standard.string(forKey: "defaultUnit") ?? Unit.kilogram.rawValue
        let initialUnit = Unit(rawValue: savedUnit) ?? .kilogram
        
        // Ensure the default unit is available for free users
        if SubscriptionManager.shared.canUseUnit(initialUnit) {
            self.defaultUnit = initialUnit.rawValue
        } else {
            self.defaultUnit = SubscriptionManager.shared.getAvailableUnits().first?.rawValue ?? ""
        }
        
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
        // Check premium access for showItemImagesByDefault
        let savedShowItemImages = UserDefaults.standard.bool(forKey: "showItemImagesByDefault")
        self.showItemImagesByDefault = savedShowItemImages && SubscriptionManager.shared.canUseItemImages()
        
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
        
        let savedNotificationBannerStyle = UserDefaults.standard.string(forKey: "notificationBannerStyle") ?? NotificationBannerStyle.banner.rawValue
        self.notificationBannerStyle = NotificationBannerStyle(rawValue: savedNotificationBannerStyle) ?? .banner
        
        // Location-based search settings
        self.restrictSearchToLocality = UserDefaults.standard.bool(forKey: "restrictSearchToLocality")
        
        let savedSearchRadius = UserDefaults.standard.double(forKey: "searchRadius")
        self.searchRadius = savedSearchRadius == 0 ? 5000 : savedSearchRadius // Default 5km radius
        
        self.useCurrentLocationForSearch = UserDefaults.standard.bool(forKey: "useCurrentLocationForSearch")
        
        // Load saved search location
        let savedLatitude = UserDefaults.standard.double(forKey: "savedSearchLocationLatitude")
        let savedLongitude = UserDefaults.standard.double(forKey: "savedSearchLocationLongitude")
        if savedLatitude != 0 && savedLongitude != 0 {
            self.savedSearchLocation = CLLocationCoordinate2D(latitude: savedLatitude, longitude: savedLongitude)
        } else {
            self.savedSearchLocation = nil
        }
    }
    
    // MARK: - Premium Settings Management
    
    /// Resets premium-only settings when subscription status changes
    func resetPremiumOnlySettings() {
        // Reset showItemImagesByDefault if user doesn't have premium access
        if !SubscriptionManager.shared.canUseItemImages() && showItemImagesByDefault {
            showItemImagesByDefault = false
        }
        
        // Reset defaultItemCategory if it's not available for free users
        if !SubscriptionManager.shared.canUseItemCategory(defaultItemCategory) {
            defaultItemCategory = SubscriptionManager.shared.getAvailableItemCategories().first ?? .other
        }
        
        // Reset defaultUnit if it's not available for free users
        if let unitEnum = Unit(rawValue: defaultUnit), !SubscriptionManager.shared.canUseUnit(unitEnum) {
            defaultUnit = SubscriptionManager.shared.getAvailableUnits().first?.rawValue ?? ""
        }
    }
    
    /// Safely sets a premium-only setting with validation
    /// Returns true if the setting was successfully set, false if user doesn't have premium access
    func setPremiumSetting(_ setting: PremiumSetting, value: Bool) -> Bool {
        guard isSettingAvailable(setting) else {
            return false
        }
        
        switch setting {
        case .itemImages:
            showItemImagesByDefault = value
        case .locationReminders:
            // This would be handled by LocationManager
            break
        case .unlimitedNotifications:
            // This would be handled by NotificationManager
            break
        case .budgetTracking:
            // This would be handled by BudgetManager
            break
        case .dataSharing:
            // This would be handled by DataSharingManager
            break
        }
        
        return true
    }
    
    /// Checks if a setting is available based on current subscription status
    func isSettingAvailable(_ setting: PremiumSetting) -> Bool {
        switch setting {
        case .itemImages:
            return SubscriptionManager.shared.canUseItemImages()
        case .locationReminders:
            return SubscriptionManager.shared.canUseLocationReminders()
        case .unlimitedNotifications:
            return SubscriptionManager.shared.canUseUnlimitedNotifications()
        case .budgetTracking:
            return SubscriptionManager.shared.canUseBudgetTracking()
        case .dataSharing:
            return SubscriptionManager.shared.canUseDataSharing()
        }
    }
}

// MARK: - Premium Setting Types
enum PremiumSetting {
    case itemImages
    case locationReminders
    case unlimitedNotifications
    case budgetTracking
    case dataSharing
} 