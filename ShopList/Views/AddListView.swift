import SwiftUI

struct AddListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShoppingListViewModel
    @StateObject private var settingsManager = UserSettingsManager.shared
    @State private var listName = ""
    @State private var category: ListCategory = .personal
    @State private var budgetString = "0.00"
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var budget: Decimal? {
        guard !budgetString.isEmpty else { return nil }
        return Decimal(string: budgetString)
    }
    
    private func validateBudgetString(_ newValue: String) -> String {
        // Allow only numbers and one decimal point
        let filtered = newValue.filter { "0123456789.".contains($0) }
        
        // Handle empty input
        if filtered.isEmpty {
            return "0.00"
        }
        
        // Handle leading decimal point
        if filtered == "." {
            return "0."
        }
        
        let components = filtered.components(separatedBy: ".")
        
        // If more than one decimal point, keep only the first one
        if components.count > 2 {
            let firstPart = components[0]
            let decimalPart = components[1...].joined()
            return "\(firstPart).\(decimalPart)"
        }
        
        // Limit to 7 digits before decimal
        if let first = components.first, first.count > 7 {
            return String(first.prefix(7)) + (components.count > 1 ? ".\(components[1])" : "")
        }
        
        // Limit to 2 decimal places
        if components.count == 2, let last = components.last, last.count > 2 {
            return "\(components[0]).\(last.prefix(2))"
        }
        
        return filtered
    }
    
    private var budgetRow: some View {
        HStack {
            Text(settingsManager.currency.symbol)
            TextField("Budget", text: Binding(
                get: { budgetString },
                set: { newValue in
                    if budgetString == "0.00" && newValue == "0.00" {
                        budgetString = ""
                    } else {
                        budgetString = validateBudgetString(newValue)
                    }
                }
            ))
            .keyboardType(.decimalPad)
        }
    }
    
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
                    budgetRow
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
                                    category: category,
                                    budget: budget != nil ? Double(truncating: budget! as NSNumber) : 0
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