import Foundation
import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
        notificationCenter.delegate = self
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
    
    func scheduleShoppingListReminder(for list: ShoppingList, at date: Date) async {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Shopping Reminder"
        content.body = "Don't forget to shop for: \(list.name)"
        content.sound = getNotificationSound()
        content.badge = 1
        content.categoryIdentifier = "SHOPPING_REMINDER"
        
        // Create date components for the reminder
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "shopping_reminder_\(list.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("Scheduled notification for list: \(list.name)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    func scheduleRecurringReminder(for list: ShoppingList, at time: Date, repeats: Bool = true) async {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Shopping List Reminder"
        content.body = "Time to review your shopping list: \(list.name)"
        content.sound = getNotificationSound()
        content.badge = 1
        content.categoryIdentifier = "RECURRING_REMINDER"
        
        // Create date components for daily reminder
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        
        let request = UNNotificationRequest(
            identifier: "recurring_reminder_\(list.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("Scheduled recurring notification for list: \(list.name)")
        } catch {
            print("Error scheduling recurring notification: \(error)")
        }
    }
    
    func scheduleItemReminder(for item: Item, in list: ShoppingList, at date: Date) async {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Item Reminder"
        content.body = "Don't forget to buy: \(item.name) for \(list.name)"
        content.sound = getNotificationSound()
        content.badge = 1
        content.categoryIdentifier = "ITEM_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "item_reminder_\(item.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("Scheduled item notification: \(item.name)")
        } catch {
            print("Error scheduling item notification: \(error)")
        }
    }
    
    // MARK: - Notification Management
    
    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        await MainActor.run {
            self.pendingNotifications = requests
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
        
        notificationCenter.setNotificationCategories([
            shoppingReminderCategory,
            recurringReminderCategory,
            itemReminderCategory
        ])
    }
}

// MARK: - Notification Delegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.actionIdentifier
        
        switch identifier {
        case "VIEW_LIST":
            // Handle view list action
            print("User tapped View List")
        case "MARK_COMPLETE":
            // Handle mark complete action
            print("User tapped Mark Complete")
        case "SNOOZE":
            // Handle snooze action
            print("User tapped Snooze")
        default:
            break
        }
        
        completionHandler()
    }
} 