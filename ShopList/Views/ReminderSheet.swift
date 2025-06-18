import SwiftUI
import SwiftData

struct ReminderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    let list: ShoppingList
    
    @State private var reminderDate = Date()
    @State private var isRecurring = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Daily Reminder", isOn: $isRecurring)
                } header: {
                    Text("Reminder Details")
                } footer: {
                    Text("Set a reminder for your shopping list")
                }
                
                Section {
                    Button("Schedule Reminder") {
                        scheduleReminder()
                    }
                    .disabled(!settingsManager.notificationsEnabled || !notificationManager.isAuthorized)
                } header: {
                    Text("Actions")
                }
                
                if !settingsManager.notificationsEnabled {
                    Section {
                        Text("Enable notifications in Settings to schedule reminders")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                } else if !notificationManager.isAuthorized {
                    Section {
                        Text("Please grant notification permissions in Settings")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Reminder Scheduled", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your reminder has been scheduled successfully!")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func scheduleReminder() {
        Task {
            if isRecurring {
                await notificationManager.scheduleRecurringReminder(for: list, at: reminderDate)
            } else {
                await notificationManager.scheduleShoppingListReminder(for: list, at: reminderDate)
            }
            
            await MainActor.run {
                showingSuccess = true
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