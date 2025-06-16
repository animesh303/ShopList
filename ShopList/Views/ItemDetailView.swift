import SwiftUI
import PhotosUI

struct ItemDetailView: View {
    let item: Item
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    @StateObject private var settingsManager = UserSettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var brand: String
    @State private var quantity: Decimal
    @State private var unit: String
    @State private var category: ItemCategory
    @State private var priority: ItemPriority
    @State private var estimatedPrice: Decimal
    @State private var notes: String
    @State private var selectedImage: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(item: Item, list: ShoppingList, viewModel: ShoppingListViewModel) {
        self.item = item
        self.list = list
        self.viewModel = viewModel
        _name = State(initialValue: item.name)
        _brand = State(initialValue: item.brand ?? "")
        _quantity = State(initialValue: item.quantity)
        _unit = State(initialValue: item.unit ?? "")
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
                TextField("Unit", text: $unit)
            }
            Picker("Category", selection: $category) {
                ForEach(ItemCategory.allCases, id: \.self) { category in
                    Text("\(category.rawValue)").tag(category)
                }
            }
            Picker("Priority", selection: $priority) {
                ForEach(ItemPriority.allCases, id: \.self) { priority in
                    Text("\(priority.rawValue)").tag(priority)
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
        Task {
            do {
                item.name = name
                item.brand = brand.isEmpty ? nil : brand
                item.quantity = quantity
                item.unit = unit.isEmpty ? nil : unit
                item.category = category
                item.priority = priority
                item.estimatedPrice = estimatedPrice
                item.notes = notes.isEmpty ? nil : notes
                
                if let selectedImage = selectedImage {
                    if let imageURL = try await viewModel.saveImage(from: selectedImage) {
                        item.imageURL = imageURL
                    }
                }
                
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
    ItemDetailView(
        item: Item(name: "Sample Item", quantity: 1, category: .groceries, priority: .normal),
        list: ShoppingList(name: "Test List"),
        viewModel: ShoppingListViewModel()
    )
}
