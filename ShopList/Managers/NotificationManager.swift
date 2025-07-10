import Foundation
import UserNotifications
import SwiftUI
import SwiftData
import CoreLocation

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    private var modelContext: ModelContext?
    
    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    @Published var listToOpen: ShoppingList?
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
        notificationCenter.delegate = self
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func clearListToOpen() {
        listToOpen = nil
    }
    
    // MARK: - Authorization
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleShoppingReminder(for list: ShoppingList, at date: Date) async -> Bool {
        // Check subscription limits
        let subscriptionManager = SubscriptionManager.shared
        if !subscriptionManager.canSendNotification() {
            print("Notification limit reached for free user")
            return false
        }
        
        guard isAuthorized else {
            print("Notifications not authorized")
            return false
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Shopping Reminder"
        content.body = "Don't forget to check your '\(list.name)' list!"
        content.sound = getNotificationSound()
        content.categoryIdentifier = "SHOPPING_REMINDER"
        content.userInfo = ["listId": list.id.uuidString]
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "shopping_reminder_\(list.id.uuidString)_\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            
            // Increment notification count for free users
            subscriptionManager.incrementNotificationCount()
            
            print("Shopping reminder scheduled for \(date)")
            return true
        } catch {
            print("Failed to schedule shopping reminder: \(error)")
            return false
        }
    }
    
    func scheduleRecurringReminder(for list: ShoppingList, at time: Date, frequency: RecurringFrequency) async -> Bool {
        // Check subscription limits
        let subscriptionManager = SubscriptionManager.shared
        if !subscriptionManager.canSendNotification() {
            print("Notification limit reached for free user")
            return false
        }
        
        guard isAuthorized else {
            print("Notifications not authorized")
            return false
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Shopping Reminder"
        content.body = "Time to check your '\(list.name)' list!"
        content.sound = getNotificationSound()
        content.categoryIdentifier = "RECURRING_REMINDER"
        content.userInfo = ["listId": list.id.uuidString]
        
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "recurring_reminder_\(list.id.uuidString)_\(frequency.rawValue)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            
            // Increment notification count for free users
            subscriptionManager.incrementNotificationCount()
            
            print("Recurring reminder scheduled for \(time)")
            return true
        } catch {
            print("Failed to schedule recurring reminder: \(error)")
            return false
        }
    }
    
    func scheduleItemReminder(for item: Item, in list: ShoppingList, at date: Date) async -> Bool {
        // Check subscription limits
        let subscriptionManager = SubscriptionManager.shared
        if !subscriptionManager.canSendNotification() {
            print("Notification limit reached for free user")
            return false
        }
        
        guard isAuthorized else {
            print("Notifications not authorized")
            return false
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Item Reminder"
        content.body = "Don't forget to buy '\(item.name)' for your '\(list.name)' list!"
        content.sound = getNotificationSound()
        content.categoryIdentifier = "ITEM_REMINDER"
        content.userInfo = ["listId": list.id.uuidString, "itemId": item.id.uuidString]
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "item_reminder_\(item.id.uuidString)_\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            
            // Increment notification count for free users
            subscriptionManager.incrementNotificationCount()
            
            print("Item reminder scheduled for \(date)")
            return true
        } catch {
            print("Failed to schedule item reminder: \(error)")
            return false
        }
    }
    
    func scheduleLocationReminder(for list: ShoppingList, at location: CLLocationCoordinate2D, radius: Double, message: String) async -> Bool {
        // Check subscription limits
        let subscriptionManager = SubscriptionManager.shared
        if !subscriptionManager.canUseLocationReminders() {
            print("Location reminders require Premium subscription")
            return false
        }
        
        if !subscriptionManager.canSendNotification() {
            print("Notification limit reached for free user")
            return false
        }
        
        guard isAuthorized else {
            print("Notifications not authorized")
            return false
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Location Reminder"
        content.body = message.isEmpty ? "You're near a store for your '\(list.name)' list!" : message
        content.sound = getNotificationSound()
        content.categoryIdentifier = "LOCATION_REMINDER"
        content.userInfo = ["listId": list.id.uuidString]
        
        let region = CLCircularRegion(
            center: location,
            radius: radius,
            identifier: "location_reminder_\(list.id.uuidString)"
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "location_reminder_\(list.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            
            // Increment notification count for free users
            subscriptionManager.incrementNotificationCount()
            
            print("Location reminder scheduled for \(location)")
            return true
        } catch {
            print("Failed to schedule location reminder: \(error)")
            return false
        }
    }
    
    // MARK: - Notification Management
    
    func getPendingNotifications() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        await MainActor.run {
            self.pendingNotifications = requests
        }
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        Task {
            await getPendingNotifications()
        }
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        Task {
            await getPendingNotifications()
        }
    }
    
    // MARK: - Helper Methods
    
    private func getNotificationSound() -> UNNotificationSound? {
        let settingsManager = UserSettingsManager.shared
        
        switch settingsManager.notificationSound {
        case .defaultSound:
            return .default
        case .gentle:
            return UNNotificationSound(named: UNNotificationSoundName("gentle.wav"))
        case .urgent:
            return UNNotificationSound(named: UNNotificationSoundName("urgent.wav"))
        case .none:
            return nil
        }
    }
    
    // MARK: - Settings Integration
    
    func setupNotificationCategories() {
        let shoppingReminderCategory = UNNotificationCategory(
            identifier: "SHOPPING_REMINDER",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_LIST",
                    title: "View List",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "MARK_COMPLETE",
                    title: "Mark Complete",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let recurringReminderCategory = UNNotificationCategory(
            identifier: "RECURRING_REMINDER",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_LIST",
                    title: "View List",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "SNOOZE",
                    title: "Snooze 1 Hour",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let itemReminderCategory = UNNotificationCategory(
            identifier: "ITEM_REMINDER",
            actions: [
                UNNotificationAction(
                    identifier: "MARK_COMPLETE",
                    title: "Mark Complete",
                    options: []
                ),
                UNNotificationAction(
                    identifier: "VIEW_LIST",
                    title: "View List",
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let locationReminderCategory = UNNotificationCategory(
            identifier: "LOCATION_REMINDER",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_LIST",
                    title: "View List",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "SNOOZE",
                    title: "Snooze 30 Min",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([
            shoppingReminderCategory,
            recurringReminderCategory,
            itemReminderCategory,
            locationReminderCategory
        ])
    }
    
    private func findAndSetListToOpen(listId: UUID) async {
        guard let modelContext = modelContext else {
            print("Model context not set")
            return
        }
        
        do {
            let descriptor = FetchDescriptor<ShoppingList>(
                predicate: #Predicate<ShoppingList> { $0.id == listId }
            )
            
            if let list = try modelContext.fetch(descriptor).first {
                self.listToOpen = list
                print("Found and set list to open: \(list.name)")
            } else {
                print("List not found with ID: \(listId)")
            }
        } catch {
            print("Error finding list: \(error)")
        }
    }
}

// MARK: - Notification Delegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Get the user's preferred banner style
        let bannerStyle = UserDefaults.standard.string(forKey: "notificationBannerStyle") ?? NotificationBannerStyle.banner.rawValue
        let userBannerStyle = NotificationBannerStyle(rawValue: bannerStyle) ?? .banner
        
        var presentationOptions: UNNotificationPresentationOptions = []
        
        switch userBannerStyle {
        case .banner:
            presentationOptions = [.banner, .sound, .badge]
        case .alert:
            presentationOptions = [.alert, .sound, .badge]
        case .none:
            presentationOptions = [.sound, .badge] // Still show sound and badge but no visual
        }
        
        completionHandler(presentationOptions)
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let listIdString = userInfo["listId"] as? String,
           let listId = UUID(uuidString: listIdString) {
            Task { @MainActor in
                await self.findAndSetListToOpen(listId: listId)
            }
        }
        
        completionHandler()
    }
}

// MARK: - Supporting Types

enum RecurringFrequency: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        }
    }
} 