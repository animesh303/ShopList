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
    @State private var quantity: Decimal
    @State private var unit: Unit
    @State private var category: ItemCategory
    @State private var priority: ItemPriority
    @State private var estimatedPrice: Decimal
    @State private var notes: String
    @State private var selectedImage: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name)
        _brand = State(initialValue: item.brand ?? "")
        _quantity = State(initialValue: item.quantity)
        _unit = State(initialValue: Unit(rawValue: item.unit ?? "") ?? .none)
        _category = State(initialValue: item.category)
        _priority = State(initialValue: item.priority)
        _estimatedPrice = State(initialValue: item.estimatedPrice ?? Decimal(0))
        _notes = State(initialValue: item.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    itemDetailsSection
                } header: {
                    Text("Item Details")
                }
                
                Section {
                    priceSection
                } header: {
                    Text("Price")
                }
                
                Section {
                    notesSection
                } header: {
                    Text("Notes")
                }
                
                Section {
                    imageSection
                } header: {
                    Text("Image")
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
    
    private var itemDetailsSection: some View {
        VStack(alignment: .leading) {
            TextField("Name", text: $name)
            TextField("Brand", text: $brand)
            HStack {
                TextField("Quantity", value: $quantity, format: .number)
                    .keyboardType(.decimalPad)
                Picker("Unit", selection: $unit) {
                    ForEach(Unit.allUnits, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
            }
            Picker("Category", selection: $category) {
                ForEach(ItemCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            Picker("Priority", selection: $priority) {
                ForEach(ItemPriority.allCases, id: \.self) { priority in
                    Text(priority.displayName).tag(priority)
                }
            }
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading) {
            TextField("Estimated Price", value: $estimatedPrice, format: .currency(code: settingsManager.currency.rawValue))
                .keyboardType(.decimalPad)
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $notes)
                .frame(minHeight: 100)
        }
    }
    
    private var imageSection: some View {
        VStack(alignment: .leading) {
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
            }
            
            PhotosPicker(selection: $selectedImage, matching: .images) {
                Label("Select Image", systemImage: "photo")
            }
        }
    }
    
    private func saveChanges() {
        do {
            item.name = name
            item.brand = brand.isEmpty ? nil : brand
            item.quantity = quantity
            item.unit = unit == .none ? nil : unit.rawValue
            item.category = category
            item.priority = priority
            item.estimatedPrice = estimatedPrice
            item.notes = notes.isEmpty ? nil : notes
            
            if let selectedImage = selectedImage {
                // TODO: Implement image saving with SwiftData
                // For now, we'll just dismiss
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
