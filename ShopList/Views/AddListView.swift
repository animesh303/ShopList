import SwiftUI
import SwiftData

struct AddListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var listName = ""
    @State private var category: ListCategory = .groceries
    @State private var budgetString = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingUpgradePrompt = false
    @State private var showingPremiumUpgrade = false
    
    private var budget: Double? {
        guard !budgetString.isEmpty else { return nil }
        return Double(budgetString)
    }
    
    private var isFormValid: Bool {
        !listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var availableCategories: [ListCategory] {
        subscriptionManager.getAvailableCategories()
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
        VStack(spacing: 8) {
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
                .disabled(!subscriptionManager.canUseBudgetTracking())
                
                if !subscriptionManager.canUseBudgetTracking() {
                    Button(action: {
                        showingPremiumUpgrade = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                            Text("Upgrade")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [DesignSystem.Colors.warning, DesignSystem.Colors.warning.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(
                            color: DesignSystem.Colors.warning.opacity(0.3),
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if !subscriptionManager.canUseBudgetTracking() {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Upgrade to Premium for budget tracking")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Spacer()
                }
            }
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
                            ForEach(availableCategories.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(category.color)
                                        .font(.title2)
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
                    } footer: {
                        if !subscriptionManager.isPremium {
                            Text("Free users can only use basic categories. Upgrade to Premium for all 20+ categories.")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(category.color)
                                .font(.title)
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Preview")
                                    .font(DesignSystem.Typography.subheadlineBold)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                Text("Category: \(category.rawValue)")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                if let budget = budget, subscriptionManager.canUseBudgetTracking() {
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
                        VStack {
                            Spacer()
                            BackButtonFAB {
                                dismiss()
                            }
                        }
                        .padding(.leading, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                        
                        Spacer()
                        
                        // Add Button FAB at bottom right
                        VStack {
                            Spacer()
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                addList()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(
                                        isFormValid ? DesignSystem.Colors.primaryButtonGradient : LinearGradient(
                                            colors: [
                                                DesignSystem.Colors.tertiaryText.opacity(0.6),
                                                DesignSystem.Colors.tertiaryText.opacity(0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(
                                        color: isFormValid ? DesignSystem.Colors.primary.opacity(0.4) : DesignSystem.Colors.tertiaryText.opacity(0.2),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                            .disabled(!isFormValid)
                        }
                        .padding(.trailing, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
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
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingPremiumUpgrade) {
                PremiumUpgradeView()
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
        
        // Check if user can create a list
        guard subscriptionManager.canCreateList() else {
            showingPremiumUpgrade = true
            return
        }
        
        // Check if user can use the selected category
        guard subscriptionManager.canUseCategory(category) else {
            showingPremiumUpgrade = true
            return
        }
        
        // Check if user can use budget tracking
        if budget != nil && !subscriptionManager.canUseBudgetTracking() {
            showingPremiumUpgrade = true
            return
        }
        
        let newList = ShoppingList(
            name: trimmedName,
            category: category,
            budget: subscriptionManager.canUseBudgetTracking() ? budget : nil
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