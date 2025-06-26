import SwiftUI
import CoreLocation

struct LocationManagementView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var showingLocationPermissionAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: locationManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(locationManager.isAuthorized ? .green : .red)
                        
                        VStack(alignment: .leading) {
                            Text("Location Permission")
                                .font(.headline)
                            Text(getPermissionStatusText())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !locationManager.isAuthorized {
                            Button("Request") {
                                requestLocationPermission()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } header: {
                    Text("Permission Status")
                }
                
                if locationManager.locationReminders.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "location.slash")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            Text("No Location Reminders")
                                .font(.headline)
                            
                            Text("Set up location-based reminders for your shopping lists to get notified when you're near stores.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                } else {
                    Section {
                        ForEach(locationManager.locationReminders, id: \.id) { reminder in
                            LocationReminderRow(reminder: reminder)
                        }
                        .onDelete(perform: deleteReminders)
                    } header: {
                        Text("Active Reminders")
                    } footer: {
                        Text("You'll receive notifications when you enter these locations")
                    }
                }
                
                if !locationManager.locationReminders.isEmpty {
                    Section {
                        Button("Clear All Reminders", role: .destructive) {
                            clearAllReminders()
                        }
                    } header: {
                        Text("Actions")
                    }
                }
            }
            .enhancedNavigation(
                title: "Location",
                subtitle: "Manage location permissions",
                icon: "location.circle",
                style: .info,
                showBanner: true
            )
            .refreshable {
                // Refresh location reminders
                locationManager.loadReminders()
            }
            .alert("Location Permission Required", isPresented: $showingLocationPermissionAlert) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Location-based reminders require 'Always' location access to work in the background. Please enable this in Settings.")
            }
        }
    }
    
    private func requestLocationPermission() {
        locationManager.requestLocationPermission()
        
        // Check if permission was denied
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let status = CLLocationManager().authorizationStatus
            if status == .denied || status == .restricted {
                showingLocationPermissionAlert = true
            }
        }
    }
    
    private func deleteReminders(at offsets: IndexSet) {
        for index in offsets {
            let reminder = locationManager.locationReminders[index]
            locationManager.removeLocationReminder(reminder)
        }
    }
    
    private func clearAllReminders() {
        locationManager.clearAllLocationReminders()
    }
    
    private func getPermissionStatusText() -> String {
        let status = CLLocationManager().authorizationStatus
        switch status {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedWhenInUse:
            return "When In Use (Background monitoring disabled)"
        case .authorizedAlways:
            return "Always (Background monitoring enabled)"
        @unknown default:
            return "Unknown"
        }
    }
}

struct LocationReminderRow: View {
    let reminder: LocationReminder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Shopping List Reminder")
                        .font(.headline)
                    
                    Text("Radius: \(Int(reminder.radius)) meters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "bell.fill")
                    .foregroundColor(.blue)
            }
            
            Text(reminder.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Location:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(reminder.location.latitude, specifier: "%.4f"), \(reminder.location.longitude, specifier: "%.4f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 