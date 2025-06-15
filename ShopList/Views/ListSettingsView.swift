import SwiftUI

struct ListSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShoppingListViewModel
    let list: ShoppingList
    
    @State private var listName: String
    @State private var category: ListCategory
    @State private var budget: Decimal?
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
                        ForEach(ListCategory.allCases.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
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
                                if let value = newValue, (value.isNaN || value.isInfinite) {
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

#Preview {
    ListSettingsView(
        list: ShoppingList(name: "My List"),
        viewModel: ShoppingListViewModel()
    )
}
