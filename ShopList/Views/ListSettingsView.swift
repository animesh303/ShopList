import SwiftUI

struct ListSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShoppingListViewModel
    @StateObject private var settingsManager = UserSettingsManager.shared
    let list: ShoppingList
    
    @State private var listName: String
    @State private var category: ListCategory
    @State private var budget: Double?
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
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("List Name", text: $listName)
                            .textContentType(.name)
                        
                        Picker(selection: $category) {
                            ForEach(ListCategory.allCases.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
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
                    } header: {
                        Text("List Details")
                    } footer: {
                        Text("Basic information about your shopping list")
                    }
                    
                    Section {
                        HStack {
                            Text(settingsManager.currency.symbol)
                            TextField("Budget Amount", value: $budget, format: .number)
                                .keyboardType(.decimalPad)
                                .onChange(of: budget) { oldValue, newValue in
                                    if let value = newValue, (value.isNaN || value.isInfinite) {
                                        budget = nil
                                    }
                                }
                        }
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
                
                // Update the list properties
                list.name = listName
                list.category = category
                list.budget = budget
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
