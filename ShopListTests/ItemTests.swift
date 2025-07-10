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
    

    
    func testItemWithOptionalProperties() {
        let item = Item(
            name: "Test Item",
            quantity: 1.5,
            category: .groceries,
            isCompleted: false,
            notes: "Test notes",
            dateAdded: Date(),
            pricePerUnit: 2.99,
            brand: "Test Brand",
            unit: "kg",
            lastPurchasedPrice: 2.50,
            lastPurchasedDate: Date(),
            imageData: Data(),
            priority: .high
        )
        
        XCTAssertEqual(item.name, "Test Item")
        XCTAssertEqual(item.quantity, 1.5)
        XCTAssertEqual(item.category, .groceries)
        XCTAssertFalse(item.isCompleted)
        XCTAssertEqual(item.notes, "Test notes")
        XCTAssertEqual(item.pricePerUnit, 2.99)
        XCTAssertEqual(item.brand, "Test Brand")
        XCTAssertEqual(item.unit, "kg")
        XCTAssertEqual(item.lastPurchasedPrice, 2.50)
        XCTAssertNotNil(item.lastPurchasedDate)
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.priority, .high)
    }
    
    func testItemCategoryAllCases() {
        let categories = ItemCategory.allCases
        XCTAssertFalse(categories.isEmpty)
        XCTAssertTrue(categories.contains(.produce))
        XCTAssertTrue(categories.contains(.dairy))
        XCTAssertTrue(categories.contains(.meat))
        XCTAssertTrue(categories.contains(.bakery))
        XCTAssertTrue(categories.contains(.frozenFoods))
        XCTAssertTrue(categories.contains(.snacks))
        XCTAssertTrue(categories.contains(.beverages))
        XCTAssertTrue(categories.contains(.household))
        XCTAssertTrue(categories.contains(.other))
        XCTAssertTrue(categories.contains(.groceries))
        XCTAssertTrue(categories.contains(.cleaning))
        XCTAssertTrue(categories.contains(.personalCare))
    }
    
    func testItemCategoryIcons() {
        XCTAssertEqual(ItemCategory.produce.icon, "leaf.fill")
        XCTAssertEqual(ItemCategory.dairy.icon, "drop.fill")
        XCTAssertEqual(ItemCategory.bakery.icon, "birthday.cake.fill")
        XCTAssertEqual(ItemCategory.meat.icon, "fish.fill")
        XCTAssertEqual(ItemCategory.frozenFoods.icon, "snowflake")
        XCTAssertEqual(ItemCategory.beverages.icon, "mug.fill")
        XCTAssertEqual(ItemCategory.snacks.icon, "takeoutbag.and.cup.and.straw.fill")
        XCTAssertEqual(ItemCategory.household.icon, "house.fill")
        XCTAssertEqual(ItemCategory.other.icon, "questionmark.circle.fill")
    }
    

} 