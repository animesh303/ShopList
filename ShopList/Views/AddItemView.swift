import SwiftUI
import AVFoundation

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    
    @State private var itemName = ""
    @State private var quantity = 1
    @State private var category: ItemCategory = .other
    @State private var notes = ""
    @State private var estimatedPrice: Double?
    @State private var brand = ""
    @State private var unit = ""
    @State private var priority: ItemPriority = .normal
    @State private var showingScanner = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var barcode: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
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
                        TextField("Estimated Price", value: $estimatedPrice, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    TextField("Brand", text: $brand)
                    TextField("Unit (e.g., kg, lb)", text: $unit)
                }
                
                Section(header: Text("Additional Information")) {
                    TextField("Notes", text: $notes)
                }
                
                Section {
                    Button(action: { showingScanner = true }) {
                        Label("Scan Barcode", systemImage: "barcode.viewfinder")
                    }
                    
                    if let barcode = barcode {
                        Text("Barcode: \(barcode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { showingImagePicker = true }) {
                        Label("Add Photo", systemImage: "photo")
                    }
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
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
                        let newItem = Item(
                            name: itemName,
                            quantity: quantity,
                            category: category,
                            isCompleted: false,
                            notes: notes.isEmpty ? nil : notes,
                            dateAdded: Date(),
                            estimatedPrice: estimatedPrice,
                            barcode: barcode,
                            brand: brand.isEmpty ? nil : brand,
                            unit: unit.isEmpty ? nil : unit,
                            priority: priority
                        )
                        var updatedList = list
                        updatedList.addItem(newItem)
                        viewModel.updateList(updatedList)
                        dismiss()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView(barcode: $barcode)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
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