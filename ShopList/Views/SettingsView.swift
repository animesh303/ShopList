import SwiftUI
import CoreLocation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showingPremiumUpgrade = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                Form {
                    // Subscription Section - Premium Gold Gradient
                    Section {
                        HStack {
                            Image(systemName: subscriptionManager.currentTier.icon)
                                .font(.title2)
                                .foregroundColor(subscriptionManager.currentTier.color)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Plan")
                                    .headlineStyle()
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                Text(subscriptionManager.currentTier.displayName)
                                    .subheadlineStyle()
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
                                    .subheadlineBoldStyle()
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                let usage = subscriptionManager.getFreeTierUsage()
                                
                                HStack {
                                    Image(systemName: "list.bullet")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                    Text("\(usage.lists)/\(usage.maxLists) lists")
                                        .captionStyle()
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(DesignSystem.Colors.accent1)
                                    Text("\(usage.notifications)/\(usage.maxNotifications) daily notifications")
                                        .captionStyle()
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(DesignSystem.Colors.accent2)
                                    Text("3 basic categories only")
                                        .captionStyle()
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                            }
                            .padding(.vertical, 8)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Premium Features:")
                                    .subheadlineBoldStyle()
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                ForEach(Array(PremiumFeature.allCases.prefix(6))) { feature in
                                    HStack {
                                        Image(systemName: feature.icon)
                                            .foregroundColor(DesignSystem.Colors.accent1)
                                        Text(feature.rawValue)
                                            .captionStyle()
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
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.premium.opacity(0.1),
                                DesignSystem.Colors.premiumLight.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Mock Subscription Testing Section (Development Only) - Debug Purple
                    #if DEBUG
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Testing Controls")
                                .subheadlineBoldStyle()
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            HStack {
                                Text("Mock Premium Subscription")
                                    .captionStyle()
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                
                                Spacer()
                                
                                Button(subscriptionManager.isPremium ? "Disable" : "Enable") {
                                    if subscriptionManager.isPremium {
                                        subscriptionManager.mockUnsubscribe()
                                    } else {
                                        subscriptionManager.mockSubscribe()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(subscriptionManager.isPremium ? .red : .green)
                                .captionStyle()
                            }
                            
                            Text("Use this to test premium features without real purchases")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                            
                            // Debug buttons
                            HStack {
                                Button("Debug Status") {
                                    subscriptionManager.debugPersistedStatus()
                                }
                                .buttonStyle(.bordered)
                                .tint(.blue)
                                .captionStyle()
                                
                                Button("Clear Data") {
                                    subscriptionManager.clearPersistedSubscriptionData()
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                                .captionStyle()
                                
                                Button("Force Refresh") {
                                    Task {
                                        await subscriptionManager.forceRefreshSubscriptionStatus()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.orange)
                                .captionStyle()
                            }
                        }
                    } header: {
                        Text("Development Testing")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.accent3.opacity(0.1),
                                DesignSystem.Colors.accent3.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    #endif
                    
                    // Appearance Section - Blue Gradient
                    Section(header: Text("Appearance").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Picker(selection: $settingsManager.appearance) {
                            ForEach(Appearance.allCases) { appearance in
                                HStack(spacing: 8) {
                                    Image(systemName: appearance.icon)
                                        .foregroundColor(appearance.color)
                                        .font(.title3)
                                        .frame(width: 20)
                                    Text(appearance.rawValue)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(appearance)
                            }
                        } label: {
                            Text("Theme")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker(selection: $settingsManager.defaultListViewStyle) {
                            ForEach(ListViewStyle.allCases) { style in
                                HStack(spacing: 8) {
                                    Image(systemName: style.icon)
                                        .foregroundColor(style.color)
                                        .font(.title)
                                        .frame(width: 32, height: 32)
                                    Text(style.rawValue)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(style)
                            }
                        } label: {
                            Text("List View Style")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Toggle("Show Completed Items", isOn: $settingsManager.showCompletedItemsByDefault)
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.1),
                                DesignSystem.Colors.primaryLight.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Currency Section - Green Gradient
                    Section(header: Text("Currency").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Picker(selection: $settingsManager.currency) {
                            ForEach(Currency.allCases) { currency in
                                HStack(spacing: 8) {
                                    Image(systemName: currency.icon)
                                        .foregroundColor(currency.color)
                                        .font(.title)
                                        .frame(width: 36, height: 36)
                                    Text(currency.name)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(currency)
                            }
                        } label: {
                            Text("Currency")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.accent2.opacity(0.1),
                                DesignSystem.Colors.accent2.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Number Format Section - Teal Gradient
                    Section(header: Text("Number Format").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Picker(selection: $settingsManager.numberFormat) {
                            ForEach(NumberFormat.allCases) { format in
                                HStack(spacing: 8) {
                                    Image(systemName: format.icon)
                                        .foregroundColor(format.color)
                                        .font(.title)
                                        .frame(width: 32, height: 32)
                                    Text(format.rawValue)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(format)
                            }
                        } label: {
                            Text("Decimal Separator")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.accent4.opacity(0.1),
                                DesignSystem.Colors.accent4.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Item Display Section - Orange Gradient
                    Section(header: Text("Item Display").foregroundColor(DesignSystem.Colors.primaryText)) {
                        HStack {
                            Toggle("Show Item Images", isOn: Binding(
                                get: { settingsManager.showItemImagesByDefault },
                                set: { newValue in
                                    if !settingsManager.setPremiumSetting(.itemImages, value: newValue) {
                                        // Show upgrade prompt if setting couldn't be enabled
                                        showingPremiumUpgrade = true
                                    }
                                }
                            ))
                            
                            if !subscriptionManager.canUseItemImages() {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                    .font(DesignSystem.Typography.caption1)
                            }
                        }
                        
                        Toggle("Show Item Notes", isOn: $settingsManager.showItemNotesByDefault)
                        Picker(selection: $settingsManager.defaultItemViewStyle) {
                            ForEach(ItemViewStyle.allCases) { style in
                                HStack(spacing: 8) {
                                    Image(systemName: style.icon)
                                        .foregroundColor(style.color)
                                        .font(.title)
                                        .frame(width: 32, height: 32)
                                    Text(style.rawValue)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(style)
                            }
                        } label: {
                            Text("Item View Style")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.accent1.opacity(0.1),
                                DesignSystem.Colors.accent1.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Defaults Section - Purple Gradient
                    Section(header: Text("Defaults").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Picker(selection: $settingsManager.defaultListCategory) {
                            ForEach(subscriptionManager.getAvailableCategories().sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
                                HStack(spacing: 8) {
                                    Image(systemName: category.icon)
                                        .foregroundColor(category.color)
                                        .font(.title3)
                                        .frame(width: 20)
                                    Text(category.rawValue)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(category)
                            }
                        } label: {
                            Text("Default List Category")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker(selection: $settingsManager.defaultItemCategory) {
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                HStack(spacing: 8) {
                                    Image(systemName: category.icon)
                                        .foregroundColor(category.color)
                                        .font(.title3)
                                        .frame(width: 20)
                                    Text(category.rawValue)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(category)
                            }
                        } label: {
                            Text("Default Item Category")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker(selection: $settingsManager.defaultItemPriority) {
                            ForEach(ItemPriority.allCases, id: \.self) { priority in
                                HStack(spacing: 8) {
                                    Image(systemName: priority.icon)
                                        .foregroundColor(priority.color)
                                        .font(.title)
                                        .frame(width: 32, height: 32)
                                    Text(priority.displayName)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(priority)
                            }
                        } label: {
                            Text("Default Item Priority")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker(selection: $settingsManager.defaultUnit) {
                            ForEach(Unit.allUnits) { unit in
                                HStack(spacing: 8) {
                                    Image(systemName: unit.icon)
                                        .foregroundColor(unit.color)
                                        .font(.title)
                                        .frame(width: 32, height: 32)
                                    Text(unit.displayName)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(unit.rawValue)
                            }
                        } label: {
                            Text("Default Unit")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker(selection: $settingsManager.defaultListSortOrder) {
                            ForEach(ListSortOrder.allCases) { order in
                                HStack(spacing: 8) {
                                    Image(systemName: order.icon)
                                        .foregroundColor(order.color)
                                        .font(.title)
                                        .frame(width: 32, height: 32)
                                    Text(order.displayName)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(order)
                            }
                        } label: {
                            Text("Default Sort Order")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.secondary.opacity(0.1),
                                DesignSystem.Colors.secondaryLight.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Notifications Section - Blue Info Gradient
                    Section(header: Text("Notifications").foregroundColor(DesignSystem.Colors.primaryText)) {
                        Toggle("Enable Notifications", isOn: $settingsManager.notificationsEnabled)
                        
                        if !notificationManager.isAuthorized && settingsManager.notificationsEnabled {
                            Text("Please enable notifications in Settings to receive reminders")
                                .captionStyle()
                                .foregroundColor(DesignSystem.Colors.warning)
                        }
                        
                        if settingsManager.notificationsEnabled {
                            DatePicker("Default Reminder Time",
                                     selection: $settingsManager.defaultReminderTime,
                                     displayedComponents: .hourAndMinute)
                            
                            Picker("Notification Sound", selection: $settingsManager.notificationSound) {
                                ForEach(NotificationSound.allCases) { sound in
                                    HStack(spacing: 8) {
                                        Image(systemName: sound.icon)
                                            .renderingMode(.template)
                                            .foregroundColor(DesignSystem.Colors.accent1)
                                            .font(.title3)
                                            .frame(width: 20)
                                        Text(sound.rawValue)
                                            .font(DesignSystem.Typography.body)
                                            .foregroundColor(DesignSystem.Colors.accent1)
                                    }
                                    .tag(sound)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            NavigationLink("Manage Notifications") {
                                NotificationSettingsView()
                            }
                            
                            if notificationManager.isAuthorized {
                                Text("Notifications are enabled and ready")
                                    .captionStyle()
                                    .foregroundColor(DesignSystem.Colors.success)
                            }
                        }
                        
                        if !subscriptionManager.canUseUnlimitedNotifications() {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                    .captionStyle()
                                Text("Free users limited to \(subscriptionManager.getNotificationLimit()) notifications per day")
                                    .captionStyle()
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                        }
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
                    
                    // Location Reminders Section - Success Green Gradient
                    Section(header: Text("Location Reminders").foregroundColor(DesignSystem.Colors.primaryText)) {
                        if !subscriptionManager.canUseLocationReminders() {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                VStack(alignment: .leading) {
                                    Text("Premium Feature")
                                        .headlineStyle()
                                    Text("Upgrade to Premium for location-based reminders")
                                        .captionStyle()
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
                                        .headlineStyle()
                                    Text(getLocationPermissionStatus())
                                        .captionStyle()
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
                                        .captionStyle()
                                        .foregroundColor(DesignSystem.Colors.success)
                                } else {
                                    Text("Background monitoring requires 'Always' location access")
                                        .captionStyle()
                                        .foregroundColor(DesignSystem.Colors.warning)
                                }
                            } else {
                                Text("Enable location access to set up store-based reminders")
                                    .captionStyle()
                                    .foregroundColor(DesignSystem.Colors.warning)
                            }
                        }
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
                    
                    // Location Search Section - Warning Yellow Gradient
                    Section(header: Text("Location Search").foregroundColor(DesignSystem.Colors.primaryText)) {
                        NavigationLink(destination: LocationSearchSettingsView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Search Restrictions")
                                        .headlineStyle()
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Text(settingsManager.restrictSearchToLocality ? "Search limited to local area" : "Search not restricted")
                                        .captionStyle()
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                Spacer()
                                HStack(spacing: 8) {
                                    Image(systemName: "location.viewfinder")
                                        .foregroundColor(.accentColor)
                                        .font(.title)
                                        .frame(width: 32, height: 32)
                                    Text("Configure")
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        if settingsManager.restrictSearchToLocality {
                            HStack {
                                Image(systemName: "circle.dashed")
                                    .foregroundColor(DesignSystem.Colors.info)
                                Text("Search radius: \(Int(settingsManager.searchRadius / 1000)) km")
                                    .captionStyle()
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                        }
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
        .environmentObject(SubscriptionManager.shared)
} 