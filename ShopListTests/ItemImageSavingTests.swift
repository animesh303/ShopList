import XCTest
import SwiftData
import SwiftUI
import PhotosUI
@testable import ShopList

@MainActor
final class ItemImageSavingTests: BaseTestCase {
    
    // MARK: - Test Data
    
    private var sampleImageData: Data {
        // Create a simple 1x1 pixel PNG image data for testing
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.pngData() ?? Data()
    }
    
    private var sampleJPEGData: Data {
        // Create a simple 1x1 pixel JPEG image data for testing
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.blue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.jpegData(compressionQuality: 0.8) ?? Data()
    }
    
    // MARK: - Item Model Tests
    
    func testItemWithImageData() throws {
        let item = Item(
            name: "Test Item with Image",
            category: .groceries,
            imageData: sampleImageData
        )
        
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageData?.count, sampleImageData.count)
        XCTAssertEqual(item.name, "Test Item with Image")
        XCTAssertEqual(item.category, .groceries)
    }
    
    func testItemImageDataPersistence() throws {
        let item = Item(
            name: "Persistent Image Item",
            category: .dairy,
            imageData: sampleJPEGData
        )
        
        // Test that image data is set correctly
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageData?.count, sampleJPEGData.count)
        
        // Test that the image can be recreated from the data
        if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
            XCTAssertNotNil(uiImage)
        } else {
            XCTFail("Failed to recreate UIImage from saved data")
        }
    }
    
    func testItemImageDataUpdate() throws {
        let item = Item(
            name: "Updateable Image Item",
            category: .bakery
        )
        
        // Initially no image
        XCTAssertNil(item.imageData)
        
        // Add image data
        item.imageData = sampleImageData
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageData?.count, sampleImageData.count)
        
        // Update to different image
        item.imageData = sampleJPEGData
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageData?.count, sampleJPEGData.count)
        
        // Remove image
        item.imageData = nil
        XCTAssertNil(item.imageData)
    }
    
    // MARK: - Image Data Validation Tests
    
    func testValidImageDataCreation() {
        let imageData = sampleImageData
        XCTAssertFalse(imageData.isEmpty)
        XCTAssertGreaterThan(imageData.count, 0)
        
        // Verify it can be converted back to UIImage
        let uiImage = UIImage(data: imageData)
        XCTAssertNotNil(uiImage)
        XCTAssertEqual(uiImage?.size.width, 1)
        XCTAssertEqual(uiImage?.size.height, 1)
    }
    
    func testJPEGImageDataCreation() {
        let jpegData = sampleJPEGData
        XCTAssertFalse(jpegData.isEmpty)
        XCTAssertGreaterThan(jpegData.count, 0)
        
        // Verify it can be converted back to UIImage
        let uiImage = UIImage(data: jpegData)
        XCTAssertNotNil(uiImage)
        XCTAssertEqual(uiImage?.size.width, 1)
        XCTAssertEqual(uiImage?.size.height, 1)
    }
    
    // MARK: - Mock PhotosPickerItem Tests
    
    func testMockPhotosPickerItem() async throws {
        // Create a mock PhotosPickerItem that returns our test data
        let mockItem = MockPhotosPickerItem(imageData: sampleImageData)
        
        // Test loading the transferable data
        let loadedData = try await mockItem.loadTransferable(type: Data.self)
        XCTAssertNotNil(loadedData)
        XCTAssertEqual(loadedData?.count, sampleImageData.count)
    }
    
    func testMockPhotosPickerItemWithJPEG() async throws {
        // Create a mock PhotosPickerItem that returns JPEG test data
        let mockItem = MockPhotosPickerItem(imageData: sampleJPEGData)
        
        // Test loading the transferable data
        let loadedData = try await mockItem.loadTransferable(type: Data.self)
        XCTAssertNotNil(loadedData)
        XCTAssertEqual(loadedData?.count, sampleJPEGData.count)
    }
    
    func testMockPhotosPickerItemFailure() async throws {
        // Create a mock PhotosPickerItem that fails
        let mockItem = MockPhotosPickerItem(imageData: nil, shouldFail: true)
        
        // Test that it throws an error
        do {
            let _ = try await mockItem.loadTransferable(type: Data.self)
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected to fail
            XCTAssertTrue(error is MockPhotosPickerItem.MockError)
        }
    }
    
    // MARK: - Image Saving Logic Tests
    
    func testImageDataAssignment() {
        let item = Item(name: "Test Item", category: .groceries)
        
        // Test PNG data assignment
        item.imageData = sampleImageData
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageData?.count, sampleImageData.count)
        
        // Test JPEG data assignment
        item.imageData = sampleJPEGData
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageData?.count, sampleJPEGData.count)
        
        // Test nil assignment
        item.imageData = nil
        XCTAssertNil(item.imageData)
        
        // Clean up by removing from context
        modelContext.delete(item)
        try? modelContext.save()
    }
    
    func testImageDataEquality() {
        let data1 = sampleImageData
        let data2 = sampleImageData
        let data3 = sampleJPEGData
        
        XCTAssertEqual(data1, data2)
        XCTAssertNotEqual(data1, data3)
    }
    
    // MARK: - Performance Tests
    
    func testImageDataPerformance() {
        // Test creating multiple items with image data
        measure {
            // Create items without saving to context to avoid performance issues
            for i in 0..<10 {
                let item = Item(
                    name: "Performance Test Item \(i)",
                    category: .groceries,
                    imageData: sampleImageData
                )
                // Just verify the item was created correctly
                XCTAssertNotNil(item.imageData)
                XCTAssertEqual(item.imageData?.count, sampleImageData.count)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyImageData() {
        let item = Item(name: "Empty Image Item", category: .groceries)
        
        // Test with empty data
        item.imageData = Data()
        XCTAssertNotNil(item.imageData)
        XCTAssertTrue(item.imageData?.isEmpty == true)
        
        // Test with nil
        item.imageData = nil
        XCTAssertNil(item.imageData)
    }
    
    func testLargeImageData() {
        // Create a larger test image (10x10 pixels)
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.green.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let largeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let largeImageData = largeImage?.pngData() ?? Data()
        
        let item = Item(name: "Large Image Item", category: .groceries)
        item.imageData = largeImageData
        
        XCTAssertNotNil(item.imageData)
        XCTAssertGreaterThan(item.imageData?.count ?? 0, sampleImageData.count)
    }
    
    func testImageDataWithSpecialCharacters() {
        let item = Item(
            name: "Special Chars: 🍎📱💻",
            category: .groceries,
            imageData: sampleImageData
        )
        
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageData?.count, sampleImageData.count)
        XCTAssertEqual(item.name, "Special Chars: 🍎📱💻")
    }
}

// MARK: - Mock PhotosPickerItem

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

// MARK: - Test Extensions

extension ItemImageSavingTests {
    
    func testImageDataCompression() {
        // Test different compression qualities
        let size = CGSize(width: 5, height: 5)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.orange.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let highQualityData = image?.jpegData(compressionQuality: 1.0)
        let mediumQualityData = image?.jpegData(compressionQuality: 0.5)
        let lowQualityData = image?.jpegData(compressionQuality: 0.1)
        
        XCTAssertNotNil(highQualityData)
        XCTAssertNotNil(mediumQualityData)
        XCTAssertNotNil(lowQualityData)
        
        // Higher quality should result in larger file size
        XCTAssertGreaterThanOrEqual(highQualityData?.count ?? 0, mediumQualityData?.count ?? 0)
        XCTAssertGreaterThanOrEqual(mediumQualityData?.count ?? 0, lowQualityData?.count ?? 0)
    }
    
    func testImageDataFormatConversion() {
        let originalImage = UIImage(data: sampleImageData)!
        
        // Convert to JPEG
        let jpegData = originalImage.jpegData(compressionQuality: 0.8)
        XCTAssertNotNil(jpegData)
        
        // Convert back to PNG
        let pngData = UIImage(data: jpegData!)?.pngData()
        XCTAssertNotNil(pngData)
        
        // The converted image should still be valid
        let convertedImage = UIImage(data: pngData!)
        XCTAssertNotNil(convertedImage)
    }
} 