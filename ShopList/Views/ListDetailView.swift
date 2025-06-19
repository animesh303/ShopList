import SwiftUI
import SwiftData

struct ListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
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
    @State private var searchText = ""
    @State private var sortOrder: ListSortOrder = .dateDesc
    @State private var editingBudget: String = ""
    
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
            List {
                // Budget Section
                if let budget = list.budget {
                    Section {
                        BudgetProgressView(
                            budget: budget,
                            spent: list.totalEstimatedCost,
                            currency: settingsManager.currency
                        )
                        .padding(.vertical, 8)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Label("Budget", systemImage: "dollarsign.circle")
                                Spacer()
                                Text(settingsManager.currency.symbol + String(format: "%.2f", budget))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Label("Estimated Cost", systemImage: "cart")
                                Spacer()
                                Text(settingsManager.currency.symbol + String(format: "%.2f", list.totalEstimatedCost))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Label("Remaining", systemImage: "creditcard")
                                Spacer()
                                let remaining = budget - list.totalEstimatedCost
                                Text(settingsManager.currency.symbol + String(format: "%.2f", remaining))
                                    .foregroundColor(remaining >= 0 ? .green : .red)
                            }
                        }
                    } header: {
                        Text("Budget Overview")
                    }
                }
                
                // Location Section
                if let location = list.location {
                    Section {
                        HStack {
                            Label("Location", systemImage: "location")
                            Spacer()
                            Text(location.name)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Update Location Reminder") {
                            showingLocationSetup = true
                        }
                        .buttonStyle(.bordered)
                    } header: {
                        Text("Store Information")
                    }
                } else {
                    Section {
                        Button("Set Up Location Reminder") {
                            showingLocationSetup = true
                        }
                        .buttonStyle(.bordered)
                    } header: {
                        Text("Location Reminder")
                    } footer: {
                        Text("Get notified when you're near the store")
                    }
                }
                
                // Items Section
                Section {
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
                                    .tint(item.isCompleted ? .orange : .green)
                                }
                        }
                    }
                    
                    if !filteredItems.isEmpty {
                        HStack {
                            Label("Total Items", systemImage: "list.bullet")
                            Spacer()
                            Text("\(filteredItems.count) items")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    HStack {
                        Text("Items")
                        Spacer()
                        if !filteredItems.isEmpty {
                            Text("\(filteredItems.count)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(list.name)
            .searchable(text: $searchText, prompt: "Search items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Sort & Filter Options
                        Label("Sort Items", systemImage: "arrow.up.arrow.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Sort By", selection: $sortOrder) {
                            ForEach(ListSortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                        
                        Toggle("Show Completed Items", isOn: $settingsManager.showCompletedItemsByDefault)
                        
                        Divider()
                        
                        // List Management Options
                        Label("List Actions", systemImage: "list.bullet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: { 
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            showingEditSheet = true 
                        }) {
                            Label("Edit List", systemImage: "pencil")
                        }
                        
                        if settingsManager.notificationsEnabled && notificationManager.isAuthorized {
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                showingReminderSheet = true
                            }) {
                                Label("Set Reminder", systemImage: "bell")
                            }
                        }
                        
                        Button(role: .destructive, action: { 
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            showingDeleteConfirmation = true 
                        }) {
                            Label("Delete List", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    }
                }
            }
            
            // Floating Action Button for adding items
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
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
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    let list = ShoppingList(name: "Test List", category: .groceries)
    
    return ListDetailView(list: list)
        .modelContainer(container)
} 