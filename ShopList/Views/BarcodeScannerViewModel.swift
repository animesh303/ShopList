import Foundation
import AVFoundation
import Vision
import SwiftUI

class BarcodeScannerViewModel: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var showingError = false
    @Published var errorMessage: String?
    
    let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var onBarcodeDetected: ((String) -> Void)?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            errorMessage = "Camera not available"
            showingError = true
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
        } catch {
            errorMessage = "Failed to setup camera: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    func startScanning(onBarcodeDetected: @escaping (String) -> Void) {
        self.onBarcodeDetected = onBarcodeDetected
        isScanning = true
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopScanning() {
        isScanning = false
        session.stopRunning()
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.hasTorch {
                device.torchMode = device.torchMode == .on ? .off : .on
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Failed to toggle flash: \(error)")
        }
    }
    
    func lookupProduct(barcode: String) async -> ScannedProduct {
        // In a real app, this would call a product database API
        // For now, we'll return mock data based on the barcode
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock product data based on barcode
        let mockProducts: [String: ScannedProduct] = [
            "1234567890123": ScannedProduct(
                barcode: "1234567890123",
                name: "Organic Bananas",
                brand: "Fresh Market",
                price: 2.99,
                description: "Fresh organic bananas, perfect for smoothies and snacks.",
                imageUrl: nil,
                unit: "bunch",
                productId: "prod_001"
            ),
            "9876543210987": ScannedProduct(
                barcode: "9876543210987",
                name: "Whole Grain Bread",
                brand: "Baker's Choice",
                price: 3.49,
                description: "Nutritious whole grain bread with seeds and nuts.",
                imageUrl: nil,
                unit: "loaf",
                productId: "prod_002"
            ),
            "4567891234567": ScannedProduct(
                barcode: "4567891234567",
                name: "Greek Yogurt",
                brand: "Dairy Fresh",
                price: 4.99,
                description: "Creamy Greek yogurt with live cultures.",
                imageUrl: nil,
                unit: "container",
                productId: "prod_003"
            )
        ]
        
        // Return mock product or create a generic one
        if let product = mockProducts[barcode] {
            return product
        } else {
            // Create a generic product for unknown barcodes
            return ScannedProduct(
                barcode: barcode,
                name: "Product (Barcode: \(barcode))",
                brand: nil,
                price: nil,
                description: "Product information not available in database.",
                imageUrl: nil,
                unit: nil,
                productId: nil
            )
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension BarcodeScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let results = request.results as? [VNBarcodeObservation],
                  let firstBarcode = results.first,
                  let payload = firstBarcode.payloadStringValue else { return }
            
            DispatchQueue.main.async {
                self?.onBarcodeDetected?(payload)
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform barcode detection: \(error)")
        }
    }
} 