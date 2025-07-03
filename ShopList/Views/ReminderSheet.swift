import SwiftUI
import SwiftData

struct ReminderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    let list: ShoppingList
    
    @State private var reminderDate = Date()
    @State private var isRecurring = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var existingReminder: UNNotificationRequest?
    @State private var isLoading = true
    
    // MARK: - Computed Properties
    private var hasExistingReminder: Bool {
        existingReminder != nil
    }
    
    private var datePickerCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Header with icon
            HStack {
                Image(systemName: "clock")
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.primary)
                Text("Reminder Time")
                    .font(DesignSystem.Typography.subheadlineBold)
                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                Spacer()
            }
            
            // Date picker with better styling
            DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .labelsHidden()
                .accentColor(DesignSystem.Colors.primary)
                .padding(DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(Color(.systemBackground).opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.cardBackground(for: list.category))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(list.category.color.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    private var recurringToggleCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Header with icon
            HStack {
                Image(systemName: "repeat")
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.primary)
                Text("Daily Reminder")
                    .font(DesignSystem.Typography.subheadlineBold)
                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                Spacer()
                
                Toggle("", isOn: $isRecurring)
                    .tint(DesignSystem.Colors.primary)
                    .scaleEffect(0.9)
            }
            
            if isRecurring {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.info)
                    Text("This reminder will repeat every day at the selected time")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 4)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(DesignSystem.Colors.info.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .stroke(DesignSystem.Colors.info.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.cardBackground(for: list.category))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(list.category.color.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    private var scheduleButton: some View {
        Button(action: scheduleReminder) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: hasExistingReminder ? "arrow.clockwise" : "bell.badge")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(hasExistingReminder ? "Update Reminder" : "Schedule Reminder")
                    .font(DesignSystem.Typography.bodyBold)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(buttonBackgroundColor)
            )
            .foregroundColor(.white)
            .shadow(
                color: !settingsManager.notificationsEnabled || !notificationManager.isAuthorized 
                    ? Color.clear 
                    : DesignSystem.Colors.primary.opacity(0.3),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .disabled(!settingsManager.notificationsEnabled || !notificationManager.isAuthorized)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    private var buttonBackgroundColor: LinearGradient {
        if !settingsManager.notificationsEnabled || !notificationManager.isAuthorized {
            return LinearGradient(
                colors: [DesignSystem.Colors.adaptiveSecondaryTextColor().opacity(0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return DesignSystem.Colors.primaryButtonGradient
        }
    }
    
    private var existingReminderCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header with icon
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.success)
                Text("Current Reminder")
                    .font(DesignSystem.Typography.subheadlineBold)
                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                Spacer()
            }
            
            // Reminder details
            if let reminder = existingReminder {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.info)
                        Text("Scheduled for: \(formatReminderDate(reminder))")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                    }
                    
                    HStack {
                        Image(systemName: reminder.identifier.contains("recurring") ? "repeat" : "calendar")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.info)
                        Text(reminder.identifier.contains("recurring") ? "Daily recurring reminder" : "One-time reminder")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(DesignSystem.Colors.success.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .stroke(DesignSystem.Colors.success.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Cancel button
            Button(action: cancelExistingReminder) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "xmark.circle")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Cancel Reminder")
                        .font(DesignSystem.Typography.bodyBold)
                }
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(DesignSystem.Colors.error.opacity(0.8))
                )
                .foregroundColor(.white)
                .shadow(
                    color: DesignSystem.Colors.error.opacity(0.3),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.cardBackground(for: list.category))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(list.category.color.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    private var notificationDisabledCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header with icon
            HStack {
                Image(systemName: "bell.slash")
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.warning)
                Text("Notifications Disabled")
                    .font(DesignSystem.Typography.subheadlineBold)
                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                Spacer()
            }
            
            // Description with better styling
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.warning)
                    .padding(.top, 2)
                
                Text("Enable notifications in Settings to schedule reminders")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.warning.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(DesignSystem.Colors.warning.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    private var permissionRequiredCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header with icon
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.warning)
                Text("Permission Required")
                    .font(DesignSystem.Typography.subheadlineBold)
                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                Spacer()
            }
            
            // Description with better styling
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "lock")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.warning)
                    .padding(.top, 2)
                
                Text("Please grant notification permissions in Settings")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.warning.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(DesignSystem.Colors.warning.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading reminder...")
                        .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                } else {
                    Form {
                        // Existing Reminder Section
                        if hasExistingReminder {
                            Section {
                                existingReminderCard
                            } header: {
                                Text("Current Reminder")
                                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                            }
                        }
                        
                        // Reminder Details Section
                        Section {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                datePickerCard
                                recurringToggleCard
                            }
                        } header: {
                            Text(hasExistingReminder ? "Update Reminder" : "Reminder Details")
                                .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                        } footer: {
                            Text(hasExistingReminder ? "Modify your existing reminder settings" : "Set a reminder for your shopping list")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.adaptiveTextColor().opacity(0.8))
                        }
                        
                        // Actions Section
                        Section {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                scheduleButton
                            }
                        } header: {
                            Text("Actions")
                                .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                        }
                        
                        // Notification Status Section
                        if !settingsManager.notificationsEnabled {
                            Section {
                                notificationDisabledCard
                            } header: {
                                Text("Notification Status")
                                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                            }
                        } else if !notificationManager.isAuthorized {
                            Section {
                                permissionRequiredCard
                            } header: {
                                Text("Notification Status")
                                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listSectionSpacing(0)
                    .listRowSpacing(0)
                    .enhancedNavigation(
                        title: hasExistingReminder ? "Edit Reminder" : "Set Reminder",
                        subtitle: "for \(list.name)",
                        icon: "bell.badge",
                        style: .custom(DesignSystem.Colors.themeAwareCategoryGradient(for: list.category, colorScheme: colorScheme)),
                        showBanner: true
                    )
                }
                
                // Enhanced Floating Action Button (FAB) for Cancel
                VStack {
                    Spacer()
                    HStack {
                        // Cancel Button FAB at bottom left
                        VStack {
                            Spacer()
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(
                                        DesignSystem.Colors.error.opacity(0.8)
                                    )
                                    .clipShape(Circle())
                                    .shadow(
                                        color: DesignSystem.Colors.error.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                        }
                        .padding(.leading, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                        
                        Spacer()
                    }
                }
            }
        }
        .alert("Reminder Scheduled", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(hasExistingReminder ? "Your reminder has been updated successfully!" : "Your reminder has been scheduled successfully!")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadExistingReminder()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadExistingReminder() {
        Task {
            await notificationManager.getPendingNotifications()
            
            await MainActor.run {
                // Find existing reminder for this list
                existingReminder = notificationManager.pendingNotifications.first { request in
                    if let listId = request.content.userInfo["listId"] as? String {
                        return listId == list.id.uuidString
                    }
                    return false
                }
                
                // If found, populate the form with existing data
                if let reminder = existingReminder {
                    populateFormWithExistingReminder(reminder)
                } else {
                    // Set default time from settings
                    reminderDate = settingsManager.defaultReminderTime
                }
                
                isLoading = false
            }
        }
    }
    
    private func populateFormWithExistingReminder(_ reminder: UNNotificationRequest) {
        // Determine if it's recurring
        isRecurring = reminder.identifier.contains("recurring")
        
        // Extract date from trigger
        if let trigger = reminder.trigger as? UNCalendarNotificationTrigger {
            if let nextTriggerDate = trigger.nextTriggerDate() {
                reminderDate = nextTriggerDate
            }
        }
    }
    
    private func formatReminderDate(_ reminder: UNNotificationRequest) -> String {
        if let trigger = reminder.trigger as? UNCalendarNotificationTrigger,
           let nextTriggerDate = trigger.nextTriggerDate() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: nextTriggerDate)
        }
        return "Unknown"
    }
    
    private func cancelExistingReminder() {
        guard let reminder = existingReminder else { return }
        
        Task {
            notificationManager.cancelNotification(withIdentifier: reminder.identifier)
            
            await MainActor.run {
                existingReminder = nil
                showingSuccess = true
            }
        }
    }
    
    private func scheduleReminder() {
        Task {
            // Cancel existing reminder if any
            if let existing = existingReminder {
                notificationManager.cancelNotification(withIdentifier: existing.identifier)
            }
            
            let success: Bool
            
            if isRecurring {
                success = await notificationManager.scheduleRecurringReminder(for: list, at: reminderDate, frequency: .daily)
            } else {
                success = await notificationManager.scheduleShoppingReminder(for: list, at: reminderDate)
            }
            
            await MainActor.run {
                if success {
                    showingSuccess = true
                } else {
                    errorMessage = "Failed to schedule reminder. Please check your notification settings."
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    let list = ShoppingList(name: "Test List", category: .groceries)
    
    ReminderSheet(list: list)
        .modelContainer(container)
} 