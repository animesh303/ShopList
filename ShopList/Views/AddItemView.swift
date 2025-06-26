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
            }
            .enhancedNavigation(
                title: "Add Item",
                subtitle: "Add a new item to your list",
                icon: "plus.circle",
                style: .success,
                showBanner: true
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.error)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Section Views
    
    private var imageSection: some View {
        Section {
            // Enhanced Image Picker Button
            Button(action: { showingImageOptions = true }) {
                if let itemImage = itemImage {
                    itemImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: DesignSystem.Shadows.colorfulMedium.color, radius: 8, x: 0, y: 4)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.title)
                            .foregroundColor(.white)
                        Text("Add Photo")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .frame(width: 120, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(DesignSystem.Colors.primaryButtonGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.3),
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
        } header: {
            Text("Item Photo")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
        } footer: {
            Text("Add a photo to help identify the item")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
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
                            Text(category.rawValue).tag(category)
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
                dateAdded: Date(),
                estimatedPrice: estimatedPrice.map { Decimal($0) },
                brand: brand.isEmpty ? nil : brand,
                unit: unit.isEmpty ? nil : unit,
                priority: priority
            )
            
            if let imageData = imageData {
                // Save image data to the item
                item.imageData = imageData
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
