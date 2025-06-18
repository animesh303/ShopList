import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var settingsManager = UserSettingsManager.shared
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: notificationManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                        
                        VStack(alignment: .leading) {
                            Text("Notification Permission")
                                .font(.headline)
                            Text(notificationManager.isAuthorized ? "Granted" : "Not Granted")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !notificationManager.isAuthorized {
                            Button("Request") {
                                requestPermission()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } header: {
                    Text("Permission Status")
                }
                
                if settingsManager.notificationsEnabled && notificationManager.isAuthorized {
                    Section {
                        ForEach(notificationManager.pendingNotifications, id: \.identifier) { request in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(request.content.title)
                                    .font(.headline)
                                Text(request.content.body)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                                    Text("Scheduled for: \(formatDate(trigger.nextTriggerDate()))")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                            .swipeActions {
                                Button("Cancel", role: .destructive) {
                                    notificationManager.cancelNotification(withIdentifier: request.identifier)
                                }
                            }
                        }
                        
                        if notificationManager.pendingNotifications.isEmpty {
                            Text("No pending notifications")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    } header: {
                        Text("Pending Notifications")
                    } footer: {
                        Text("Swipe left to cancel notifications")
                    }
                    
                    Section {
                        Button("Cancel All Notifications", role: .destructive) {
                            notificationManager.cancelAllNotifications()
                        }
                    } header: {
                        Text("Actions")
                    }
                }
                
                if !settingsManager.notificationsEnabled {
                    Section {
                        Text("Enable notifications in Settings to view and manage reminders")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Notification Settings")
            .refreshable {
                await notificationManager.getPendingNotifications()
            }
            .onAppear {
                Task {
                    await notificationManager.getPendingNotifications()
                }
            }
        }
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications in Settings to use this feature.")
        }
    }
    
    private func requestPermission() {
        Task {
            let granted = await notificationManager.requestNotificationPermission()
            if !granted {
                await MainActor.run {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NotificationSettingsView()
} 