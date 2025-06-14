import SwiftUI
import AVFoundation
import UIKit

// View for displaying item suggestions
private struct SuggestionsListView: View {
    let suggestions: [(name: String, category: ItemCategory)]
    let onSelect: ((name: String, category: ItemCategory)) -> Void
    
    var body: some View {
        ForEach(suggestions, id: \.name) { suggestion in
            Button(action: { onSelect(suggestion) }) {
                HStack {
                    Text(suggestion.name.capitalized)
                    Spacer()
                    Text(suggestion.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// Define Field at the top level to avoid forward reference issues
private enum Field {
    case name, price, brand, unit, notes
}

// Custom toolbar content to avoid ambiguity
private struct AddItemToolbar: ToolbarContent {
    @Binding var itemName: String
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    @FocusState.Binding var focusedField: Field?
    let onCancel: () -> Void
    let onAdd: () -> Void
    
    var body: some ToolbarContent {
        // Navigation bar items
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", action: onCancel)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Add", action: onAdd)
                .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        
        // Keyboard accessory view
        ToolbarItem(placement: .keyboard) {
            HStack {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    
    @State private var itemName = ""
    @State private var showSuggestions = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                        .focused($isFocused)
                        .onAppear {
                            isFocused = true
                        }
                    
                    // Show suggestions if available
                    if showSuggestions {
                        let suggestions = viewModel.getSuggestions(for: itemName)
                        if !suggestions.isEmpty {
                            Section(header: Text("Suggestions")) {
                                ForEach(suggestions, id: \.name) { suggestion in
                                    Button(action: {
                                        itemName = suggestion.name
                                        showSuggestions = false
                                    }) {
                                        HStack {
                                            Text(suggestion.name.capitalized)
                                            Spacer()
                                            Text(suggestion.category.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // Simple add item logic
                        let newItem = Item(
                            name: itemName,
                            quantity: 1,
                            category: .other,
                            isCompleted: false,
                            notes: nil,
                            dateAdded: Date(),
                            estimatedPrice: nil,
                            barcode: nil,
                            brand: nil,
                            unit: nil,
                            priority: .normal
                        )
                        
                        do {
                            try viewModel.addItem(newItem, to: list)
                            viewModel.addOrUpdateSuggestion(itemName, category: .other)
                            dismiss()
                        } catch {
                            print("Error adding item: \(error)")
                        }
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: itemName) { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                showSuggestions = !trimmed.isEmpty
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