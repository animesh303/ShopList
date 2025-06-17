import SwiftUI
import AVFoundation
import UIKit
import PhotosUI
import SwiftData

// Extension to provide colors for categories
extension ItemCategory {
    var color: Color {
        switch self {
        // Food & Beverages
        case .groceries: return .blue
        case .dairy: return .blue.opacity(0.7)
        case .bakery: return .brown
        case .produce: return .green
        case .meat: return .red
        case .frozenFoods: return .blue.opacity(0.5)
        case .beverages: return .blue.opacity(0.9)
        case .snacks: return .orange.opacity(0.8)
        case .spices: return .orange.opacity(0.6)
            
        // Household
        case .household: return .orange
        case .cleaning: return .blue.opacity(0.3)
        case .laundry: return .blue.opacity(0.4)
        case .kitchen: return .orange.opacity(0.7)
        case .bathroom: return .blue.opacity(0.2)
        case .office: return .gray.opacity(0.5)
            
        // Personal Care
        case .personalCare: return .purple.opacity(0.7)
        case .beauty: return .pink.opacity(0.8)
        case .health: return .red.opacity(0.8)
        case .babyCare: return .pink.opacity(0.6)
        case .petCare: return .brown.opacity(0.6)
            
        // Other
        case .electronics: return .purple
        case .clothing: return .pink
        case .automotive: return .gray.opacity(0.7)
        case .garden: return .green.opacity(0.7)
        case .other: return .gray
        }
    }
}

// View for displaying item suggestions
private struct SuggestionsListView: View {
    let suggestions: [(name: String, category: ItemCategory)]
    let onSelect: ((name: String, category: ItemCategory)) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if suggestions.isEmpty {
                Text("No suggestions found")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            } else {
                Text("SUGGESTIONS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                
                ForEach(suggestions, id: \.name) { suggestion in
                    Button(action: { onSelect(suggestion) }) {
                        HStack {
                            Image(systemName: "arrow.up.left.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.caption)
                            
                            Text(suggestion.name.capitalized)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(suggestion.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(suggestion.category.color)
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if suggestion.name != suggestions.last?.name {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
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
    @State private var selectedImage: PhotosPickerItem?
    @State private var itemImage: Image?
    @State private var imageData: Data?
    
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
                Text(category.rawValue).tag(category)
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
            Form {
                Section {
                    VStack(spacing: 16) {
                        TextField("Item Name", text: $name)
                            .textContentType(.name)
                            .onChange(of: name) { _, newValue in
                                if !newValue.isEmpty {
                                    showingSuggestions = true
                                } else {
                                    showingSuggestions = false
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
                                Text(unit.displayName).tag(unit.rawValue)
                            }
                        }
                    }
                } header: {
                    Text("Item Details")
                } footer: {
                    Text("Enter the basic information about your item")
                }
                
                Section {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Estimated Price")
                            Spacer()
                            TextField("Price", value: $estimatedPrice, format: .currency(code: settingsManager.currency.rawValue))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
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
                } header: {
                    Text("Additional Information")
                } footer: {
                    Text("Add more details to help organize your items")
                }
                
                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                } header: {
                    Text("Notes")
                } footer: {
                    Text("Add any additional notes or reminders about this item")
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
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
                dateAdded: Date(),
                estimatedPrice: estimatedPrice.map { Decimal($0) },
                brand: brand.isEmpty ? nil : brand,
                unit: unit.isEmpty ? nil : unit,
                priority: priority
            )
            
            if let selectedImage = selectedImage {
                // TODO: Implement image saving with SwiftData
                // For now, we'll just add the item
            }
            
            // Add item to list
            list.addItem(item)
            
            // Update item history
            let lowercaseName = name.lowercased()
            let descriptor = FetchDescriptor<ItemHistory>(
                predicate: #Predicate { $0.lowercaseName == lowercaseName }
            )
            
            if let existingHistory = try modelContext.fetch(descriptor).first {
                // Update existing history
                existingHistory.usageCount += 1
                existingHistory.lastUsedDate = Date()
                existingHistory.brand = item.brand
                existingHistory.unit = item.unit
                existingHistory.estimatedPrice = item.estimatedPrice
            } else {
                // Create new history entry
                let history = ItemHistory(
                    name: name,
                    category: item.category,
                    brand: item.brand,
                    unit: item.unit,
                    estimatedPrice: item.estimatedPrice
                )
                modelContext.insert(history)
            }
            
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
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
    
    struct BarcodeScannerView: UIViewControllerRepresentable {
        @Binding var barcode: String?
        @Environment(\.dismiss) private var dismiss
        
        func makeUIViewController(context: Context) -> UIViewController {
            let viewController = UIViewController()
            let captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
            let videoInput: AVCaptureDeviceInput
            
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return viewController
            }
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                return viewController
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
            } else {
                return viewController
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = viewController.view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            viewController.view.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
            
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
            let parent: BarcodeScannerView
            
            init(_ parent: BarcodeScannerView) {
                self.parent = parent
            }
            
            func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
                if let metadataObject = metadataObjects.first {
                    guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                    guard let stringValue = readableObject.stringValue else { return }
                    parent.barcode = stringValue
                    parent.dismiss()
                }
            }
        }
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    let list = ShoppingList(name: "Preview List")
    
    return AddItemView(list: list)
        .modelContainer(container)
}
