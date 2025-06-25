import SwiftUI
import PhotosUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    @StateObject private var settingsManager = UserSettingsManager.shared
    @State private var name: String
    @State private var brand: String
    @State private var quantity: Double
    @State private var unit: Unit
    @State private var category: ItemCategory
    @State private var priority: ItemPriority
    @State private var estimatedPrice: Double?
    @State private var notes: String
    @State private var selectedImage: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name)
        _brand = State(initialValue: item.brand ?? "")
        _quantity = State(initialValue: Double(truncating: item.quantity as NSDecimalNumber))
        _unit = State(initialValue: Unit(rawValue: item.unit ?? "") ?? .none)
        _category = State(initialValue: item.category)
        _priority = State(initialValue: item.priority)
        _estimatedPrice = State(initialValue: item.estimatedPrice.map { Double(truncating: $0 as NSDecimalNumber) })
        _notes = State(initialValue: item.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
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
                        Text("Estimated Price")
                        Spacer()
                        TextField("Price", value: $estimatedPrice, format: .currency(code: settingsManager.currency.rawValue))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                } header: {
                    Text("Price")
                } footer: {
                    Text("Set an estimated price for this item")
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
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Label("Select Image", systemImage: "photo")
                    }
                } header: {
                    Text("Image")
                } footer: {
                    Text("Add a photo of the item for easy identification")
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
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
            item.estimatedPrice = estimatedPrice.map { Decimal($0) }
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
