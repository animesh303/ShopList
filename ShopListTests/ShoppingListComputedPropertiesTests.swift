import XCTest
@testable import ShopList

final class ShoppingListComputedPropertiesTests: XCTestCase {
    
    func testEstimatedTotalWithPricedItems() {
        let item1 = Item(
            name: "Milk",
            quantity: 2,
            category: .dairy,
            pricePerUnit: 3.99
        )
        
        let item2 = Item(
            name: "Bread",
            quantity: 1,
            category: .bakery,
            pricePerUnit: 2.49
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item1, item2]
        )
        
        // Expected: (2 * 3.99) + (1 * 2.49) = 7.98 + 2.49 = 10.47
        XCTAssertEqual(list.estimatedTotal, 10.47, accuracy: 0.01)
        XCTAssertEqual(list.totalEstimatedCost, 10.47, accuracy: 0.01)
    }
    
    func testEstimatedTotalWithUnpricedItems() {
        let item1 = Item(
            name: "Milk",
            quantity: 2,
            category: .dairy
        )
        
        let item2 = Item(
            name: "Bread",
            quantity: 1,
            category: .bakery,
            pricePerUnit: 2.49
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item1, item2]
        )
        
        // Expected: (2 * 0) + (1 * 2.49) = 0 + 2.49 = 2.49
        XCTAssertEqual(list.estimatedTotal, 2.49, accuracy: 0.01)
    }
    
    func testTotalSpentCostWithCompletedItems() {
        let completedItem1 = Item(
            name: "Milk",
            quantity: 2,
            category: .dairy,
            isCompleted: true,
            pricePerUnit: 3.99
        )
        
        let completedItem2 = Item(
            name: "Bread",
            quantity: 1,
            category: .bakery,
            isCompleted: true,
            pricePerUnit: 2.49
        )
        
        let pendingItem = Item(
            name: "Eggs",
            quantity: 1,
            category: .dairy,
            isCompleted: false,
            pricePerUnit: 4.99
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [completedItem1, completedItem2, pendingItem]
        )
        
        // Expected: Only completed items (2 * 3.99) + (1 * 2.49) = 7.98 + 2.49 = 10.47
        XCTAssertEqual(list.totalSpentCost, 10.47, accuracy: 0.01)
    }
    
    func testTotalSpentCostWithNoCompletedItems() {
        let pendingItem1 = Item(
            name: "Milk",
            quantity: 2,
            category: .dairy,
            isCompleted: false,
            pricePerUnit: 3.99
        )
        
        let pendingItem2 = Item(
            name: "Bread",
            quantity: 1,
            category: .bakery,
            isCompleted: false,
            pricePerUnit: 2.49
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [pendingItem1, pendingItem2]
        )
        
        // Expected: No completed items, so total spent is 0
        XCTAssertEqual(list.totalSpentCost, 0.0, accuracy: 0.01)
    }
    
    func testAddItem() {
        let list = ShoppingList(name: "Test List")
        let originalCount = list.items.count
        let originalLastModified = list.lastModified
        
        let item = Item(
            name: "Milk",
            quantity: 1,
            category: .dairy
        )
        
        list.addItem(item)
        
        XCTAssertEqual(list.items.count, originalCount + 1)
        XCTAssertEqual(list.items.last?.name, "Milk")
        XCTAssertTrue(list.lastModified > originalLastModified)
    }
    
    func testRemoveItem() {
        let item = Item(
            name: "Milk",
            quantity: 1,
            category: .dairy
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item]
        )
        
        let originalCount = list.items.count
        let originalLastModified = list.lastModified
        
        list.removeItem(item)
        
        XCTAssertEqual(list.items.count, originalCount - 1)
        XCTAssertTrue(list.items.isEmpty)
        XCTAssertTrue(list.lastModified > originalLastModified)
    }
    
    func testToggleItemCompletion() {
        let item = Item(
            name: "Milk",
            quantity: 1,
            category: .dairy,
            isCompleted: false
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item]
        )
        
        let originalLastModified = list.lastModified
        
        list.toggleItemCompletion(item)
        
        XCTAssertTrue(list.items.first?.isCompleted == true)
        XCTAssertTrue(list.lastModified > originalLastModified)
        
        list.toggleItemCompletion(item)
        
        XCTAssertTrue(list.items.first?.isCompleted == false)
    }
    
    func testUpdateItem() {
        let item = Item(
            name: "Milk",
            quantity: 1,
            category: .dairy,
            isCompleted: false
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item]
        )
        
        let originalLastModified = list.lastModified
        
        let updatedItem = Item(
            id: item.id,
            name: "Organic Milk",
            quantity: 2,
            category: item.category,
            isCompleted: true,
            notes: item.notes,
            dateAdded: item.dateAdded,
            pricePerUnit: item.pricePerUnit,
            brand: item.brand,
            unit: item.unit,
            lastPurchasedPrice: item.lastPurchasedPrice,
            lastPurchasedDate: item.lastPurchasedDate,
            imageData: item.imageData,
            priority: item.priority
        )
        
        list.updateItem(updatedItem)
        
        XCTAssertEqual(list.items.first?.name, "Organic Milk")
        XCTAssertEqual(list.items.first?.quantity, 2)
        XCTAssertTrue(list.items.first?.isCompleted == true)
        XCTAssertTrue(list.lastModified > originalLastModified)
    }
    
    func testReorderItems() {
        // Create items with explicit IDs to avoid any SwiftData issues
        let item1 = Item(
            id: UUID(),
            name: "Milk", 
            quantity: 1,
            category: .dairy,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        let item2 = Item(
            id: UUID(),
            name: "Bread", 
            quantity: 1,
            category: .bakery,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        let item3 = Item(
            id: UUID(),
            name: "Eggs", 
            quantity: 1,
            category: .dairy,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item1, item2, item3]
        )
        
        print("testReorderItems: Initial order: \(list.items.map { $0.name })")
        
        let originalLastModified = list.lastModified
        
        // Based on the test results, toOffset seems to mean "insert at this position"
        // So moving from index 0 to position 2 should result in: [Bread, Milk, Eggs]
        list.reorderItems(from: IndexSet(integer: 0), to: 2)
        
        print("testReorderItems: Order after reorder: \(list.items.map { $0.name })")
        
        // Debug: Print each item's position
        for (index, item) in list.items.enumerated() {
            print("testReorderItems: Item at index \(index): \(item.name)")
        }
        
        // Based on the actual behavior, expect: [Bread, Milk, Eggs]
        XCTAssertEqual(list.items.count, 3, "Should still have 3 items")
        XCTAssertEqual(list.items[0].name, "Bread", "First item should be Bread")
        XCTAssertEqual(list.items[1].name, "Milk", "Second item should be Milk")
        XCTAssertEqual(list.items[2].name, "Eggs", "Third item should be Eggs")
        XCTAssertTrue(list.lastModified > originalLastModified, "lastModified should be updated")
    }
    
    func testReorderItemsSimple() {
        // Test the move operation in complete isolation
        var items = ["Milk", "Bread", "Eggs"]
        print("testReorderItemsSimple: Initial: \(items)")
        
        // Move "Milk" (index 0) to position 2
        items.move(fromOffsets: IndexSet(integer: 0), toOffset: 2)
        print("testReorderItemsSimple: After move: \(items)")
        
        // Based on the actual behavior, expect: ["Bread", "Milk", "Eggs"]
        XCTAssertEqual(items, ["Bread", "Milk", "Eggs"])
    }
    
    func testReorderItemsUnderstanding() {
        // Test to understand how move(fromOffsets:toOffset:) actually works
        var items = ["A", "B", "C", "D"]
        print("testReorderItemsUnderstanding: Initial: \(items)")
        
        // Move "A" (index 0) to position 2
        items.move(fromOffsets: IndexSet(integer: 0), toOffset: 2)
        print("testReorderItemsUnderstanding: After moving A to position 2: \(items)")
        
        // Based on the previous test results, let's see what actually happens
        // If we get ["B", "A", "C", "D"], then toOffset means "insert at this position"
        // If we get ["B", "C", "A", "D"], then toOffset means "insert after this position"
        
        // Let's test moving "B" (now at index 1) to position 3
        items.move(fromOffsets: IndexSet(integer: 1), toOffset: 3)
        print("testReorderItemsUnderstanding: After moving B to position 3: \(items)")
        
        // This will help us understand the correct behavior
    }
    
    func testCommonUnits() {
        let units = ShoppingList.commonUnits
        XCTAssertFalse(units.isEmpty)
        XCTAssertTrue(units.contains(""))
        XCTAssertTrue(units.contains("kg"))
        XCTAssertTrue(units.contains("g"))
        XCTAssertTrue(units.contains("l"))
        XCTAssertTrue(units.contains("ml"))
        XCTAssertTrue(units.contains("piece"))
        XCTAssertTrue(units.contains("dozen"))
        XCTAssertTrue(units.contains("box"))
        XCTAssertTrue(units.contains("pack"))
        XCTAssertTrue(units.contains("bottle"))
        XCTAssertTrue(units.contains("can"))
        XCTAssertTrue(units.contains("jar"))
        XCTAssertTrue(units.contains("bag"))
    }
} 