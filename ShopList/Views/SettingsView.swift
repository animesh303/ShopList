import SwiftUI
import CoreLocation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingPremiumUpgrade = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                Form {
                    // Subscription Section
                    Section {
                        HStack {
                            Image(systemName: subscriptionManager.currentTier.icon)
                                .font(.title2)
                                .foregroundColor(subscriptionManager.currentTier.color)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Plan")
                                    .font(.headline)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                Text(subscriptionManager.currentTier.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                            
                            Spacer()
                            
                            if !subscriptionManager.isPremium {
                                Button("Upgrade") {
                                    showingPremiumUpgrade = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.orange)
                            }
                        }
                        
                        if !subscriptionManager.isPremium {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Free Plan Limits:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                let usage = subscriptionManager.getFreeTierUsage()
                                
                                HStack {
                                    Image(systemName: "list.bullet")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                    Text("\(usage.lists)/\(usage.maxLists) lists")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(DesignSystem.Colors.accent1)
                                    Text("\(usage.notifications)/\(usage.maxNotifications) daily notifications")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(DesignSystem.Colors.accent2)
                                    Text("3 basic categories only")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                            }
                            .padding(.vertical, 8)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Premium Features:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                ForEach(Array(PremiumFeature.allCases.prefix(6))) { feature in
                                    HStack {
                                        Image(systemName: feature.icon)
                                            .foregroundColor(DesignSystem.Colors.accent1)
                                        Text(feature.rawValue)
                                            .font(.caption)
                                            .foregroundColor(DesignSystem.Colors.secondaryText)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    } header: {
                        Text("Subscription")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                    
                    Section(header: Text("Appearance").foregroundColor(DesignSystem.Colors.primaryText)) {
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
                    
                    Section(header: Text("Currency").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Picker("Currency", selection: $settingsManager.currency) {
                            ForEach(Currency.allCases) { currency in
                                Text("\(currency.symbol) \(currency.name)")
                                    .tag(currency)
                            }
                        }
                    }
                    
                    Section(header: Text("Number Format").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Picker("Decimal Separator", selection: $settingsManager.numberFormat) {
                            ForEach(NumberFormat.allCases) { format in
                                Text(format.rawValue)
                                    .tag(format)
                            }
                        }
                    }
                    
                    Section(header: Text("Item Display").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Toggle("Show Item Images", isOn: $settingsManager.showItemImagesByDefault)
                            .disabled(!subscriptionManager.canUseItemImages())
                        
                        if !subscriptionManager.canUseItemImages() {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("Premium feature")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                        }
                        
                        Toggle("Show Item Notes", isOn: $settingsManager.showItemNotesByDefault)
                        Picker("Item View Style", selection: $settingsManager.defaultItemViewStyle) {
                            ForEach(ItemViewStyle.allCases) { style in
                                Text(style.rawValue)
                                    .tag(style)
                            }
                        }
                    }
                    
                    Section(header: Text("Defaults").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Picker("Default List Category", selection: $settingsManager.defaultListCategory) {
                            ForEach(subscriptionManager.getAvailableCategories().sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
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
                    
                    Section(header: Text("Notifications").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Toggle("Enable Notifications", isOn: $settingsManager.notificationsEnabled)
                        
                        if !notificationManager.isAuthorized && settingsManager.notificationsEnabled {
                            Text("Please enable notifications in Settings to receive reminders")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.warning)
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
                                    .foregroundColor(DesignSystem.Colors.success)
                            }
                        }
                        
                        if !subscriptionManager.canUseUnlimitedNotifications() {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("Free users limited to \(subscriptionManager.getNotificationLimit()) notifications per day")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                        }
                    }
                    
                    Section(header: Text("Location Reminders").foregroundColor(DesignSystem.Colors.primaryText)) {
                        if !subscriptionManager.canUseLocationReminders() {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                VStack(alignment: .leading) {
                                    Text("Premium Feature")
                                        .font(.headline)
                                    Text("Upgrade to Premium for location-based reminders")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                Spacer()
                                Button("Upgrade") {
                                    showingPremiumUpgrade = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.orange)
                            }
                        } else {
                            HStack {
                                Image(systemName: locationManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(locationManager.isAuthorized ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                                
                                VStack(alignment: .leading) {
                                    Text("Location Access")
                                        .font(.headline)
                                    Text(getLocationPermissionStatus())
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                
                                Spacer()
                                
                                if !locationManager.isAuthorized {
                                    Button("Request") {
                                        locationManager.requestLocationPermission()
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(DesignSystem.Colors.primary)
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
                                        .foregroundColor(DesignSystem.Colors.success)
                                } else {
                                    Text("Background monitoring requires 'Always' location access")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.warning)
                                }
                            } else {
                                Text("Enable location access to set up store-based reminders")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.warning)
                            }
                        }
                    }
                    
                    Section(header: Text("Location Search").foregroundColor(DesignSystem.Colors.primaryText)) {
                        HStack {
                            Image(systemName: settingsManager.restrictSearchToLocality ? "location.fill" : "location.slash")
                                .foregroundColor(settingsManager.restrictSearchToLocality ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText)
                            
                            VStack(alignment: .leading) {
                                Text("Search Restrictions")
                                    .font(.headline)
                                Text(settingsManager.restrictSearchToLocality ? "Search limited to local area" : "Search not restricted")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                            
                            Spacer()
                            
                            NavigationLink("Configure") {
                                LocationSearchSettingsView()
                            }
                        }
                        
                        if settingsManager.restrictSearchToLocality {
                            HStack {
                                Image(systemName: "circle.dashed")
                                    .foregroundColor(DesignSystem.Colors.info)
                                Text("Search radius: \(Int(settingsManager.searchRadius / 1000)) km")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                        }
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
                title: "Settings",
                subtitle: "Customize your app",
                icon: "gear",
                style: .secondary,
                showBanner: true
            )
            .sheet(isPresented: $showingPremiumUpgrade) {
                PremiumUpgradeView()
            }
        }
    }
    
    private func getLocationPermissionStatus() -> String {
        let status = CLLocationManager().authorizationStatus
        switch status {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedWhenInUse:
            return "When In Use"
        case .authorizedAlways:
            return "Always"
        @unknown default:
            return "Unknown"
        }
    }
}

#Preview {
    SettingsView()
} 