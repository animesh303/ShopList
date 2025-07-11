import XCTest
import SwiftData
import SwiftUI
import PhotosUI
@testable import ShopList

@MainActor
final class ItemImageSavingViewTests: BaseTestCase {
    
    // MARK: - Test Data
    
    private var sampleImageData: Data {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.pngData() ?? Data()
    }
    
    private var sampleJPEGData: Data {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.blue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.jpegData(compressionQuality: 0.8) ?? Data()
    }
    
    // MARK: - AddItemView Image Saving Tests
    
    func testAddItemViewImageDataInitialization() throws {
        // Test that image data can be initialized properly
        var imageData: Data? = nil
        var itemImage: Image? = nil
        
        XCTAssertNil(imageData)
        XCTAssertNil(itemImage)
        
        // Simulate image selection
        imageData = sampleImageData
        if let uiImage = UIImage(data: sampleImageData) {
            itemImage = Image(uiImage: uiImage)
        }
        
        XCTAssertNotNil(imageData)
        XCTAssertNotNil(itemImage)
    }
    
    func testAddItemViewImageDataAssignment() throws {
        // Simulate the image data assignment logic from AddItemView
        var imageData: Data? = nil
        
        // Test PNG data
        imageData = sampleImageData
        XCTAssertNotNil(imageData)
        XCTAssertEqual(imageData?.count, sampleImageData.count)
        
        // Test JPEG data
        imageData = sampleJPEGData
        XCTAssertNotNil(imageData)
        XCTAssertEqual(imageData?.count, sampleJPEGData.count)
        
        // Test nil assignment
        imageData = nil
        XCTAssertNil(imageData)
    }
    
    func testAddItemViewItemCreationWithImage() throws {
        // Simulate the addItem() function logic from AddItemView
        let name = "Test Item with Image"
        let quantity = Decimal(2)
        let category = ItemCategory.groceries
        let notes = "Test notes"
        let pricePerUnit = Decimal(1.99)
        let brand = "Test Brand"
        let unit = "kg"
        let imageData = sampleImageData
        let priority = ItemPriority.high
        
        let item = Item(
            name: name,
            quantity: quantity,
            category: category,
            isCompleted: false,
            notes: notes,
            pricePerUnit: pricePerUnit,
            brand: brand,
            unit: unit,
            imageData: imageData,
            priority: priority
        )
        
        // Verify item properties
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.quantity, quantity)
        XCTAssertEqual(item.category, category)
        XCTAssertEqual(item.notes, notes)
        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
        XCTAssertEqual(item.brand, brand)
        XCTAssertEqual(item.unit, unit)
        XCTAssertEqual(item.imageData, imageData)
        XCTAssertEqual(item.priority, priority)
        
