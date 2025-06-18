import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = UserSettingsManager.shared
    
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
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
} 