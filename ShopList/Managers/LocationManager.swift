import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var locationReminders: [LocationReminder] = []
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        
        checkAuthorizationStatus()
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
    
    func checkAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        DispatchQueue.main.async {
            self.isAuthorized = status == .authorizedAlways || status == .authorizedWhenInUse
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
        
        // Only start monitoring if we have proper authorization
        if locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startMonitoring(for: region)
        } else {
            print("Cannot start region monitoring: requires 'Always' location authorization")
        }
    }
    
    func removeLocationReminder(_ reminder: LocationReminder) {
        // Stop monitoring the region
        locationManager.stopMonitoring(for: CLCircularRegion(
            center: reminder.location,
            radius: reminder.radius,
            identifier: reminder.id.uuidString
        ))
        
        // Remove from array
        locationReminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    func clearAllLocationReminders() {
        // Stop monitoring all regions
        for reminder in locationReminders {
            locationManager.stopMonitoring(for: CLCircularRegion(
                center: reminder.location,
                radius: reminder.radius,
                identifier: reminder.id.uuidString
            ))
        }
        
        // Clear array
        locationReminders.removeAll()
        saveReminders()
    }
    
    func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "LocationReminders"),
           let reminders = try? JSONDecoder().decode([LocationReminder].self, from: data) {
            locationReminders = reminders
            
            // Only restart monitoring if we have proper authorization
            if locationManager.authorizationStatus == .authorizedAlways {
                for reminder in reminders {
                    let region = CLCircularRegion(
                        center: reminder.location,
                        radius: reminder.radius,
                        identifier: reminder.id.uuidString
                    )
                    region.notifyOnEntry = true
                    region.notifyOnExit = false
                    locationManager.startMonitoring(for: region)
                }
            } else {
                print("Cannot restore region monitoring: requires 'Always' location authorization")
            }
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
        content.badge = 1
        content.categoryIdentifier = "LOCATION_REMINDER"
        
        // Add list information to user info
        content.userInfo = [
            "listId": reminder.listId.uuidString,
            "reminderId": reminder.id.uuidString,
            "notificationType": "location_reminder"
        ]
        
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.isAuthorized = status == .authorizedAlways || status == .authorizedWhenInUse
            
            // If authorization changed to 'Always', restart monitoring for existing reminders
            if status == .authorizedAlways {
                self.restartMonitoringForExistingReminders()
            }
        }
    }
    
    private func restartMonitoringForExistingReminders() {
        for reminder in locationReminders {
            let region = CLCircularRegion(
                center: reminder.location,
                radius: reminder.radius,
                identifier: reminder.id.uuidString
            )
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
        }
    }
} 