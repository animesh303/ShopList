import SwiftUI
import UIKit

struct ShoppingListView: View {
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var showingAddItemSheet = false
    @State private var showingShareSheet = false
    @State private var showingListSettings = false
    @State private var searchText = ""
    @State private var showingCompletedItems = false
    @State private var sortOrder: ItemSortOrder = .category
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var listToShare: ShoppingList?
    
    var filteredItems: [Item] {
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
    
    var itemsByCategory: [ItemCategory: [Item]] {
        Dictionary(grouping: filteredItems) { $0.category }
    }
    
    var body: some View {
        List {
            if let budget = list.budget {
                Section {
                    HStack {
                        Text("Budget")
                        Spacer()
                        Text("$\(budget, specifier: "%.2f")")
                            .foregroundColor(.secondary)
                    }
                    
                    let totalCost = list.totalEstimatedCost
                    HStack {
                        Text("Estimated Total")
                        Spacer()
                        Text("$\(totalCost, specifier: "%.2f")")
                            .foregroundColor(totalCost > budget ? .red : .secondary)
                    }
                }
            }
            
            ForEach(itemsByCategory.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { category, items in
                Section(header: Text(category.rawValue)) {
                    ForEach(items) { item in
                        ItemRow(item: item, list: list, viewModel: viewModel, showingError: $showingError, errorMessage: $errorMessage)
                    }
                    .onMove { source, destination in
                        Task {
                            do {
                                var updatedList = list
                                updatedList.reorderItems(from: source, to: destination)
                                try viewModel.updateList(updatedList)
                            } catch {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            do {
                                var updatedList = list
                                let itemsToDelete = indexSet.map { items[$0] }
                                itemsToDelete.forEach { updatedList.removeItem($0) }
                                try viewModel.updateList(updatedList)
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
}

struct ItemRow: View {
    let item: Item
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var showingItemDetails = false
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        HStack {
            Button(action: {
                Task {
                    do {
                        var updatedList = list
                        updatedList.toggleItemCompletion(item)
                        try viewModel.updateList(updatedList)
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
                    if let brand = item.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let unit = item.unit {
                        Text("\(item.quantity) \(unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Qty: \(item.quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let price = item.estimatedPrice {
                        Text("$\(price, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let notes = item.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let image = item.imageURL {
                AsyncImage(url: image) { image in
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

enum ItemSortOrder {
    case category
    case name
    case priority
    case dateAdded
}

struct ListSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var listName: String
    @State private var category: ListCategory
    @State private var budget: Double?
    @State private var isTemplate: Bool
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(list: ShoppingList, viewModel: ShoppingListViewModel) {
        self.list = list
        self.viewModel = viewModel
        _listName = State(initialValue: list.name)
        _category = State(initialValue: list.category)
        _budget = State(initialValue: list.budget)
        _isTemplate = State(initialValue: list.isTemplate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("List Details")) {
                    TextField("List Name", text: $listName)
                    Picker("Category", selection: $category) {
                        ForEach(ListCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Budget")) {
                    HStack {
                        Text("$")
                        TextField("Budget Amount", value: $budget, format: .number)
                            .keyboardType(.decimalPad)
                            .onChange(of: budget) { newValue in
                                if let value = newValue, value.isNaN || value.isInfinite {
                                    budget = nil
                                }
                            }
                    }
                }
                
                Section {
                    Toggle("Save as Template", isOn: $isTemplate)
                }
            }
            .navigationTitle("List Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            do {
                                var updatedList = list
                                updatedList.name = listName
                                updatedList.category = category
                                updatedList.budget = budget
                                updatedList.isTemplate = isTemplate
                                try viewModel.updateList(updatedList)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    }
                    .disabled(listName.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let item: Item
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Item Details")) {
                    LabeledContent("Name", value: item.name)
                    LabeledContent("Quantity", value: "\(item.quantity)")
                    LabeledContent("Category", value: item.category.rawValue)
                    LabeledContent("Priority", value: item.priority.displayName)
                }
                
                if let brand = item.brand {
                    Section(header: Text("Brand")) {
                        Text(brand)
                    }
                }
                
                if let price = item.estimatedPrice {
                    Section(header: Text("Price")) {
                        Text("$\(price, specifier: "%.2f")")
                    }
                }
                
                if let notes = item.notes {
                    Section(header: Text("Notes")) {
                        Text(notes)
                    }
                }
                
                if let imageURL = item.imageURL {
                    Section {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditItemView(item: item, list: list, viewModel: viewModel)
            }
        }
    }
}

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    let item: Item
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var editedItem: Item
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, price, brand, unit, notes
    }
    
    init(item: Item, list: ShoppingList, viewModel: ShoppingListViewModel) {
        self.item = item
        self.list = list
        self.viewModel = viewModel
        _editedItem = State(initialValue: item)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $editedItem.name)
                        .focused($focusedField, equals: .name)
                    Stepper("Quantity: \(editedItem.quantity)", value: $editedItem.quantity, in: 1...99)
                    Picker("Category", selection: $editedItem.category) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    Picker("Priority", selection: $editedItem.priority) {
                        ForEach(ItemPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                }
                
                Section(header: Text("Price & Brand")) {
                    HStack {
                        Text("$")
                        TextField("Estimated Price", value: $editedItem.estimatedPrice, format: .number)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .price)
                            .onChange(of: editedItem.estimatedPrice) { newValue in
                                if let value = newValue, value.isNaN || value.isInfinite {
                                    editedItem.estimatedPrice = nil
                                }
                            }
                    }
                    TextField("Brand", text: Binding(
                        get: { editedItem.brand ?? "" },
                        set: { editedItem.brand = $0.isEmpty ? nil : $0 }
                    ))
                    .focused($focusedField, equals: .brand)
                    TextField("Unit", text: Binding(
                        get: { editedItem.unit ?? "" },
                        set: { editedItem.unit = $0.isEmpty ? nil : $0 }
                    ))
                    .focused($focusedField, equals: .unit)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Notes", text: Binding(
                        get: { editedItem.notes ?? "" },
                        set: { editedItem.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .focused($focusedField, equals: .notes)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            do {
                                var updatedList = list
                                updatedList.updateItem(editedItem)
                                try viewModel.updateList(updatedList)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    }
                    .disabled(editedItem.name.isEmpty)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .keyboardAdaptive()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 