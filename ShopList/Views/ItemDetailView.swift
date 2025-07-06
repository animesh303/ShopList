import SwiftUI
import PhotosUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var item: Item
    @StateObject private var settingsManager = UserSettingsManager.shared
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var name: String
    @State private var brand: String
    @State private var quantity: Double
    @State private var unit: Unit
    @State private var category: ItemCategory
    @State private var priority: ItemPriority
    @State private var pricePerUnit: Double?
    @State private var notes: String
    @State private var selectedImage: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingUpgradePrompt = false
    @State private var upgradePromptMessage = ""
    @State private var showingPremiumUpgrade = false
    @State private var showingImageOptions = false
    @State private var showingCamera = false
    @State private var itemImage: Image?
    
    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name)
        _brand = State(initialValue: item.brand ?? "")
        _quantity = State(initialValue: Double(truncating: item.quantity as NSDecimalNumber))
        _unit = State(initialValue: Unit(rawValue: item.unit ?? "") ?? .none)
        _category = State(initialValue: item.category)
        _priority = State(initialValue: item.priority)
        _pricePerUnit = State(initialValue: item.pricePerUnit.map { Double(truncating: $0 as NSDecimalNumber) })
        _notes = State(initialValue: item.notes ?? "")
        
        // Initialize item image if available
        if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
            _itemImage = State(initialValue: Image(uiImage: uiImage))
        }
    }
    
    private var totalCost: Double {
        guard let price = pricePerUnit, price > 0 else { return 0 }
        return price * quantity
    }
    
    private var currencyIcon: String {
        return settingsManager.currency.icon
    }
    
    var body: some View {
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
            List {
                imageSection
                itemDetailsSection
                additionalInfoSection
                notesSection
                }
                .scrollContentBackground(.hidden)
                
            // Enhanced Floating Action Buttons with consistent design
                VStack {
                    Spacer()
                    HStack {
                    // Back Button FAB at bottom left
                        VStack {
                            Spacer()
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                                dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                .background(
                                    DesignSystem.Colors.error.opacity(0.8)
                                )
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
                                saveChanges()
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(
                                        DesignSystem.Colors.success.opacity(0.8)
                                    )
                                    .clipShape(Circle())
                                    .shadow(
                                        color: DesignSystem.Colors.success.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                        }
                        .padding(.trailing, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                    }
                }
            }
            .enhancedNavigation(
                title: "Edit Item",
                subtitle: "Modify item details",
                icon: "pencil.circle",
            style: .custom(DesignSystem.Colors.themeAwareCategoryGradient(for: category, colorScheme: colorScheme)),
                showBanner: true
            )
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Upgrade to Premium", isPresented: $showingUpgradePrompt) {
                Button("Upgrade") {
                    showingPremiumUpgrade = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(upgradePromptMessage)
            }
            .sheet(isPresented: $showingPremiumUpgrade) {
                PremiumUpgradeView()
            }
        .onChange(of: selectedImage) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        itemImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
    
    // MARK: - Section Views
    
    private var imageSection: some View {
        Section {
            // Enhanced Image Picker Button
            Button(action: { 
                if subscriptionManager.canUseItemImages() {
                    showingImageOptions = true
                } else {
                    upgradePromptMessage = subscriptionManager.getUpgradePrompt(for: .itemImages)
                    showingUpgradePrompt = true
                }
            }) {
                if let itemImage = itemImage {
                    itemImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: subscriptionManager.canUseItemImages() ? "photo.badge.plus" : "crown.fill")
                            .font(.title)
                            .foregroundColor(.white)
                        Text(subscriptionManager.canUseItemImages() ? "Add Photo" : "Premium Feature")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        if !subscriptionManager.canUseItemImages() {
                            Text("Upgrade to add photos")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(width: 120, height: 120)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(subscriptionManager.canUseItemImages() ? DesignSystem.Colors.primaryButtonGradient : DesignSystem.Colors.premiumGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(subscriptionManager.canUseItemImages() ? DesignSystem.Colors.primary.opacity(0.3) : DesignSystem.Colors.premium.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .shadow(
                        color: subscriptionManager.canUseItemImages() ? DesignSystem.Colors.primary.opacity(0.3) : DesignSystem.Colors.premium.opacity(0.3),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .confirmationDialog("Choose Image Source", isPresented: $showingImageOptions) {
                Button("Camera") {
                    showingCamera = true
                }
                Button("Photo Library") {
                    showingImagePicker = true
                }
                Button("Cancel", role: .cancel) { }
            }
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedImage, matching: .images)
            .sheet(isPresented: $showingCamera) {
                CameraView(image: $itemImage, imageData: .constant(nil))
            }
            
            // Centered footer text
            HStack {
                Spacer()
                if subscriptionManager.canUseItemImages() {
                    if itemImage != nil {
                        Text("Tap to change the photo")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    } else {
                        Text("Add a photo to help identify the item")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                } else {
                    Text("Upgrade to Premium to add photos to your items")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                Spacer()
            }
            .padding(.top, 8)
        } header: {
            HStack {
                Text("Item Photo")
                    .font(.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                if !subscriptionManager.canUseItemImages() {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.premium)
                }
            }
        }
        .listRowBackground(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primary.opacity(0.2),
                    DesignSystem.Colors.primaryLight.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var itemDetailsSection: some View {
        Section {
            VStack(spacing: 20) {
                // Enhanced Item Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Item Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    TextField("Enter item name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.name)
                }
                
                // Enhanced Brand field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Brand")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    TextField("Enter brand name", text: $brand)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.organizationName)
                }
                
                // Enhanced Quantity and Unit
                VStack(spacing: 20) {
                    // Quantity Field - Settings Style
                    HStack {
                        Text("Quantity")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Spacer()
                        
                        TextField("0", value: $quantity, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onTapGesture {
                                // Clear field on tap for easier editing
                                if quantity == 1.0 {
                                    quantity = 0
                                }
                            }
                        
                        Stepper("", value: $quantity, in: 1.0...999.9, step: 0.5)
                            .labelsHidden()
                    }

                    // Unit Picker - Settings Style
                    Picker(selection: $unit) {
                        ForEach(subscriptionManager.getAvailableUnits(), id: \.self) { unit in
                            HStack(spacing: 8) {
                                Image(systemName: unit.icon)
                                    .foregroundColor(unit.color)
                                    .font(.title3)
                                    .frame(width: 20)
                                Text(unit.displayName)
                                    .font(DesignSystem.Typography.body)
                            }
                            .tag(unit)
                        }
                    } label: {
                        HStack {
                            Text("Unit")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            if !subscriptionManager.isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.premium)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: unit) { _, newUnit in
                        if !subscriptionManager.canUseUnit(newUnit) {
                            upgradePromptMessage = subscriptionManager.getUpgradePrompt(for: .allUnits)
                            showingUpgradePrompt = true
                            // Reset to a free unit
                            unit = subscriptionManager.getAvailableUnits().first ?? .none
                        }
                    }
                }
            }
        } header: {
            Text("Item Details")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
        } footer: {
            Text("Enter the basic information about your item")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .listRowBackground(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.accent2.opacity(0.2),
                    DesignSystem.Colors.accent2.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var additionalInfoSection: some View {
        Section {
            VStack(spacing: 20) {
                // Price Field - Settings Style
                HStack {
                    Text("Price per unit")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: currencyIcon)
                            .font(.title3)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        TextField("0.00", value: $pricePerUnit, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // Total Cost Field - Settings Style
                if pricePerUnit != nil && pricePerUnit! > 0 {
                    HStack {
                        Text("Total Cost")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(totalCost.formatted(.currency(code: settingsManager.currency.rawValue)))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.primary)
                            
                            Text("\(quantity, specifier: "%.1f") × \(pricePerUnit!.formatted(.currency(code: settingsManager.currency.rawValue)))")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(DesignSystem.Colors.primary.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Category Picker - Settings Style
                Picker(selection: $category) {
                    ForEach(subscriptionManager.getAvailableItemCategories(), id: \.self) { category in
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
                    HStack {
                        Text("Category")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        if !subscriptionManager.isPremium {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.premium)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: category) { _, newCategory in
                    if !subscriptionManager.canUseItemCategory(newCategory) {
                        upgradePromptMessage = subscriptionManager.getUpgradePrompt(for: .allCategories)
                        showingUpgradePrompt = true
                        // Reset to a free category
                        category = subscriptionManager.getAvailableItemCategories().first ?? .other
                    }
                }
                
                // Priority Picker - Settings Style
                Picker(selection: $priority) {
                    ForEach(ItemPriority.allCases, id: \.self) { priority in
                        HStack(spacing: 8) {
                            let (iconName, iconColor) = getPriorityIconAndColor(for: priority)
                            Image(systemName: iconName)
                                .foregroundColor(iconColor)
                                .font(.title3)
                                .frame(width: 20)
                            Text(priority.displayName)
                                .font(DesignSystem.Typography.body)
                        }
                        .tag(priority)
                    }
                } label: {
                    Text("Priority")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }
                .pickerStyle(MenuPickerStyle())
            }
        } header: {
            Text("Additional Information")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
        } footer: {
            Text("Add more details to help organize your items")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .listRowBackground(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.accent1.opacity(0.2),
                    DesignSystem.Colors.accent1.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var notesSection: some View {
        Section {
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(8)
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(8)
        } header: {
            Text("Notes")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
        } footer: {
            Text("Add any additional notes or reminders about this item")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .listRowBackground(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.secondary.opacity(0.2),
                    DesignSystem.Colors.secondaryLight.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Helper Methods
    
    private func getPriorityIconAndColor(for priority: ItemPriority) -> (iconName: String, color: Color) {
        switch priority {
        case .high:
            return ("exclamationmark.circle.fill", .red)
        case .normal:
            return ("circle.fill", .blue)
        case .low:
            return ("circle", .gray)
        }
    }
    
    private func saveChanges() {
        do {
            item.name = name
            item.brand = brand.isEmpty ? nil : brand
            item.quantity = Decimal(quantity)
            item.unit = unit == .none ? nil : unit.rawValue
            item.category = category
            item.priority = priority
            item.pricePerUnit = pricePerUnit.map { Decimal($0) }
            item.notes = notes.isEmpty ? nil : notes
            
            if let selectedImage = selectedImage {
                Task {
                    do {
                        if let data = try await selectedImage.loadTransferable(type: Data.self) {
                            item.imageData = data
                        }
                    } catch {
                        errorMessage = "Failed to load image: \(error.localizedDescription)"
                        showingError = true
                    }
                }
            }
            
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    let item = Item(name: "Sample Item", quantity: 1, category: .groceries, priority: .normal)
    
    return ItemDetailView(item: item)
        .modelContainer(container)
}
