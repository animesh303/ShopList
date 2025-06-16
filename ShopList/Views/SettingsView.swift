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
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
} 