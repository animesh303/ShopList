import SwiftUI
import SwiftData

struct ListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var list: ShoppingList
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var viewModel: ShoppingListViewModel
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var locationManager = LocationManager.shared
    
    @State private var showingAddItem = false
    @State private var showingDeleteConfirmation = false
    @State private var showingEditSheet = false
    @State private var showingReminderSheet = false
    @State private var showingLocationSetup = false
    @State private var showingSortPicker = false
    @State private var isFabExpanded = false
    @State private var fabTimer: Timer?
    @State private var searchText = ""
    @State private var sortOrder: ListSortOrder = .dateDesc
    @State private var editingBudget: String = ""
    @State private var showBudgetDetails = false
    
    init(list: ShoppingList) {
        self.list = list
        _viewModel = StateObject(wrappedValue: ShoppingListViewModel(modelContext: list.modelContext))
    }
    
    private var filteredItems: [Item] {
        var items = list.items
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply completed items filter
        if !settingsManager.showCompletedItemsByDefault {
            items = items.filter { !$0.isCompleted }
        }
        
        // Apply sorting
        switch sortOrder {
        case .nameAsc:
            items.sort { $0.name < $1.name }
        case .nameDesc:
            items.sort { $0.name > $1.name }
        case .dateDesc:
            items.sort { $0.dateAdded > $1.dateAdded }
        case .dateAsc:
            items.sort { $0.dateAdded < $1.dateAdded }
        case .categoryAsc:
            items.sort { $0.category.rawValue < $1.category.rawValue }
        case .categoryDesc:
            items.sort { $0.category.rawValue > $1.category.rawValue }
        }
        
        return items
    }
    
    var body: some View {
        ZStack {
            // Enhanced background with vibrant gradient
            DesignSystem.Colors.backgroundGradient
                .ignoresSafeArea()
            
            List {
                // Budget Section
                if let budget = list.budget {
                    Section {
                        DisclosureGroup(
                            isExpanded: $showBudgetDetails,
                            content: {
                                VStack(spacing: 4) {
                                    HStack {
                                        Label("Budget", systemImage: settingsManager.currency.icon)
                                            .foregroundColor(DesignSystem.Colors.primary)
                                        Spacer()
                                        Text(settingsManager.currency.symbol + String(format: "%.2f", budget))
                                            .foregroundColor(DesignSystem.Colors.primary)
                                            .fontWeight(.semibold)
                                    }
                                    HStack {
                                        Label("Estimated Cost", systemImage: "cart")
                                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                        Spacer()
                                        Text(settingsManager.currency.symbol + String(format: "%.2f", list.totalEstimatedCost))
                                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                            .fontWeight(.semibold)
                                    }
                                    HStack {
                                        Label("Spent", systemImage: "checkmark.circle.fill")
                                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                        Spacer()
                                        Text(settingsManager.currency.symbol + String(format: "%.2f", list.totalSpentCost))
                                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                            .fontWeight(.semibold)
                                    }
                                    HStack {
                                        Label("Remaining", systemImage: "creditcard")
                                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                        Spacer()
                                        let remaining = budget - list.totalSpentCost
                                        Text(settingsManager.currency.symbol + String(format: "%.2f", remaining))
                                            .foregroundColor(remaining >= 0 ? DesignSystem.Colors.adaptiveTextColor() : DesignSystem.Colors.error)
                                            .fontWeight(.semibold)
                                    }
                                }
                            },
                            label: {
                                BudgetProgressView(
                                    budget: budget,
                                    spent: list.totalSpentCost,
                                    currency: settingsManager.currency
                                )
                                .padding(.vertical, 2)
                            }
                        )
                    } header: {
                        Text("Budget Overview")
                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                    }
                }
                
                // Location Section
                if let location = list.location {
                    Section {
                        HStack {
                            Label("Location", systemImage: "location")
                                .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                            Spacer()
                            Text(location.name)
                                .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                        }
                        
                        Button("Update Location Reminder") {
                            showingLocationSetup = true
                        }
                        .buttonStyle(.bordered)
                        .tint(DesignSystem.Colors.primary)
                    } header: {
                        Text("Store Information")
                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                    }
                } else {
                    Section {
                        Button("Set Up Location Reminder") {
                            showingLocationSetup = true
                        }
                        .buttonStyle(.bordered)
                        .tint(DesignSystem.Colors.primary)
                    } header: {
                        Text("Location Reminder")
                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                    } footer: {
                        Text("Get notified when you're near the store")
                            .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                    }
                }
                
                // Items Section
                Section {
                    if filteredItems.isEmpty {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(.systemBackground).opacity(0.92))
                                .shadow(color: DesignSystem.Colors.primary.opacity(0.35), radius: 24, x: 0, y: 12)
                            VStack(spacing: 8) {
                                Button(action: {
                                    showingAddItem = true
                                }) {
                                    Image(systemName: "cart.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                        .padding()
                                        .background(DesignSystem.Colors.primary.opacity(0.1))
                                        .clipShape(Circle())
                                        .shadow(color: DesignSystem.Colors.primary.opacity(0.15), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(PlainButtonStyle())
                                Text("No items yet!")
                                    .font(.headline)
                                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                Text("Tap the cart to add your first item.")
                                    .font(.subheadline)
                                    .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 180)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredItems) { item in
                            NavigationLink(value: item) {
                                ItemRow(item: item)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            let generator = UINotificationFeedbackGenerator()
                                            generator.notificationOccurred(.success)
                                            list.removeItem(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            item.isCompleted.toggle()
                                        } label: {
                                            Label(item.isCompleted ? "Uncheck" : "Check", 
                                                  systemImage: item.isCompleted ? "xmark.circle" : "checkmark.circle")
                                        }
                                        .tint(item.isCompleted ? DesignSystem.Colors.warning : DesignSystem.Colors.success)
                                    }
                            }
                        }
                        
                        if !filteredItems.isEmpty {
                            HStack {
                                Label("Total Items", systemImage: "list.bullet")
                                    .foregroundColor(DesignSystem.Colors.primary)
                                Spacer()
                                Text("\(filteredItems.count) items")
                                    .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Items")
                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                        Spacer()
                        if !filteredItems.isEmpty {
                            Text("\(filteredItems.count)")
                                .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                                .font(.caption)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listSectionSpacing(0)
            .listRowSpacing(0)
            .listRowSeparator(.hidden)
            .enhancedNavigation(
                title: list.name,
                subtitle: "\(list.items.count) items • \(list.category.rawValue)",
                icon: list.category.icon,
                style: .custom(DesignSystem.Colors.themeAwareCategoryGradient(for: list.category, colorScheme: colorScheme)),
                showBanner: true,
                searchText: $searchText,
                searchPrompt: "Search items"
            )
            .overlay(
                Group {
                    if settingsManager.restrictSearchToLocality && !searchText.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                Text("Search restricted to local area")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                }
            )
            
            // Enhanced Floating Action Buttons with vibrant design
            VStack {
                Spacer()
                HStack {
                    // Back Button FAB at bottom left
                    VStack {
                        Spacer()
                        BackButtonFAB {
                            dismiss()
                        }
                    }
                    .padding(.leading, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                    
                    Spacer()
                    
                    // Right FAB at bottom right
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Spacer() // Push FAB to bottom
                        
                        if isFabExpanded {
                            // Delete List button
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                showingDeleteConfirmation = true
                                withAnimation(DesignSystem.Animations.spring) {
                                    isFabExpanded = false
                                }
                                stopFabTimer()
                            } label: {
                                Image(systemName: "trash")
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
                            .transition(.scale.combined(with: .opacity))
                            
                            // Reminder button (if notifications enabled)
                            if settingsManager.notificationsEnabled && notificationManager.isAuthorized {
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingReminderSheet = true
                                    withAnimation(DesignSystem.Animations.spring) {
                                        isFabExpanded = false
                                    }
                                    stopFabTimer()
                                } label: {
                                    Image(systemName: "bell")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                        .background(
                                            DesignSystem.Colors.secondary.opacity(0.8)
                                        )
                                        .clipShape(Circle())
                                        .shadow(
                                            color: DesignSystem.Colors.secondary.opacity(0.4),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // Edit List button
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                showingEditSheet = true
                                withAnimation(DesignSystem.Animations.spring) {
                                    isFabExpanded = false
                                }
                                stopFabTimer()
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(
                                        DesignSystem.Colors.warning.opacity(0.8)
                                    )
                                    .clipShape(Circle())
                                    .shadow(
                                        color: DesignSystem.Colors.warning.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                            .transition(.scale.combined(with: .opacity))
                            
                            // Sort button
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                showingSortPicker = true
                                withAnimation(DesignSystem.Animations.spring) {
                                    isFabExpanded = false
                                }
                                stopFabTimer()
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(
                                        DesignSystem.Colors.info.opacity(0.8)
                                    )
                                    .clipShape(Circle())
                                    .shadow(
                                        color: DesignSystem.Colors.info.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                            .transition(.scale.combined(with: .opacity))
                            
                            // Add Item button
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                showingAddItem = true
                                withAnimation(DesignSystem.Animations.spring) {
                                    isFabExpanded = false
                                }
                                stopFabTimer()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(
                                        DesignSystem.Colors.primaryButtonGradient
                                    )
                                    .clipShape(Circle())
                                    .shadow(
                                        color: DesignSystem.Colors.primary.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Enhanced toggle button with vibrant design
                        Button {
                            withAnimation(DesignSystem.Animations.spring) {
                                isFabExpanded.toggle()
                            }
                            if isFabExpanded {
                                startFabTimer()
                            } else {
                                stopFabTimer()
                            }
                        } label: {
                            Image(systemName: isFabExpanded ? "chevron.down" : "ellipsis")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                .background(
                                    DesignSystem.Colors.accentButtonGradient
                                )
                                .clipShape(Circle())
                                .shadow(
                                    color: DesignSystem.Colors.accent1.opacity(0.4),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                        }
                    }
                    .padding(.trailing, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(list: list)
        }
        .sheet(isPresented: $showingEditSheet) {
            ListSettingsView(list: list, viewModel: viewModel)
        }
        .sheet(isPresented: $showingReminderSheet) {
            ReminderSheet(list: list)
        }
        .sheet(isPresented: $showingLocationSetup) {
            LocationSetupView(list: list)
        }
        .sheet(isPresented: $showingSortPicker) {
            ItemSortPickerView(sortOrder: $sortOrder)
        }
        .navigationDestination(for: Item.self) { item in
            ItemDetailView(item: item)
        }
        .alert("Delete List", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                deleteList()
            }
        } message: {
            Text("Are you sure you want to delete this list? This action cannot be undone.")
        }
    }
    
    private func deleteList() {
        modelContext.delete(list)
        dismiss()
    }
    
    // MARK: - FAB Timer Functions
    
    private func startFabTimer() {
        stopFabTimer() // Cancel any existing timer
        fabTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation {
                isFabExpanded = false
            }
        }
    }
    
    private func stopFabTimer() {
        fabTimer?.invalidate()
        fabTimer = nil
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    let list = ShoppingList(name: "Test List", category: .groceries)
    
    return ListDetailView(list: list)
        .modelContainer(container)
} 