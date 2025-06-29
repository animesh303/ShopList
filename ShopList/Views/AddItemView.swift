import SwiftUI
import UIKit
import PhotosUI
import SwiftData

// Extension to provide colors for categories
extension ItemCategory {
    var color: Color {
        switch self {
        // Food & Beverages
        case .groceries: return DesignSystem.Colors.categoryGroceries
        case .dairy: return DesignSystem.Colors.categoryGroceries.opacity(0.8)
        case .bakery: return DesignSystem.Colors.categoryGroceries.opacity(0.9)
        case .produce: return DesignSystem.Colors.categoryGroceries.opacity(0.7)
        case .meat: return DesignSystem.Colors.categoryHealth.opacity(0.8)
        case .frozenFoods: return DesignSystem.Colors.categoryGroceries.opacity(0.6)
        case .beverages: return DesignSystem.Colors.categoryGroceries.opacity(0.9)
        case .snacks: return DesignSystem.Colors.categoryClothing.opacity(0.8)
        case .spices: return DesignSystem.Colors.categoryClothing.opacity(0.6)
            
        // Household
        case .household: return DesignSystem.Colors.categoryHousehold
        case .cleaning: return DesignSystem.Colors.categoryHousehold.opacity(0.7)
        case .laundry: return DesignSystem.Colors.categoryHousehold.opacity(0.8)
        case .kitchen: return DesignSystem.Colors.categoryHousehold.opacity(0.9)
        case .bathroom: return DesignSystem.Colors.categoryHousehold.opacity(0.6)
        case .office: return DesignSystem.Colors.categoryOffice
            
        // Personal Care
        case .personalCare: return DesignSystem.Colors.categoryPersonalCare
        case .beauty: return DesignSystem.Colors.categoryPersonalCare.opacity(0.9)
        case .health: return DesignSystem.Colors.categoryHealth
        case .babyCare: return DesignSystem.Colors.categoryBaby
        case .petCare: return DesignSystem.Colors.categoryPet
            
        // Other
        case .electronics: return DesignSystem.Colors.categoryElectronics
        case .clothing: return DesignSystem.Colors.categoryClothing
        case .automotive: return DesignSystem.Colors.categoryAutomotive
        case .garden: return DesignSystem.Colors.categoryGarden
        case .other: return DesignSystem.Colors.categoryOther
        }
    }
    
    // Enhanced gradient for categories
    var gradient: LinearGradient {
        return DesignSystem.Colors.categoryGradient(for: self)
    }
}

