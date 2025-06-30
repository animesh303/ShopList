import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var settingsManager = UserSettingsManager.shared
    @State private var showingPermissionAlert = false
    
    var body: some View {
        ZStack {
            // Enhanced background with vibrant gradient
            DesignSystem.Colors.backgroundGradient
                .ignoresSafeArea()
            
            List {
                // Permission Status Section - Info Blue Gradient
                Section {
                    HStack {
                        Image(systemName: notificationManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(notificationManager.isAuthorized ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notification Permission")
                                .headlineStyle()
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Text(notificationManager.isAuthorized ? "Granted" : "Not Granted")
                                .captionStyle()
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        
                        Spacer()
                        
                        if !notificationManager.isAuthorized {
                            Button("Request") {
                                requestPermission()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(DesignSystem.Colors.info)
                        }
                    }
                } header: {
                    Text("Permission Status")
                        .foregroundColor(DesignSystem.Colors.primaryText)
                } footer: {
                    Text("Enable notifications to receive reminders for your shopping lists")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .listRowBackground(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.info.opacity(0.1),
                            DesignSystem.Colors.info.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                if settingsManager.notificationsEnabled && notificationManager.isAuthorized {
                    // Pending Notifications Section - Success Green Gradient
                    Section {
                        ForEach(notificationManager.pendingNotifications, id: \.identifier) { request in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(
                                            Circle()
                                                .fill(DesignSystem.Colors.success)
                                        )
                                        .shadow(
                                            color: DesignSystem.Colors.success.opacity(0.4),
                                            radius: 2,
                                            x: 0,
                                            y: 1
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(request.content.title)
                                            .headlineStyle()
                                            .foregroundColor(DesignSystem.Colors.primaryText)
                                        Text(request.content.body)
                                            .captionStyle()
                                            .foregroundColor(DesignSystem.Colors.secondaryText)
                                    }
                                    
                                    Spacer()
                                }
                                
                                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .font(.caption2)
                                            .foregroundColor(DesignSystem.Colors.info)
                                        Text("Scheduled for: \(formatDate(trigger.nextTriggerDate()))")
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(DesignSystem.Colors.info)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.Colors.success.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(DesignSystem.Colors.success.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .swipeActions {
                                Button("Cancel", role: .destructive) {
                                    notificationManager.cancelNotification(withIdentifier: request.identifier)
                                }
                            }
                        }
                        
                        if notificationManager.pendingNotifications.isEmpty {
                            HStack {
                                Image(systemName: "tray")
                                    .font(.title2)
                                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                                Text("No pending notifications")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                    } header: {
                        Text("Pending Notifications")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    } footer: {
                        Text("Swipe left to cancel notifications")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.success.opacity(0.1),
                                DesignSystem.Colors.success.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Actions Section - Warning Orange Gradient
                    Section {
                        Button(action: {
                            notificationManager.cancelAllNotifications()
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(DesignSystem.Colors.error)
                                    )
                                    .shadow(
                                        color: DesignSystem.Colors.error.opacity(0.4),
                                        radius: 2,
                                        x: 0,
                                        y: 1
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Cancel All Notifications")
                                        .headlineStyle()
                                        .foregroundColor(DesignSystem.Colors.error)
                                    Text("Remove all scheduled reminders")
                                        .captionStyle()
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.Colors.error.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(DesignSystem.Colors.error.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    } header: {
                        Text("Actions")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    } footer: {
                        Text("This action cannot be undone")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.warning)
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.warning.opacity(0.1),
                                DesignSystem.Colors.warning.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                
                if !settingsManager.notificationsEnabled {
                    // Disabled Notifications Section - Warning Yellow Gradient
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.warning)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notifications Disabled")
                                    .headlineStyle()
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                Text("Enable notifications in Settings to view and manage reminders")
                                    .captionStyle()
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(DesignSystem.Colors.warning.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(DesignSystem.Colors.warning.opacity(0.2), lineWidth: 1)
                                )
                        )
                    } header: {
                        Text("Status")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    } footer: {
                        Text("Go to Settings > Notifications > ShopList to enable")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.warning.opacity(0.1),
                                DesignSystem.Colors.warning.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .scrollContentBackground(.hidden)
            
            // Back Button FAB at bottom left
            VStack {
                Spacer()
                HStack {
                    VStack {
                        Spacer()
                        BackButtonFAB {
                            dismiss()
                        }
                    }
                    .padding(.leading, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                    
                    Spacer()
                }
            }
        }
        .enhancedNavigation(
            title: "Notifications",
            subtitle: "Manage notification preferences",
            icon: "bell.circle",
            style: .warning,
            showBanner: true
        )
        .refreshable {
            await notificationManager.getPendingNotifications()
        }
        .onAppear {
            Task {
                await notificationManager.getPendingNotifications()
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