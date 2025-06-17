import SwiftUI
import SwiftData

struct BudgetProgressView: View {
    let budget: Double
    let spent: Double
    let currency: Currency
    
    private var progress: Double {
        min(spent / budget, 1.0)
    }
    
    private var remaining: Double {
        budget - spent
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Budget Progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(currency.symbol)\(String(format: "%.2f", spent)) / \(currency.symbol)\(String(format: "%.2f", budget))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 12)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text("Remaining: \(currency.symbol)\(String(format: "%.2f", remaining))")
                    .font(.caption)
                    .foregroundColor(remaining >= 0 ? .green : .red)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(progressColor)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return .red
        } else if progress >= 0.8 {
            return .orange
        } else {
            return .green
        }
    }
}

struct ListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var list: ShoppingList
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    @State private var showingAddItem = false
    @State private var showingDeleteConfirmation = false
    @State private var showingEditSheet = false
    @State private var searchText = ""
    @State private var sortOrder: ListSortOrder = .dateDesc
    @State private var showingCompletedItems = true
    @State private var editingBudget: String = ""
    
    private var filteredItems: [Item] {
        var items = list.items
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply completed items filter
        if !showingCompletedItems {
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
                Section {
                    if let budget = list.budget {
                        BudgetProgressView(
                            budget: budget,
                            spent: list.totalEstimatedCost,
                            currency: settingsManager.currency
                        )
                    }
                    
                    if let budget = list.budget {
                        HStack {
                            Text("Budget")
                            Spacer()
                            Text(settingsManager.currency.symbol + String(format: "%.2f", budget))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Estimated Cost")
                        Spacer()
                        Text(settingsManager.currency.symbol + String(format: "%.2f", list.totalEstimatedCost))
                            .foregroundColor(.secondary)
                    }
                    
                    if let budget = list.budget {
                        HStack {
                            Text("Remaining")
                            Spacer()
                            let remaining = budget - list.totalEstimatedCost
                            Text(settingsManager.currency.symbol + String(format: "%.2f", remaining))
                                .foregroundColor(remaining >= 0 ? .green : .red)
                        }
                    }
                    
                    if let location = list.location {
                        HStack {
                            Text("Location")
                            Spacer()
                            Text(location.name)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    ForEach(filteredItems) { item in
                        NavigationLink(value: item) {
                            ItemRow(item: item)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.success)
                                        if let index = list.items.firstIndex(where: { $0.id == item.id }) {
                                            list.removeItem(item)
                                        }
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
                
                    HStack {
                        Text("Items")
                        Spacer()
                        Text("\(list.items.count) items")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(list.name)
            .searchable(text: $searchText, prompt: "Search items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $sortOrder) {
                            ForEach(ListSortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                        
                        Toggle("Show Completed", isOn: $showingCompletedItems)
                        
                        Button(action: { 
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            showingEditSheet = true 
                        }) {
                            Label("Edit List", systemImage: "pencil")
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
            ListSettingsView(list: list, viewModel: ShoppingListViewModel.shared)
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
    
    private func deleteItems(at offsets: IndexSet) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        for index in offsets {
            let item = filteredItems[index]
            list.removeItem(item)
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
    let list = ShoppingList(name: "Preview List")
    
    return NavigationView {
        ListDetailView(list: list)
    }
    .modelContainer(container)
} 