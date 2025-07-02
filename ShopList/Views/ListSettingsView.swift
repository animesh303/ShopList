import SwiftUI

struct ListSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShoppingListViewModel
    @StateObject private var settingsManager = UserSettingsManager.shared
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    let list: ShoppingList
    
    @State private var listName: String
    @State private var category: ListCategory
    @State private var budget: Double?
    @State private var isTemplate: Bool
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingPremiumUpgrade = false
    
    init(list: ShoppingList, viewModel: ShoppingListViewModel) {
        self.list = list
        self.viewModel = viewModel
        _listName = State(initialValue: list.name)
        _category = State(initialValue: list.category)
        _budget = State(initialValue: list.budget)
        _isTemplate = State(initialValue: list.isTemplate)
    }
    
    private var availableCategories: [ListCategory] {
        subscriptionManager.getAvailableCategories()
    }
    
    private var budgetRow: some View {
        VStack(spacing: 8) {
            HStack {
                Text(settingsManager.currency.symbol)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                TextField("Budget Amount", value: $budget, format: .number)
                    .keyboardType(.decimalPad)
                    .disabled(!subscriptionManager.canUseBudgetTracking())
                    .onChange(of: budget) { oldValue, newValue in
                        if let value = newValue, (value.isNaN || value.isInfinite) {
                            budget = nil
                        }
                        
                        // Check if user is trying to set a budget without premium
                        if newValue != nil && !subscriptionManager.canUseBudgetTracking() {
                            budget = nil
                            showingPremiumUpgrade = true
                        }
                    }
                
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
                            .textContentType(.name)
                        
                        Picker(selection: $category) {
                            ForEach(availableCategories.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
                                HStack(spacing: 8) {
                                    Image(systemName: category.icon)
                                        .foregroundColor(category.color)
                                        .font(.title3)
                                        .frame(width: 20)
                                    Text(category.rawValue)
                                        .font(DesignSystem.Typography.body)
                                }
                                .tag(category)
                            }
                        } label: {
                            Text("Category")
                                .font(DesignSystem.Typography.body)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: category) { oldValue, newValue in
                            // Check if user is trying to use a premium category
                            if !subscriptionManager.canUseCategory(newValue) {
                                category = oldValue
                                showingPremiumUpgrade = true
                            }
                        }
                    } header: {
                        Text("List Details")
                    } footer: {
                        if !subscriptionManager.isPremium {
                            Text("Free users can only use basic categories. Upgrade to Premium for all 20+ categories.")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        } else {
                            Text("Basic information about your shopping list")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                    
                    Section {
                        budgetRow
                    } header: {
                        Text("Budget")
                    } footer: {
                        Text("Set a budget to track your spending")
                    }
                    
                    Section {
                        Toggle("Save as Template", isOn: $isTemplate)
                    } header: {
                        Text("Template")
                    } footer: {
                        Text("Templates can be used to quickly create new lists with predefined items")
                    }
                }
                .scrollContentBackground(.hidden)
                
                // FABs at the bottom
                VStack {
                    Spacer()
                    HStack {
                        // Cancel Button FAB at bottom left
                        VStack {
                            Spacer()
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(DesignSystem.Colors.error.opacity(0.8))
                                    .clipShape(Circle())
                                    .shadow(
                                        color: DesignSystem.Colors.error.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                        }
                        .padding(.leading, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                        
                        Spacer()
                        
                        // Save Button FAB at bottom right
                        VStack {
                            Spacer()
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                saveList()
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(!listName.isEmpty ? DesignSystem.Colors.success.opacity(0.8) : DesignSystem.Colors.tertiaryText.opacity(0.6))
                                    .clipShape(Circle())
                                    .shadow(
                                        color: !listName.isEmpty ? DesignSystem.Colors.success.opacity(0.4) : DesignSystem.Colors.tertiaryText.opacity(0.2),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                            .disabled(listName.isEmpty)
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
                style: .secondary,
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
