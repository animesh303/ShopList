import SwiftUI
import AVFoundation
import UIKit

// Extension to provide colors for categories
extension ItemCategory {
    var color: Color {
        switch self {
        case .groceries: return .blue
        case .dairy: return .blue.opacity(0.7)
        case .bakery: return .brown
        case .produce: return .green
        case .meat: return .red
        case .household: return .orange
        case .electronics: return .purple
        case .clothing: return .pink
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
    @Environment(\.dismiss) private var dismiss
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    
    @State private var itemName = ""
    @State private var quantityString = "1"
    @State private var category: ItemCategory = .other
    @State private var priority: ItemPriority = .normal
    @State private var estimatedPriceString = ""
    @State private var brand: String = ""
    @State private var unit: String = ""
    @State private var notes: String = ""
    
    private var quantity: Decimal {
        return Decimal(string: quantityString) ?? 1
    }
    
    private var estimatedPrice: Decimal? {
        guard !estimatedPriceString.isEmpty else { return nil }
        return Decimal(string: estimatedPriceString)
    }
    @State private var showSuggestions = false
    @State private var selectedSuggestion: Item? = nil
    @State private var showingError = false
    @State private var errorMessage = ""
    
    @FocusState private var focusedField: Field?
    
    private var isFormValid: Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $itemName)
                        .focused($focusedField, equals: .name)
                        .onAppear {
                            focusedField = .name
                        }
                    
                    // Show suggestions if available
                    if showSuggestions {
                        let suggestions = viewModel.getSuggestions(for: itemName)
                        if !suggestions.isEmpty {
                            let suggestionItems = suggestions.map { ($0.name, $0.category) }
                            SuggestionsListView(suggestions: suggestionItems) { selectedSuggestion in
                                handleSuggestionSelection(selectedSuggestion, from: suggestions)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("1", text: $quantityString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .onChange(of: quantityString) { newValue in
                                // Allow only numbers and one decimal point
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                let components = filtered.components(separatedBy: ".")
                                if components.count > 2 {
                                    // If more than one decimal point, remove the last one
                                    quantityString = String(filtered.dropLast())
                                } else if let first = components.first, first.count > 5 {
                                    // Limit to 5 digits before decimal
                                    quantityString = String(first.prefix(5))
                                } else if components.count == 2, let last = components.last, last.count > 2 {
                                    // Limit to 2 decimal places
                                    quantityString = "\(components[0]).\(last.prefix(2))"
                                } else {
                                    quantityString = filtered
                                }
                            }
                        if !unit.isEmpty {
                            Text(unit)
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
                
                Section(header: Text("Price & Brand")) {
                    HStack {
                        Text("$")
                        TextField("Estimated Price", text: $estimatedPriceString)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .price)
                            .onChange(of: estimatedPriceString) { newValue in
                                // Allow only numbers and one decimal point
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                let components = filtered.components(separatedBy: ".")
                                if components.count > 2 {
                                    // If more than one decimal point, remove the last one
                                    estimatedPriceString = String(filtered.dropLast())
                                } else if let first = components.first, first.count > 5 {
                                    // Limit to 5 digits before decimal
                                    estimatedPriceString = String(first.prefix(5))
                                } else if components.count == 2, let last = components.last, last.count > 2 {
                                    // Limit to 2 decimal places
                                    estimatedPriceString = "\(components[0]).\(last.prefix(2))"
                                } else {
                                    estimatedPriceString = filtered
                                }
                            }
                    }
                    
                    TextField("Brand", text: $brand)
                        .focused($focusedField, equals: .brand)
                    
                    HStack {
                        TextField("Unit (e.g., kg, g, lb)", text: $unit)
                            .focused($focusedField, equals: .unit)
                        
                        if !unit.isEmpty {
                            Button(action: {
                                unit = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .notes)
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
                        addNewItem()
                    }
                    .disabled(!isFormValid)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: itemName) { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                showSuggestions = !trimmed.isEmpty
            }
        }
    }
    
    private func handleSuggestionSelection(_ suggestion: (name: String, category: ItemCategory), from suggestions: [Item]) {
        // Find the full item from the suggestions
        if let selectedItem = suggestions.first(where: { $0.name == suggestion.name }) {
            // Update all fields from the selected suggestion
            itemName = selectedItem.name
            // Update quantityString instead of the computed quantity property
            quantityString = selectedItem.quantity.formatted()
            category = selectedItem.category
            priority = selectedItem.priority
            // Update estimatedPriceString instead of the computed estimatedPrice property
            if let price = selectedItem.estimatedPrice {
                estimatedPriceString = price.formatted()
            } else {
                estimatedPriceString = ""
            }
            brand = selectedItem.brand ?? ""
            unit = selectedItem.unit ?? ""
            notes = selectedItem.notes ?? ""
            showSuggestions = false
        }
    }
    
    private func addNewItem() {
        // Capture the current values to avoid reference issues
        let itemName = self.itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let category = self.category
        let notes = self.notes.isEmpty ? nil : self.notes
        let brand = self.brand.isEmpty ? nil : self.brand
        let unit = self.unit.isEmpty ? nil : self.unit
        
        // Ensure quantity is at least 0.01
        let validQuantity = max(0.01, quantity)
        
        let newItem = Item(
            name: itemName,
            quantity: validQuantity,
            category: category,
            isCompleted: false,
            notes: notes,
            dateAdded: Date(),
            estimatedPrice: self.estimatedPrice,
            barcode: nil,
            brand: brand,
            unit: unit,
            lastPurchasedPrice: self.estimatedPrice, // Save current price as last purchased
            lastPurchasedDate: Date(),
            imageURL: nil,
            priority: self.priority
        )
        
        Task {
            do {
                try viewModel.addItem(newItem, to: list)
                // Update suggestions with the full item
                viewModel.addOrUpdateSuggestion(newItem)
                dismiss()
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                }
            }
        }
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
