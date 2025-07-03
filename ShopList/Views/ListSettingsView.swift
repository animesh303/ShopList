import SwiftUI

struct ListSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ShoppingListViewModel
    @StateObject private var settingsManager = UserSettingsManager.shared
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    let list: ShoppingList
    
    @State private var listName: String
    @State private var category: ListCategory
    @State private var budgetString: String
    @State private var isTemplate: Bool
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingPremiumUpgrade = false
    
    init(list: ShoppingList, viewModel: ShoppingListViewModel) {
        self.list = list
        self.viewModel = viewModel
        _listName = State(initialValue: list.name)
        _category = State(initialValue: list.category)
        _budgetString = State(initialValue: list.budget != nil ? String(format: "%.2f", list.budget!) : "")
        _isTemplate = State(initialValue: list.isTemplate)
    }
    
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
                            Image(systemName: "list.bullet")
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
                                
                                if isTemplate {
                                    Text("Template: Yes")
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
                    
                    // Template Settings Card
                    VStack(spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.primary)
                            Text("Template Settings")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                            Spacer()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Save as Template")
                                    .font(DesignSystem.Typography.subheadlineBold)
                                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                                Text("Templates can be used to quickly create new lists with predefined items")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $isTemplate)
                                .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primary))
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
                    
                    // Save Button FAB
                    VStack {
                        Spacer()
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            saveList()
                        } label: {
                            Image(systemName: "checkmark")
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
            title: "List Settings",
            subtitle: "Configure list preferences",
            icon: "slider.horizontal.3",
            style: .custom(DesignSystem.Colors.themeAwareCategoryGradient(for: category, colorScheme: colorScheme)),
            showBanner: true
        )
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingPremiumUpgrade) {
            PremiumUpgradeView()
        }
    }
    
    private func saveList() {
        Task {
            do {
                guard !listName.isEmpty else {
                    throw AppError.invalidListName
                }
                
                // Check if the new name conflicts with another list
                if listName != list.name {
                    if await viewModel.findListInfo(byName: listName) != nil {
                        throw AppError.listAlreadyExists
                    }
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
                
                // Update the list properties
                list.name = listName
                list.category = category
                list.budget = subscriptionManager.canUseBudgetTracking() ? budget : nil
                list.isTemplate = isTemplate
                
                try await viewModel.updateShoppingList(list)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
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
