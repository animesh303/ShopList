import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var item: Item
    private let list: ShoppingList
    @ObservedObject private var viewModel: ShoppingListViewModel
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(item: Item, list: ShoppingList, viewModel: ShoppingListViewModel) {
        self._item = State(initialValue: item)
        self.list = list
        self.viewModel = viewModel
    }
    
    private func updateItem() {
        Task {
            do {
                var updatedList = list
                if let index = updatedList.items.firstIndex(where: { $0.id == item.id }) {
                    updatedList.items[index] = item
                    try viewModel.updateList(updatedList)
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $item.name)
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("1", value: $item.quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        
                        Picker("Unit", selection: $item.unit) {
                            ForEach(ShoppingList.commonUnits, id: \.self) { unit in
                                Text(unit.isEmpty ? "None" : unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Picker("Category", selection: $item.category) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Picker("Priority", selection: $item.priority) {
                        ForEach(ItemPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                }
                
                Section(header: Text("Brand & Price")) {
                    TextField("Brand", text: Binding(
                        get: { item.brand ?? "" },
                        set: { item.brand = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Estimated Price", value: $item.estimatedPrice, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(
                        get: { item.notes ?? "" },
                        set: { item.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(minHeight: 100)
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
                        updateItem()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    ItemDetailView(
        item: Item(name: "Sample Item", quantity: 1, category: .groceries, priority: .normal),
        list: ShoppingList(name: "Test List"),
        viewModel: ShoppingListViewModel()
    )
}
