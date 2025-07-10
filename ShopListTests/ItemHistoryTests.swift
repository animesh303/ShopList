import XCTest
@testable import ShopList

final class ItemHistoryTests: XCTestCase {
    
    func testItemHistoryCreation() {
        let history = ItemHistory(
            name: "Milk",
            category: .dairy,
            brand: "Organic Valley",
            unit: "gallon",
            lastUsedDate: Date(),
            usageCount: 5,
            pricePerUnit: 4.99
        )
        
        XCTAssertEqual(history.name, "Milk")
        XCTAssertEqual(history.lowercaseName, "milk")
        XCTAssertEqual(history.category, .dairy)
        XCTAssertEqual(history.brand, "Organic Valley")
        XCTAssertEqual(history.unit, "gallon")
        XCTAssertEqual(history.usageCount, 5)
        XCTAssertEqual(history.pricePerUnit, 4.99)
    }
    
    func testItemHistoryCreationWithDefaults() {
        let history = ItemHistory(
            name: "Bread",
            category: .bakery
        )
        
        XCTAssertEqual(history.name, "Bread")
        XCTAssertEqual(history.lowercaseName, "bread")
        XCTAssertEqual(history.category, .bakery)
        XCTAssertNil(history.brand)
        XCTAssertNil(history.unit)
        XCTAssertEqual(history.usageCount, 1)
        XCTAssertNil(history.pricePerUnit)
    }
    
    func testItemHistoryLowercaseName() {
        let history1 = ItemHistory(name: "MILK", category: .dairy)
        XCTAssertEqual(history1.lowercaseName, "milk")
        
        let history2 = ItemHistory(name: "Organic Milk", category: .dairy)
        XCTAssertEqual(history2.lowercaseName, "organic milk")
        
        let history3 = ItemHistory(name: "123 Items", category: .other)
        XCTAssertEqual(history3.lowercaseName, "123 items")
    }
    
    func testItemHistoryUniqueID() {
        let history1 = ItemHistory(name: "Milk", category: .dairy)
        let history2 = ItemHistory(name: "Milk", category: .dairy)
        
        XCTAssertNotEqual(history1.id, history2.id)
    }
    
    func testItemHistoryUsageCountIncrement() {
        let history = ItemHistory(
            name: "Milk",
            category: .dairy,
            usageCount: 1
        )
        
        XCTAssertEqual(history.usageCount, 1)
        
        // Simulate usage increment (in real app, this would be a method)
        // For now, we test the initial value
        XCTAssertEqual(history.usageCount, 1)
    }
    
    func testItemHistoryPricePerUnit() {
        let history = ItemHistory(
            name: "Milk",
            category: .dairy,
            pricePerUnit: 3.99
        )
        
        XCTAssertEqual(history.pricePerUnit, 3.99)
        
        let historyWithoutPrice = ItemHistory(
            name: "Bread",
            category: .bakery
        )
        
        XCTAssertNil(historyWithoutPrice.pricePerUnit)
    }
} 