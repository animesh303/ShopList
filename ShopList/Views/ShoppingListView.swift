import SwiftUI
import UIKit

enum ItemSortOrder: String, CaseIterable {
    case category = "Category"
    case name = "Name"
    case priority = "Priority"
    case dateAdded = "Date Added"
}

struct ShoppingListView: View {
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    @StateObject private var settingsManager = UserSettingsManager.shared
    @State private var showingAddItemSheet = false
    @State private var showingShareSheet = false
    @State private var showingListSettings = false
    @State private var searchText = ""
    @State private var showingCompletedItems = false
    @State private var sortOrder: ItemSortOrder = .category
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var listToShare: ShoppingList?
    
    private var filteredItems: [Item] {
        var items = list.items
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply sorting
        switch sortOrder {
        case .category:
            items.sort { $0.category.rawValue < $1.category.rawValue }
        case .name:
            items.sort { $0.name < $1.name }
        case .priority:
            items.sort { $0.priority.rawValue > $1.priority.rawValue }
        case .dateAdded:
            items.sort { $0.dateAdded > $1.dateAdded }
        }
        
        return items
    }
    
    private var itemsByCategory: [(key: ItemCategory, value: [Item])] {
        let grouped = Dictionary(grouping: filteredItems) { $0.category }
        return grouped.sorted { $0.key.rawValue.localizedCaseInsensitiveCompare($1.key.rawValue) == .orderedAscending }
    }
        
    var body: some View {
        List {
            if let budget = list.budget {
                let totalCost = list.totalEstimatedCost
                Section {
                    budgetRow(budget: budget, totalCost: totalCost)
                }
            }
            
            ForEach(itemsByCategory, id: \.key) { category, items in
                Section(header: Text(category.rawValue)) {
                    ForEach(items) { item in
                        ItemRow(item: item, list: list, viewModel: viewModel, showingError: $showingError, errorMessage: $errorMessage)
                    }
                    .onMove { source, destination in
                        Task {
                            do {
                                list.reorderItems(from: source, to: destination)
                                try await viewModel.updateShoppingList(list)
                            } catch {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            do {
                                let itemsToDelete = indexSet.map { items[$0] }
                                itemsToDelete.forEach { list.removeItem($0) }
                                try await viewModel.updateShoppingList(list)
                            } catch {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search items")
        .navigationTitle(list.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItemSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingListSettings = true }) {
                        Label("List Settings", systemImage: "gear")
                    }
                    Button(action: { showingShareSheet = true }) {
                        Label("Share List", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Picker("Sort by", selection: $sortOrder) {
                        Text("Category").tag(ItemSortOrder.category)
                        Text("Name").tag(ItemSortOrder.name)
                        Text("Priority").tag(ItemSortOrder.priority)
                        Text("Date Added").tag(ItemSortOrder.dateAdded)
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .sheet(isPresented: $showingAddItemSheet) {
            AddItemView(list: list, viewModel: viewModel)
        }
        .sheet(isPresented: $showingListSettings) {
            ListSettingsView(list: list, viewModel: viewModel)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [list.name])
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    @ViewBuilder
    private func budgetRow(budget: Double, totalCost: Double) -> some View {
        Group {
            HStack {
                Text("Budget")
                Spacer()
                Text(budget, format: .currency(code: settingsManager.currency.rawValue).precision(.fractionLength(2)))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Estimated Total")
                Spacer()
                Text(totalCost, format: .currency(code: settingsManager.currency.rawValue).precision(.fractionLength(2)))
                    .foregroundColor(totalCost > budget ? .red : .secondary)
            }
        }
    }
}

struct ItemRow: View {
    let item: Item
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    @StateObject private var settingsManager = UserSettingsManager.shared
    @State private var showingItemDetails = false
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        HStack {
            Button(action: {
                Task {
                    do {
                        list.toggleItemCompletion(item)
                        try await viewModel.updateShoppingList(list)
                    } catch {
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .strikethrough(item.isCompleted)
                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                    
                    if item.priority == .high {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                
                HStack {
                    if let brand = item.brand, !brand.isEmpty {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(item.quantity.formatted(.number.precision(.fractionLength(1))))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let unit = item.unit, !unit.isEmpty {
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let price = item.estimatedPrice {
                        Text(price, format: .currency(code: settingsManager.currency.rawValue))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingItemDetails = true
        }
        .sheet(isPresented: $showingItemDetails) {
            ItemDetailView(item: item, list: list, viewModel: viewModel)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
