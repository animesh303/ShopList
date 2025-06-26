import SwiftUI
import SwiftData

struct AddListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    @State private var listName = ""
    @State private var category: ListCategory = .groceries
    @State private var budgetString = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var budget: Double? {
        guard !budgetString.isEmpty else { return nil }
        return Double(budgetString)
    }
    
    private var isFormValid: Bool {
        !listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func validateBudgetString(_ input: String) -> String {
        let filtered = input.filter { "0123456789.".contains($0) }
        let components = filtered.components(separatedBy: ".")
        if components.count > 2 {
            return String(components.prefix(2).joined(separator: "."))
        }
        return filtered
    }
    
    private var budgetRow: some View {
        HStack {
            Text(settingsManager.currency.symbol)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
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
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("List Name", text: $listName)
                            .font(DesignSystem.Typography.body)
                        
                        Picker("Category", selection: $category) {
                            ForEach(ListCategory.allCases.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(category.color)
                                        .font(.title3)
                                    Text(category.rawValue)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        budgetRow
                    } header: {
                        Text("List Details")
                            .font(DesignSystem.Typography.subheadlineBold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(category.color)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Preview")
                                    .font(DesignSystem.Typography.subheadlineBold)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                Text("Category: \(category.rawValue)")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                if let budget = budget {
                                    Text("Budget: \(budget, format: .currency(code: settingsManager.currency.rawValue))")
                                        .font(DesignSystem.Typography.caption1)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(DesignSystem.Spacing.sm)
                        .background(category.color.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.sm)
                    } header: {
                        Text("Preview")
                            .font(DesignSystem.Typography.subheadlineBold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                }
                .scrollContentBackground(.hidden)
                
                // Back Button FAB at bottom left
                VStack {
                    Spacer()
                    HStack {
                        BackButtonFAB {
                            dismiss()
                        }
                        .padding(.leading, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                        
                        Spacer()
                    }
                }
            }
            .enhancedNavigation(
                title: "New List",
                subtitle: "Create a new shopping list",
                icon: "plus.square",
                style: .primary,
                showBanner: true
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addList()
                    }
                    .disabled(!isFormValid)
                    .foregroundColor(isFormValid ? DesignSystem.Colors.primary : DesignSystem.Colors.tertiaryText)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addList() {
        let trimmedName = listName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            alertMessage = "Please enter a list name"
            showingAlert = true
            return
        }
        
        let newList = ShoppingList(
            name: trimmedName,
            category: category,
            budget: budget
        )
        
        modelContext.insert(newList)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to create list: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    AddListView()
        .modelContainer(for: ShoppingList.self, inMemory: true)
} 