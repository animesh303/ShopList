import SwiftUI
import SwiftData

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
                        }
                    }
                    .onDelete(perform: deleteItems)
                
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
                        
                        Button(action: { showingEditSheet = true }) {
                            Label("Edit List", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
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
                deleteList()
            }
        } message: {
            Text("Are you sure you want to delete this list? This action cannot be undone.")
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
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