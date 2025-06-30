import SwiftUI
import PhotosUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
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
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        VStack(spacing: 16) {
                            TextField("Name", text: $name)
                                .textContentType(.name)
                            
                            TextField("Brand", text: $brand)
                                .textContentType(.organizationName)
                            
                            HStack {
                                Text("Quantity")
                                Spacer()
                                TextField("Quantity", value: $quantity, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                            }
                            
                            Picker("Unit", selection: $unit) {
                                ForEach(Unit.allUnits, id: \.self) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                            
                            Picker("Category", selection: $category) {
                                ForEach(ItemCategory.allCases, id: \.self) { category in
                                    HStack {
                                        Image(systemName: category.icon)
                                            .foregroundColor(category.color)
                                        Text(category.rawValue)
                                    }
                                    .tag(category)
                                }
                            }
                            
                            Picker("Priority", selection: $priority) {
                                ForEach(ItemPriority.allCases, id: \.self) { priority in
                                    Text(priority.displayName).tag(priority)
                                }
                            }
                        }
                    } header: {
                        Text("Item Details")
                    } footer: {
                        Text("Basic information about your item")
                    }
                    
                    Section {
                        HStack {
                            Text("Price per unit")
                            Spacer()
                            TextField("Price", value: $pricePerUnit, format: .currency(code: settingsManager.currency.rawValue))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    } header: {
                        Text("Price")
                    } footer: {
                        Text("Set the price per unit for this item")
                    }
                    
                    Section {
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                    } header: {
                        Text("Notes")
                    } footer: {
                        Text("Add any additional notes or reminders about this item")
                    }
                    
                    Section {
                        if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        if subscriptionManager.canUseItemImages() {
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                Label("Select Image", systemImage: "photo")
                            }
                        } else {
                            Button {
                                upgradePromptMessage = subscriptionManager.getUpgradePrompt(for: .itemImages)
                                showingUpgradePrompt = true
                            } label: {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(DesignSystem.Colors.premium)
                                    Text("Upgrade to add photos")
                                        .foregroundColor(DesignSystem.Colors.premium)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("Image")
                            
                            if !subscriptionManager.canUseItemImages() {
                                Image(systemName: "crown.fill")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.premium)
                            }
                        }
                    } footer: {
                        if subscriptionManager.canUseItemImages() {
                            Text("Add a photo of the item for easy identification")
                        } else {
                            Text("Upgrade to Premium to add photos to your items")
                        }
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
                style: .info,
                showBanner: true
            )
            .navigationBarBackButtonHidden(true)
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
        .navigationBarBackButtonHidden(true)
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
