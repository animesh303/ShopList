import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var locationReminders: [LocationReminder] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        loadReminders()
    }
    
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    func addLocationReminder(for list: ShoppingList, at location: CLLocationCoordinate2D, radius: Double, message: String) {
        let reminder = LocationReminder(
            listId: list.id,
            location: location,
            radius: radius,
            message: message
        )
        
        locationReminders.append(reminder)
        saveReminders()
        
        // Start monitoring the region
        let region = CLCircularRegion(
            center: location,
            radius: radius,
            identifier: reminder.id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        locationManager.startMonitoring(for: region)
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "LocationReminders"),
           let reminders = try? JSONDecoder().decode([LocationReminder].self, from: data) {
            locationReminders = reminders
        }
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(locationReminders) {
            UserDefaults.standard.set(encoded, forKey: "LocationReminders")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let reminder = locationReminders.first(where: { $0.id.uuidString == region.identifier }) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Shopping List Reminder"
        content.body = reminder.message
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region: \(error)")
    }
} 