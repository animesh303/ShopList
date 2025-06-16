import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Currency")) {
                    Picker("Select Currency", selection: $settingsManager.currency) {
                        ForEach(Currency.allCases) { currency in
                            Text("\(currency.symbol) - \(currency.name)")
                                .tag(currency)
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