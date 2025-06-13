import XCTest
@testable import ShopList

final class ItemTests: XCTestCase {
    func testItemCreation() {
        let item = Item(
            name: "Milk",
            quantity: 2,
            category: .dairy,
            isCompleted: false,
            notes: "Get whole milk",
            dateAdded: Date()
        )
        
        XCTAssertEqual(item.name, "Milk")
        XCTAssertEqual(item.quantity, 2)
        XCTAssertEqual(item.category, .dairy)
        XCTAssertFalse(item.isCompleted)
        XCTAssertEqual(item.notes, "Get whole milk")
    }
    
    func testItemCodable() {
        let originalItem = Item(
            name: "Bread",
            quantity: 1,
            category: .bakery,
            isCompleted: true,
            notes: nil,
            dateAdded: Date()
        )
        
        do {
            let encoded = try JSONEncoder().encode(originalItem)
            let decoded = try JSONDecoder().decode(Item.self, from: encoded)
            
            XCTAssertEqual(originalItem.name, decoded.name)
            XCTAssertEqual(originalItem.quantity, decoded.quantity)
            XCTAssertEqual(originalItem.category, decoded.category)
            XCTAssertEqual(originalItem.isCompleted, decoded.isCompleted)
            XCTAssertEqual(originalItem.notes, decoded.notes)
        } catch {
            XCTFail("Failed to encode/decode Item: \(error)")
        }
    }
    
    func testCategoryAllCases() {
        let categories = Item.Category.allCases
        XCTAssertFalse(categories.isEmpty)
        XCTAssertTrue(categories.contains(.produce))
        XCTAssertTrue(categories.contains(.dairy))
        XCTAssertTrue(categories.contains(.meat))
        XCTAssertTrue(categories.contains(.bakery))
        XCTAssertTrue(categories.contains(.frozen))
        XCTAssertTrue(categories.contains(.canned))
        XCTAssertTrue(categories.contains(.snacks))
        XCTAssertTrue(categories.contains(.beverages))
        XCTAssertTrue(categories.contains(.household))
        XCTAssertTrue(categories.contains(.other))
    }
} 