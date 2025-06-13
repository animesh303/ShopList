import XCTest
@testable import ShopList

final class ShoppingListTests: XCTestCase {
    func testShoppingListCreation() {
        let list = ShoppingList(
            name: "Grocery List",
            items: [],
            dateCreated: Date(),
            isShared: false
        )
        
        XCTAssertEqual(list.name, "Grocery List")
        XCTAssertTrue(list.items.isEmpty)
        XCTAssertFalse(list.isShared)
        XCTAssertNil(list.sharedWith)
    }
    
    func testCompletedAndPendingItems() {
        let completedItem = Item(
            name: "Milk",
            quantity: 1,
            category: .dairy,
            isCompleted: true,
            notes: nil,
            dateAdded: Date()
        )
        
        let pendingItem = Item(
            name: "Bread",
            quantity: 1,
            category: .bakery,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [completedItem, pendingItem],
            dateCreated: Date(),
            isShared: false
        )
        
        XCTAssertEqual(list.completedItems.count, 1)
        XCTAssertEqual(list.pendingItems.count, 1)
        XCTAssertEqual(list.completedItems.first?.name, "Milk")
        XCTAssertEqual(list.pendingItems.first?.name, "Bread")
    }
    
    func testItemsByCategory() {
        let dairyItem = Item(
            name: "Milk",
            quantity: 1,
            category: .dairy,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        let bakeryItem = Item(
            name: "Bread",
            quantity: 1,
            category: .bakery,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [dairyItem, bakeryItem],
            dateCreated: Date(),
            isShared: false
        )
        
        XCTAssertEqual(list.itemsByCategory[.dairy]?.count, 1)
        XCTAssertEqual(list.itemsByCategory[.bakery]?.count, 1)
        XCTAssertEqual(list.itemsByCategory[.dairy]?.first?.name, "Milk")
        XCTAssertEqual(list.itemsByCategory[.bakery]?.first?.name, "Bread")
    }
    
    func testShoppingListCodable() {
        let item = Item(
            name: "Test Item",
            quantity: 1,
            category: .other,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        let originalList = ShoppingList(
            name: "Test List",
            items: [item],
            dateCreated: Date(),
            isShared: true,
            sharedWith: ["user1", "user2"]
        )
        
        do {
            let encoded = try JSONEncoder().encode(originalList)
            let decoded = try JSONDecoder().decode(ShoppingList.self, from: encoded)
            
            XCTAssertEqual(originalList.name, decoded.name)
            XCTAssertEqual(originalList.items.count, decoded.items.count)
            XCTAssertEqual(originalList.isShared, decoded.isShared)
            XCTAssertEqual(originalList.sharedWith, decoded.sharedWith)
        } catch {
            XCTFail("Failed to encode/decode ShoppingList: \(error)")
        }
    }
} 