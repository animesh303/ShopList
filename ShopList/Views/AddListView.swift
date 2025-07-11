import SwiftUI
import SwiftData

struct AddListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var settingsManager = UserSettingsManager.shared
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
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
    
    var body: some View {
        ZStack {
            // Enhanced background with vibrant gradient
            DesignSystem.Colors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // List Details Card
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Header
                        HStack {
                            Image(systemName: "plus.square")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.primary)
                            Text("List Details")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                            Spacer()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        
                        // List Name Field
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("List Name")
                                .font(DesignSystem.Typography.subheadlineBold)
                                .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                            
                            TextField("Enter list name", text: $listName)
                                .font(DesignSystem.Typography.body)
                                .padding(DesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                        .fill(Color(.systemBackground).opacity(0.8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                                .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        
                        // Category Picker
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Category")
                                .font(DesignSystem.Typography.subheadlineBold)
                                .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                            
                            Menu {
                                ForEach(availableCategories.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { cat in
                                    Button(action: {
                                        if subscriptionManager.canUseCategory(cat) {
                                            category = cat
                                        } else {
                                            showingPremiumUpgrade = true
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: cat.icon)
                                                .foregroundColor(cat.color)
                                            Text(cat.rawValue)
                                            if !subscriptionManager.canUseCategory(cat) {
                                                Image(systemName: "crown.fill")
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(category.color)
                                        .font(.title3)
                                    Text(category.rawValue)
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                                }
                                .padding(DesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                        .fill(Color(.systemBackground).opacity(0.8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                                .stroke(category.color.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        
                        // Budget Field
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            HStack {
                                Text("Budget")
                                    .font(DesignSystem.Typography.subheadlineBold)
                                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                
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
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            HStack {
                                Text(settingsManager.currency.symbol)
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                
                                TextField("0.00", text: Binding(
                                    get: { budgetString },
                                    set: { newValue in
                                        if budgetString == "0.00" && newValue == "0.00" {
                                            budgetString = ""
                                        } else {
                                            budgetString = validateBudgetString(newValue)
                                        }
                                        
                                        if !newValue.isEmpty && !subscriptionManager.canUseBudgetTracking() {
                                            budgetString = ""
                                            showingPremiumUpgrade = true
                                        }
                                    }
                                ))
                                .keyboardType(.decimalPad)
                                .font(DesignSystem.Typography.body)
                                .disabled(!subscriptionManager.canUseBudgetTracking())
                            }
                            .padding(DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                    .fill(Color(.systemBackground).opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                            .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            if !subscriptionManager.canUseBudgetTracking() {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text("Upgrade to Premium for budget tracking")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .fill(Color(.systemBackground).opacity(0.92))
                            .shadow(color: DesignSystem.Colors.primary.opacity(0.15), radius: 16, x: 0, y: 8)
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Preview Card
                    VStack(spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Image(systemName: "eye")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.primary)
                            Text("Preview")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                            Spacer()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: category.icon)
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(DesignSystem.Colors.categoryGradient(for: category))
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm))
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text(listName.isEmpty ? "List Name" : listName)
                                    .font(DesignSystem.Typography.subheadlineBold)
                                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                
                                Text("Category: \(category.rawValue)")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                                
                                if let budget = budget, subscriptionManager.canUseBudgetTracking() {
                                    Text("Budget: \(budget, format: .currency(code: settingsManager.currency.rawValue))")
                                        .font(DesignSystem.Typography.caption1)
                                        .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(category.color.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                        .stroke(category.color.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .fill(Color(.systemBackground).opacity(0.92))
                            .shadow(color: DesignSystem.Colors.primary.opacity(0.15), radius: 16, x: 0, y: 8)
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Bottom spacing for FABs
                    Spacer(minLength: 100)
                }
            }
            
            // Enhanced Floating Action Buttons
            VStack {
                Spacer()
                HStack {
                    // Back Button FAB
                    VStack {
                        Spacer()
                        BackButtonFAB {
                            dismiss()
                        }
                    }
                    .padding(.leading, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                    
                    Spacer()
                    
                    // Add Button FAB
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
            style: .custom(DesignSystem.Colors.themeAwareCategoryGradient(for: category, colorScheme: colorScheme)),
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