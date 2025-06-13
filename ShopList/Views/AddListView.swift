import SwiftUI

struct AddListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var listName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("List Name", text: $listName)
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newList = ShoppingList(
                            name: listName,
                            items: [],
                            dateCreated: Date(),
                            isShared: false
                        )
                        viewModel.addShoppingList(newList)
                        dismiss()
                    }
                    .disabled(listName.isEmpty)
                }
            }
        }
    }
} 