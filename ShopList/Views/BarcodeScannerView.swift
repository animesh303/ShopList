import SwiftUI
import AVFoundation
import Vision

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scannerViewModel = BarcodeScannerViewModel()
    @State private var showingProductDetails = false
    @State private var scannedProduct: ScannedProduct?
    
    var onProductScanned: ((ScannedProduct) -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview
                CameraPreviewView(session: scannerViewModel.session)
                    .ignoresSafeArea()
                
                // Overlay
                VStack {
                    // Top controls
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.5))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        Text("Scan Barcode")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(.black.opacity(0.5))
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Button("Flash") {
                            scannerViewModel.toggleFlash()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.5))
                        .cornerRadius(8)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Scanning frame
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 250, height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange, lineWidth: 1)
                                .frame(width: 250, height: 150)
                        )
                    
                    Spacer()
                    
                    // Bottom info
                    VStack(spacing: 8) {
                        Text("Position barcode within the frame")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(.black.opacity(0.5))
                            .cornerRadius(8)
                        
                        if scannerViewModel.isScanning {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                scannerViewModel.startScanning { barcode in
                    handleBarcodeScanned(barcode)
                }
            }
            .onDisappear {
                scannerViewModel.stopScanning()
            }
            .sheet(isPresented: $showingProductDetails) {
                if let product = scannedProduct {
                    ProductDetailsView(product: product) { item in
                        onProductScanned?(product)
                        dismiss()
                    }
                }
            }
            .alert("Scanning Error", isPresented: $scannerViewModel.showingError) {
                Button("OK") { }
            } message: {
                Text(scannerViewModel.errorMessage ?? "An error occurred while scanning")
            }
        }
    }
    
    private func handleBarcodeScanned(_ barcode: String) {
        print("Barcode scanned: \(barcode)")
        
        // Look up product information
        Task {
            let product = await scannerViewModel.lookupProduct(barcode: barcode)
            await MainActor.run {
                scannedProduct = product
                showingProductDetails = true
            }
        }
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Product Details View

struct ProductDetailsView: View {
    let product: ScannedProduct
    let onAddItem: (Item) -> Void
    
    @State private var quantity: Double = 1.0
    @State private var notes: String = ""
    @State private var selectedCategory: ItemCategory = .groceries
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Product image
                    if let imageUrl = product.imageUrl {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .cornerRadius(12)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    
                    // Product info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(product.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let brand = product.brand {
                            Text("Brand: \(brand)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let price = product.price {
                            Text("Price: $\(price, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        
                        if let description = product.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Add to list form
                    VStack(spacing: 16) {
                        HStack {
                            Text("Quantity:")
                            Spacer()
                            Stepper("\(quantity, specifier: "%.0f")", value: $quantity, in: 1...99)
                        }
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        
                        TextField("Notes (optional)", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Dismiss
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add to List") {
                        let item = Item(
                            name: product.name,
                            quantity: Decimal(quantity),
                            category: selectedCategory,
                            isCompleted: false,
                            notes: notes.isEmpty ? nil : notes,
                            estimatedPrice: product.price.map { Decimal($0) },
                            barcode: product.barcode,
                            brand: product.brand,
                            unit: product.unit,
                            imageData: nil,
                            priority: .normal,
                            productId: product.productId,
                            lastScanned: nil
                        )
                        onAddItem(item)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

// MARK: - Scanned Product Model

struct ScannedProduct {
    let barcode: String
    let name: String
    let brand: String?
    let price: Double?
    let description: String?
    let imageUrl: URL?
    let unit: String?
    let productId: String?
}

#Preview {
    BarcodeScannerView()
} 