// View for displaying item suggestions
private struct SuggestionsListView: View {
    let suggestions: [(name: String, category: ItemCategory)]
    let onSelect: ((name: String, category: ItemCategory)) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if suggestions.isEmpty {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .font(.caption)
                    Text("No suggestions found")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(DesignSystem.Colors.warning)
                            .font(.caption)
                        Text("SUGGESTIONS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    
                    ForEach(suggestions, id: \.name) { suggestion in
                        Button(action: { onSelect(suggestion) }) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.up.left.circle.fill")
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .font(.caption)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.name.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Text(suggestion.category.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        suggestion.category.gradient
                                    )
                                    .cornerRadius(8)
                                    .shadow(
                                        color: suggestion.category.color.opacity(0.3),
                                        radius: 3,
                                        x: 0,
                                        y: 1
                                    )
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if suggestion.name != suggestions.last?.name {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.cardGradient)
                .shadow(color: DesignSystem.Shadows.colorfulSmall.color, radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
}

// Field type for focus management
private enum Field: Hashable {
    case name, price, brand, unit, notes
}

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var list: ShoppingList
    @Query private var allLists: [ShoppingList]
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var name = ""
    @State private var quantity = 1.0
    @State private var unit = ""
    @State private var brand = ""
    @State private var estimatedPrice: Double?
    @State private var category: ItemCategory = .other
    @State private var notes = ""
    @State private var priority: ItemPriority = .normal
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuggestions = false
    @State private var selectedSuggestions: Set<String> = []
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var itemImage: Image?
    @State private var imageData: Data?
    @State private var showingImageOptions = false
    @State private var showingUpgradePrompt = false
    @State private var upgradePromptMessage = ""
    
    @FocusState private var focusedField: Field?
    
    private var quantityField: some View {
        HStack {
            Text("Quantity")
            Spacer()
            TextField("Quantity", value: $quantity, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
        }
    }
    
    private var priceField: some View {
        HStack {
            Text("Estimated Price")
            Spacer()
            TextField("Price", value: $estimatedPrice, format: .currency(code: settingsManager.currency.rawValue))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
        }
    }
    
    private var unitPicker: some View {
        Picker("Unit", selection: $unit) {
            ForEach(Unit.allUnits, id: \.self) { unit in
                Text(unit.displayName).tag(unit.rawValue)
            }
        }
    }
    
    private var categoryPicker: some View {
        Picker("Category", selection: $category) {
            ForEach(ItemCategory.allCases, id: \.self) { category in
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
    }
    
    private var priorityPicker: some View {
        Picker("Priority", selection: $priority) {
            ForEach(ItemPriority.allCases, id: \.self) { priority in
                Text(priority.displayName).tag(priority)
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
                    imageSection
                    itemDetailsSection
                    additionalInfoSection
                    notesSection
                }
                .scrollContentBackground(.hidden)
                
                // FABs at bottom
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
                        
                        // Add Button FAB at bottom right
                        VStack {
                            Spacer()
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                addItem()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(
                                        !name.isEmpty ? DesignSystem.Colors.success.opacity(0.8) : DesignSystem.Colors.tertiaryText.opacity(0.6)
                                    )
                                    .clipShape(Circle())
                                    .shadow(
                                        color: !name.isEmpty ? DesignSystem.Colors.success.opacity(0.4) : DesignSystem.Colors.tertiaryText.opacity(0.2),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                            .disabled(name.isEmpty)
                        }
                        .padding(.trailing, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                    }
                }
            }
            .enhancedNavigation(
                title: "Add Item",
                subtitle: "Add a new item to your list",
                icon: "plus.circle",
                style: .success,
                showBanner: true
            )
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Upgrade to Premium", isPresented: $showingUpgradePrompt) {
                Button("Upgrade") {
                    // Show premium upgrade view
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(upgradePromptMessage)
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
                        .shadow(color: DesignSystem.Shadows.colorfulMedium.color, radius: 8, x: 0, y: 4)
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
                CameraView(image: $itemImage, imageData: $imageData)
            }
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                        if let uiImage = UIImage(data: data) {
                            itemImage = Image(uiImage: uiImage)
                        }
                    }
                }
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
                        .onChange(of: name) { _, newValue in
                            if !newValue.isEmpty {
                                showingSuggestions = true
                            } else {
                                showingSuggestions = false
                            }
                        }
                }
                
                if showingSuggestions {
                    SuggestionsListView(
                        suggestions: getSuggestions(for: name),
                        onSelect: { suggestion in
                            onSuggestionSelected(suggestion)
                        }
                    )
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
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        TextField("0", value: $quantity, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Picker("Unit", selection: $unit) {
                            ForEach(Unit.allUnits, id: \.self) { unit in
                                Text(unit.displayName).tag(unit.rawValue)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(DesignSystem.Colors.secondaryBackground)
                        .cornerRadius(8)
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
                .foregroundColor(.secondary)
        }
    }
    
    private var additionalInfoSection: some View {
        Section {
            VStack(spacing: 20) {
                // Enhanced Price field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estimated Price")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    TextField("0.00", value: $estimatedPrice, format: .currency(code: settingsManager.currency.rawValue))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                // Enhanced Category picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
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
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Enhanced Priority picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Priority")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Picker("Priority", selection: $priority) {
                        ForEach(ItemPriority.allCases, id: \.self) { priority in
                            priorityRow(for: priority)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        } header: {
            Text("Additional Information")
                .font(.headline)
                .foregroundColor(.primary)
        } footer: {
            Text("Add more details to help organize your items")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var notesSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        } header: {
            Text("Notes")
                .font(.headline)
                .foregroundColor(.primary)
        } footer: {
            Text("Add any additional notes or reminders about this item")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Views
    
    private func priorityRow(for priority: ItemPriority) -> some View {
        HStack {
            let (iconName, iconColor) = getPriorityIconAndColor(for: priority)
            
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            Text(priority.displayName)
        }
        .tag(priority)
    }
    
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
    
    private func getSuggestions(for query: String) -> [(name: String, category: ItemCategory)] {
        print("Getting suggestions for query: \(query)")
        
        // Compute lowercase query before creating predicate
        let lowercaseQuery = query.lowercased()
        
        // Fetch matching items from history
        let descriptor = FetchDescriptor<ItemHistory>(
            predicate: #Predicate { $0.lowercaseName.contains(lowercaseQuery) },
            sortBy: [SortDescriptor(\.usageCount, order: .reverse), SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        
        do {
            let historyItems = try modelContext.fetch(descriptor)
            print("Found \(historyItems.count) suggestions in history")
            
            // Convert to the format expected by the view
            return historyItems.prefix(5).map { history in
                (name: history.name, category: history.category)
            }
        } catch {
            print("Error fetching suggestions: \(error)")
            return []
        }
    }
    
    private func addItem() {
        do {
            let item = Item(
                name: name,
                quantity: Decimal(quantity),
                category: category,
                isCompleted: false,
                notes: notes.isEmpty ? nil : notes,
                estimatedPrice: estimatedPrice.map { Decimal($0) },
                brand: brand.isEmpty ? nil : brand,
                unit: unit.isEmpty ? nil : unit,
                imageData: imageData,
                priority: priority
            )
            
            list.items.append(item)
            
            // Add to item history for suggestions
            let history = ItemHistory(
                name: name,
                category: item.category,
                brand: item.brand,
                unit: item.unit,
                estimatedPrice: item.estimatedPrice
            )
            modelContext.insert(history)
            
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func detectCategory(from productName: String) -> ItemCategory? {
        let lowercasedName = productName.lowercased()
        
        // Food categories
        if lowercasedName.contains("banana") || lowercasedName.contains("apple") || lowercasedName.contains("fruit") {
            return .produce
        }
        if lowercasedName.contains("bread") || lowercasedName.contains("cake") || lowercasedName.contains("pastry") {
            return .bakery
        }
        if lowercasedName.contains("milk") || lowercasedName.contains("cheese") || lowercasedName.contains("yogurt") {
            return .dairy
        }
        if lowercasedName.contains("meat") || lowercasedName.contains("chicken") || lowercasedName.contains("beef") {
            return .meat
        }
        if lowercasedName.contains("frozen") || lowercasedName.contains("ice cream") {
            return .frozenFoods
        }
        if lowercasedName.contains("drink") || lowercasedName.contains("soda") || lowercasedName.contains("juice") {
            return .beverages
        }
        if lowercasedName.contains("snack") || lowercasedName.contains("chips") || lowercasedName.contains("candy") {
            return .snacks
        }
        
        // Default to groceries for food items
        return .groceries
    }
    
    private func onSuggestionSelected(_ suggestion: (name: String, category: ItemCategory)) {
        name = suggestion.name
        category = suggestion.category
        
        // Compute lowercase name before creating predicate
        let lowercaseName = suggestion.name.lowercased()
        
        // Find the most recent item with this name from history
        let descriptor = FetchDescriptor<ItemHistory>(
            predicate: #Predicate { $0.lowercaseName == lowercaseName },
            sortBy: [SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        
        do {
            if let recentItem = try modelContext.fetch(descriptor).first {
                // Populate fields from the history
                brand = recentItem.brand ?? ""
                unit = recentItem.unit ?? ""
                if let price = recentItem.estimatedPrice {
                    estimatedPrice = Double(truncating: price as NSDecimalNumber)
                }
            }
        } catch {
            print("Error fetching item history: \(error)")
        }
        
        showingSuggestions = false
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        @Environment(\.dismiss) private var dismiss
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.image = image
                }
                parent.dismiss()
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                parent.dismiss()
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = Image(uiImage: uiImage)
                parent.imageData = uiImage.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    let list = ShoppingList(name: "Preview List")
    
    return AddItemView(list: list)
        .modelContainer(container)
}
