import SwiftUI

struct AddListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var listName = ""
    @State private var category: ListCategory = .personal
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("List Name", text: $listName)
                    Picker("Category", selection: $category) {
                        ForEach(ListCategory.allCases.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
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
                        Task {
                            do {
                                guard !listName.isEmpty else {
                                    throw AppError.invalidListName
                                }
                                
                                guard await viewModel.findList(byName: listName) == nil else {
                                    throw AppError.listAlreadyExists
                                }
                                
                                let newList = ShoppingList(
                                    name: listName,
                                    items: [],
                                    dateCreated: Date(),
                                    isShared: false,
                                    category: category
                                )
                                
                                try await viewModel.addShoppingList(newList)
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