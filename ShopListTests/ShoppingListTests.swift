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
    
    func testShoppingListProperties() {
        let item = Item(
            name: "Test Item",
            quantity: 2,
            category: .other,
            isCompleted: false,
            notes: "Test notes",
            dateAdded: Date(),
            pricePerUnit: 1.50
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item],
            dateCreated: Date(),
            isShared: true,
            category: .groceries,
            isTemplate: false,
            budget: 100.0
        )
        
        XCTAssertEqual(list.name, "Test List")
        XCTAssertEqual(list.items.count, 1)
        XCTAssertTrue(list.isShared)
        XCTAssertEqual(list.category, .groceries)
        XCTAssertFalse(list.isTemplate)
        XCTAssertEqual(list.budget, 100.0)
        XCTAssertEqual(list.estimatedTotal, 3.0) // 2 * 1.50
        XCTAssertEqual(list.totalEstimatedCost, 3.0)
        XCTAssertEqual(list.totalSpentCost, 0.0) // No completed items
    }
    
    func testShoppingListMethods() {
        let list = ShoppingList(name: "Test List")
        
        // Test addItem
        let item1 = Item(name: "Item 1", category: .other)
        list.addItem(item1)
        XCTAssertEqual(list.items.count, 1)
        XCTAssertEqual(list.items.first?.name, "Item 1")
        
        // Test removeItem
        list.removeItem(item1)
        XCTAssertEqual(list.items.count, 0)
        
        // Test toggleItemCompletion
        let item2 = Item(name: "Item 2", category: .other)
        list.addItem(item2)
        XCTAssertFalse(item2.isCompleted)
        
        list.toggleItemCompletion(item2)
        XCTAssertTrue(list.items.first?.isCompleted ?? false)
        
        // Test updateItem
        // Note: updateItem expects to match by id, so updatedItem must have the same id as item2
        print("testShoppingListMethods: Before update - items: \(list.items.map { "\($0.name)(id:\($0.id))" })")
        
        let updatedItem = Item(
            id: item2.id,
            name: "Updated Item",
            quantity: 3,
            category: item2.category,
            isCompleted: true,
            notes: "Updated notes",
            dateAdded: item2.dateAdded,
            pricePerUnit: item2.pricePerUnit,
            brand: item2.brand,
            unit: item2.unit,
            lastPurchasedPrice: item2.lastPurchasedPrice,
            lastPurchasedDate: item2.lastPurchasedDate,
            imageData: item2.imageData,
            priority: item2.priority
        )
        
        print("testShoppingListMethods: Updated item - name:\(updatedItem.name), id:\(updatedItem.id)")
        
        list.updateItem(updatedItem)
        
        print("testShoppingListMethods: After update - items: \(list.items.map { "\($0.name)(id:\($0.id))" })")
        
        XCTAssertEqual(list.items.first?.name, "Updated Item")
        XCTAssertEqual(list.items.first?.quantity, 3)
        XCTAssertTrue(list.items.first?.isCompleted ?? false)
    }
    
    func testShoppingListCalculations() {
        let item1 = Item(
            name: "Item 1",
            quantity: 2,
            category: .other,
            isCompleted: true,
            dateAdded: Date(),
            pricePerUnit: 2.50
        )
        
        let item2 = Item(
            name: "Item 2",
            quantity: 1,
            category: .other,
            isCompleted: false,
            dateAdded: Date(),
            pricePerUnit: 1.00
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item1, item2],
            dateCreated: Date()
        )
        
        XCTAssertEqual(list.estimatedTotal, 6.0) // (2 * 2.50) + (1 * 1.00)
        XCTAssertEqual(list.totalEstimatedCost, 6.0)
        XCTAssertEqual(list.totalSpentCost, 5.0) // Only completed item: 2 * 2.50
        XCTAssertEqual(list.completedItems.count, 1)
        XCTAssertEqual(list.pendingItems.count, 1)
    }
    
    func testShoppingListCommonUnits() {
        let units = ShoppingList.commonUnits
        XCTAssertFalse(units.isEmpty)
        XCTAssertTrue(units.contains("kg"))
        XCTAssertTrue(units.contains("g"))
        XCTAssertTrue(units.contains("l"))
        XCTAssertTrue(units.contains("ml"))
        XCTAssertTrue(units.contains("piece"))
        XCTAssertTrue(units.contains("pack"))
        XCTAssertTrue(units.contains("bottle"))
    }
} 