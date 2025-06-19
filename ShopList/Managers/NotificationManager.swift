import Foundation
import UserNotifications
import SwiftUI
import SwiftData

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
        
        // Add list information to user info
        content.userInfo = [
            "listId": list.id.uuidString,
            "listName": list.name,
            "notificationType": "shopping_reminder"
        ]
        
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
        
        // Add list information to user info
        content.userInfo = [
            "listId": list.id.uuidString,
            "listName": list.name,
            "notificationType": "recurring_reminder"
        ]
        
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
        
        // Add list and item information to user info
        content.userInfo = [
            "listId": list.id.uuidString,
            "listName": list.name,
            "itemId": item.id.uuidString,
            "itemName": item.name,
            "notificationType": "item_reminder"
        ]
        
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
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let identifier = response.actionIdentifier
        
        // Handle notification tap to open list
        if identifier == UNNotificationDefaultActionIdentifier {
            Task { @MainActor in
                await self.handleNotificationTap(userInfo: userInfo)
            }
        }
        
        switch identifier {
        case "VIEW_LIST":
            Task { @MainActor in
                await self.handleNotificationTap(userInfo: userInfo)
            }
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
    
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) async {
        guard let listIdString = userInfo["listId"] as? String,
              let listId = UUID(uuidString: listIdString) else {
            print("Invalid list ID in notification")
            return
        }
        
        // Find the list and set it to open
        await findAndSetListToOpen(listId: listId)
    }
} 