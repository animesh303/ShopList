import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    
    @State private var itemName = ""
    @State private var quantity = 1
    @State private var category: ItemCategory = .other
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Item Name", text: $itemName)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section {
                    TextField("Notes (Optional)", text: $notes)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newItem = Item(
                            name: itemName,
                            quantity: quantity,
                            category: category,
                            isCompleted: false,
                            notes: notes.isEmpty ? nil : notes,
                            dateAdded: Date()
                        )
                        var updatedList = list
                        updatedList.addItem(newItem)
                        viewModel.updateList(updatedList)
                        dismiss()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
} 