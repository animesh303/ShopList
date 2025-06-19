import SwiftUI
import CoreLocation

struct SettingsView: View {
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $settingsManager.appearance) {
                        ForEach(Appearance.allCases) { appearance in
                            Text(appearance.rawValue)
                                .tag(appearance)
                        }
                    }
                    
                    Picker("List View Style", selection: $settingsManager.defaultListViewStyle) {
                        ForEach(ListViewStyle.allCases) { style in
                            Text(style.rawValue)
                                .tag(style)
                        }
                    }
                    
                    Toggle("Show Completed Items", isOn: $settingsManager.showCompletedItemsByDefault)
                }
                
                Section(header: Text("Currency")) {
                    Picker("Currency", selection: $settingsManager.currency) {
                        ForEach(Currency.allCases) { currency in
                            Text("\(currency.symbol) \(currency.name)")
                                .tag(currency)
                        }
                    }
                }
                
                Section(header: Text("Number Format")) {
                    Picker("Decimal Separator", selection: $settingsManager.numberFormat) {
                        ForEach(NumberFormat.allCases) { format in
                            Text(format.rawValue)
                                .tag(format)
                        }
                    }
                }
                
                Section(header: Text("Item Display")) {
                    Toggle("Show Item Images", isOn: $settingsManager.showItemImagesByDefault)
                    Toggle("Show Item Notes", isOn: $settingsManager.showItemNotesByDefault)
                    Picker("Item View Style", selection: $settingsManager.defaultItemViewStyle) {
                        ForEach(ItemViewStyle.allCases) { style in
                            Text(style.rawValue)
                                .tag(style)
                        }
                    }
                }
                
                Section(header: Text("Defaults")) {
                    Picker("Default List Category", selection: $settingsManager.defaultListCategory) {
                        ForEach(ListCategory.allCases.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    
                    Picker("Default Item Priority", selection: $settingsManager.defaultItemPriority) {
                        ForEach(ItemPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName)
                                .tag(priority)
                        }
                    }
                    
                    Picker("Default Unit", selection: $settingsManager.defaultUnit) {
                        ForEach(Unit.allUnits) { unit in
                            Text(unit.displayName)
                                .tag(unit.rawValue)
                        }
                    }
                    
                    Picker("Default Sort Order", selection: $settingsManager.defaultListSortOrder) {
                        ForEach(ListSortOrder.allCases) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $settingsManager.notificationsEnabled)
                    
                    if !notificationManager.isAuthorized && settingsManager.notificationsEnabled {
                        Text("Please enable notifications in Settings to receive reminders")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    if settingsManager.notificationsEnabled {
                        DatePicker("Default Reminder Time",
                                 selection: $settingsManager.defaultReminderTime,
                                 displayedComponents: .hourAndMinute)
                        
                        Picker("Notification Sound", selection: $settingsManager.notificationSound) {
                            ForEach(NotificationSound.allCases) { sound in
                                Text(sound.rawValue)
                                    .tag(sound)
                            }
                        }
                        
                        NavigationLink("Manage Notifications") {
                            NotificationSettingsView()
                        }
                        
                        if notificationManager.isAuthorized {
                            Text("Notifications are enabled and ready")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section(header: Text("Location Reminders")) {
                    HStack {
                        Image(systemName: locationManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(locationManager.isAuthorized ? .green : .red)
                        
                        VStack(alignment: .leading) {
                            Text("Location Access")
                                .font(.headline)
                            Text(getLocationPermissionStatus())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !locationManager.isAuthorized {
                            Button("Request") {
                                locationManager.requestLocationPermission()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    if locationManager.isAuthorized {
                        NavigationLink("Manage Location Reminders") {
                            LocationManagementView()
                        }
                        
                        let status = CLLocationManager().authorizationStatus
                        if status == .authorizedAlways {
                            Text("Location reminders are enabled")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("Background monitoring requires 'Always' location access")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    } else {
                        Text("Enable location access to set up store-based reminders")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func getLocationPermissionStatus() -> String {
        switch CLLocationManager().authorizationStatus {
        case .notDetermined:
            return "Location permission not determined"
        case .restricted:
            return "Location permission restricted"
        case .denied:
            return "Location permission denied"
        case .authorizedWhenInUse:
            return "Location permission authorized when in use"
        case .authorizedAlways:
            return "Location permission authorized always"
        @unknown default:
            return "Unknown location permission status"
        }
    }
}

#Preview {
    SettingsView()
} 