        // Clean up
        modelContext.delete(item)
        try modelContext.save()
    }
    
    // MARK: - ItemDetailView Image Saving Tests
    
    func testItemDetailViewImageDataInitialization() throws {
        let item = Item(name: "Test Item", category: .groceries)
        
        // Test initialization with existing image data
        item.imageData = sampleImageData
        
        // Simulate ItemDetailView initialization
        let name = item.name
        let brand = item.brand ?? ""
        let quantity = Double(truncating: item.quantity as NSDecimalNumber)
        let unit = Unit(rawValue: item.unit ?? "") ?? .none
        let category = item.category
        let priority = item.priority
        let pricePerUnit = item.pricePerUnit.map { Double(truncating: $0 as NSDecimalNumber) }
        let notes = item.notes ?? ""
        var itemImage: Image? = nil
        var imageData: Data? = nil
        
        // Initialize item image if available (simulating ItemDetailView init)
        if let existingImageData = item.imageData, let uiImage = UIImage(data: existingImageData) {
            itemImage = Image(uiImage: uiImage)
            imageData = existingImageData
        }
        
        // Verify the initialization worked correctly
        XCTAssertEqual(name, "Test Item")
        XCTAssertEqual(brand, "")
        XCTAssertEqual(quantity, 1.0) // Default quantity
        XCTAssertEqual(unit, .none)
        XCTAssertEqual(category, .groceries)
        XCTAssertEqual(priority, .normal) // Default priority
        XCTAssertNil(pricePerUnit)
        XCTAssertEqual(notes, "")
        
        XCTAssertNotNil(itemImage)
        XCTAssertNotNil(imageData)
        XCTAssertEqual(imageData, sampleImageData)
    }
    
    func testItemDetailViewSaveChangesWithImage() async throws {
        let item = Item(name: "Test Item", category: .groceries)
        
        // Simulate the saveChanges() function logic from ItemDetailView
        let newName = "Updated Item Name"
        let newBrand = "Updated Brand"
        let newQuantity = 3.0
        let newUnit = Unit.kilogram
        let newCategory = ItemCategory.dairy
        let newPriority = ItemPriority.high
        let newPricePerUnit = 2.99
        let newNotes = "Updated notes"
        let newImageData = sampleJPEGData
        
        // Simulate the async save operation
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Task {
                // Update item properties (simulating saveChanges logic)
                item.name = newName
                item.brand = newBrand.isEmpty ? nil : newBrand
                item.quantity = Decimal(newQuantity)
                item.unit = newUnit == .none ? nil : newUnit.rawValue
                item.category = newCategory
                item.priority = newPriority
                item.pricePerUnit = Decimal(newPricePerUnit)
                item.notes = newNotes.isEmpty ? nil : newNotes
                
                // Handle image saving (simulating the async image loading)
                item.imageData = newImageData
                
                continuation.resume()
            }
        }
        
        // Verify all properties were updated
        XCTAssertEqual(item.name, newName)
        XCTAssertEqual(item.brand, newBrand)
        XCTAssertEqual(item.quantity, Decimal(newQuantity))
        XCTAssertEqual(item.unit, newUnit.rawValue)
        XCTAssertEqual(item.category, newCategory)
        XCTAssertEqual(item.priority, newPriority)
        XCTAssertEqual(item.pricePerUnit, Decimal(newPricePerUnit))
        XCTAssertEqual(item.notes, newNotes)
        XCTAssertEqual(item.imageData, newImageData)
    }
    
    func testItemDetailViewSaveChangesWithoutImage() async throws {
        let item = Item(name: "Test Item", category: .groceries)
        
        // Simulate saving without changing the image
        let newName = "Updated Item Name"
        let newNotes = "Updated notes"
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Task {
                // Update only some properties
                item.name = newName
                item.notes = newNotes.isEmpty ? nil : newNotes
                
                // No image changes
                // item.imageData remains unchanged
                
                continuation.resume()
            }
        }
        
        // Verify properties were updated
        XCTAssertEqual(item.name, newName)
        XCTAssertEqual(item.notes, newNotes)
        // Image data should remain unchanged
        XCTAssertNil(item.imageData)
    }
    
    // MARK: - PhotosPickerItem Integration Tests
    
    func testPhotosPickerItemImageLoading() async throws {
        // Test the onChange logic from both views
        let mockItem = MockPhotosPickerItem(imageData: sampleImageData)
        
        // Simulate the onChange logic
        var imageData: Data? = nil
        var itemImage: Image? = nil
        
        do {
            if let data = try await mockItem.loadTransferable(type: Data.self) {
                imageData = data
                if let uiImage = UIImage(data: data) {
                    itemImage = Image(uiImage: uiImage)
                }
            }
        } catch {
            XCTFail("Failed to load image data: \(error)")
        }
        
        XCTAssertNotNil(imageData)
        XCTAssertNotNil(itemImage)
        XCTAssertEqual(imageData?.count, sampleImageData.count)
    }
    
    func testPhotosPickerItemImageLoadingFailure() async throws {
        // Test error handling in the onChange logic
        let mockItem = MockPhotosPickerItem(imageData: nil, shouldFail: true)
        
        var imageData: Data? = nil
        var itemImage: Image? = nil
        var errorOccurred = false
        
        do {
            if let data = try await mockItem.loadTransferable(type: Data.self) {
                imageData = data
                if let uiImage = UIImage(data: data) {
                    itemImage = Image(uiImage: uiImage)
                }
            }
        } catch {
            errorOccurred = true
            XCTAssertTrue(error is MockPhotosPickerItem.MockError)
        }
        
        XCTAssertTrue(errorOccurred)
        XCTAssertNil(imageData)
        XCTAssertNil(itemImage)
    }
    
    // MARK: - Camera Integration Tests
    
    func testCameraImageDataHandling() throws {
        // Test the camera image data handling logic
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.green.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cameraImageData = uiImage?.jpegData(compressionQuality: 0.8)
        
        XCTAssertNotNil(cameraImageData)
        
        // Simulate the camera image assignment
        var imageData: Data? = nil
        var itemImage: Image? = nil
        
        if let uiImage = uiImage {
            itemImage = Image(uiImage: uiImage)
            imageData = cameraImageData
        }
        
        XCTAssertNotNil(imageData)
        XCTAssertNotNil(itemImage)
        XCTAssertEqual(imageData, cameraImageData)
    }
    
    // MARK: - Error Handling Tests
    
    func testImageLoadingErrorHandling() async throws {
        // Simulate error handling in saveChanges
        var errorMessage = ""
        var showingError = false
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Task {
                // Simulate a failed image loading scenario
                let mockItem = MockPhotosPickerItem(imageData: nil, shouldFail: true)
                
                do {
                    if try await mockItem.loadTransferable(type: Data.self) != nil {
                        // This should not happen since the mock is set to fail
                        XCTFail("Expected error to be thrown")
                    }
                } catch {
                    // This is the expected error handling path
                    errorMessage = "Failed to load image: \(error.localizedDescription)"
                    showingError = true
                }
                
                continuation.resume()
            }
        }
        
        XCTAssertTrue(showingError)
        XCTAssertTrue(errorMessage.contains("Failed to load image"))
    }
    
    // MARK: - Performance Tests
    
    func testImageSavingPerformance() {
        measure {
            let item = Item(name: "Performance Test Item", category: .groceries)
            
            // Simulate multiple image assignments
            for _ in 0..<5 {
                item.imageData = sampleImageData
                item.imageData = sampleJPEGData
            }
            
            // Final assignment
            item.imageData = sampleImageData
            
            XCTAssertNotNil(item.imageData)
        }
    }
    
    // MARK: - Edge Cases
    
    func testImageDataWithEmptyData() throws {
        let item = Item(name: "Test Item", category: .groceries)
        
        // Test with empty data
        item.imageData = Data()
        XCTAssertNotNil(item.imageData)
        XCTAssertTrue(item.imageData?.isEmpty == true)
        
        // Test with nil
        item.imageData = nil
        XCTAssertNil(item.imageData)
    }
    
    func testImageDataWithInvalidData() throws {
        let item = Item(name: "Test Item", category: .groceries)
        
        // Test with invalid image data
        let invalidData = "This is not image data".data(using: .utf8)!
        item.imageData = invalidData
        
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageData, invalidData)
        
        // Verify it can't be converted to UIImage
        let uiImage = UIImage(data: invalidData)
        XCTAssertNil(uiImage)
    }
}

// MARK: - Mock PhotosPickerItem (same as in ItemImageSavingTests)

private struct MockPhotosPickerItem {
    private let imageData: Data?
    private let shouldFail: Bool
    
    init(imageData: Data?, shouldFail: Bool = false) {
        self.imageData = imageData
        self.shouldFail = shouldFail
    }
    
    func loadTransferable<T>(type: T.Type) async throws -> T? where T : Transferable {
        if shouldFail {
            throw MockError.loadFailed
        }
        
        if let imageData = imageData, T.self == Data.self {
            return imageData as? T
        }
        
        return nil
    }
    
    enum MockError: Error {
        case loadFailed
    }
} 