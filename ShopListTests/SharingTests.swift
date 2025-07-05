import XCTest
@testable import ShopList

final class SharingTests: XCTestCase {
    var viewModel: ShoppingListViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ShoppingListViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testGenerateShareableContent() {
        // Create a test shopping list
        let item1 = Item(
            name: "Milk",
            quantity: Decimal(2),
            category: .dairy,
            isCompleted: false,
            notes: "Organic",
            dateAdded: Date(),
            pricePerUnit: Decimal(3.99),
            unit: "gallon"
        )
        
        let item2 = Item(
            name: "Bread",
            quantity: Decimal(1),
            category: .bakery,
            isCompleted: true,
            notes: nil,
            dateAdded: Date(),
            pricePerUnit: Decimal(2.49),
            unit: "loaf"
        )
        
        let list = ShoppingList(
            name: "Grocery List",
            items: [item1, item2],
            category: .groceries,
            budget: 50.0
        )
        
        // Generate shareable content
        let content = viewModel.generateShareableContent(for: list, currency: .USD)
        
        // Verify content contains expected elements
        XCTAssertTrue(content.contains("🛒 Grocery List"))
        XCTAssertFalse(content.contains("📊 Category:")) // Category should not be included
        XCTAssertTrue(content.contains("💰 Budget: $50.00"))
        XCTAssertTrue(content.contains("📋 Items (2 total):"))
        XCTAssertTrue(content.contains("1. ⭕ Milk (2) gallon - $3.99 (Organic)"))
        XCTAssertTrue(content.contains("2. ✅ Bread (1) loaf - $2.49"))
        XCTAssertTrue(content.contains("Shared from ShopList App"))
    }
    
    func testGenerateCSVContent() {
        // Create a test shopping list
        let item1 = Item(
            name: "Milk",
            quantity: Decimal(2),
            category: .dairy,
            isCompleted: false,
            notes: "Organic",
            dateAdded: Date(),
            pricePerUnit: Decimal(3.99),
            unit: "gallon"
        )
        
        let item2 = Item(
            name: "Bread",
            quantity: Decimal(1),
            category: .bakery,
            isCompleted: true,
            notes: nil,
            dateAdded: Date(),
            pricePerUnit: Decimal(2.49),
            unit: "loaf"
        )
        
        let list = ShoppingList(
            name: "Grocery List",
            items: [item1, item2],
            category: .groceries
        )
        
        // Generate CSV content
        let csv = viewModel.generateCSVContent(for: list, currency: .USD)
        
        // Verify CSV contains expected elements
        XCTAssertTrue(csv.contains("No.,Name,Quantity,Unit,Price ($),Notes,Completed"))
        XCTAssertTrue(csv.contains("1,Milk,2,gallon,3.99,Organic,No"))
        XCTAssertTrue(csv.contains("2,Bread,1,loaf,2.49,,Yes"))
    }
    
    func testShareList() {
        let list = ShoppingList(name: "Test List")
        
        // Initially, no list should be set for sharing
        XCTAssertNil(viewModel.listToShare)
        XCTAssertFalse(viewModel.showingShareSheet)
        
        // Share the list
        viewModel.shareList(list)
        
        // Verify the list is set for sharing
        XCTAssertEqual(viewModel.listToShare?.name, "Test List")
        XCTAssertTrue(viewModel.showingShareSheet)
    }
    
    func testGetShareableItems() {
        let item = Item(
            name: "Test Item",
            quantity: Decimal(1),
            category: .other,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item],
            category: .other
        )
        
        let shareableItems = viewModel.getShareableItems(for: list, currency: .USD)
        
        // Should contain at least the text content
        XCTAssertGreaterThan(shareableItems.count, 0)
        
        // First item should be a string (text content)
        XCTAssertTrue(shareableItems[0] is String)
        
        // Should also contain CSV file URL if available
        if shareableItems.count > 1 {
            XCTAssertTrue(shareableItems[1] is URL)
        }
    }
    
    func testSerialNumberFormatting() {
        // Create a test shopping list with items in different order
        let item1 = Item(
            name: "Zucchini",
            quantity: Decimal(3),
            category: .vegetables,
            isCompleted: false,
            notes: nil,
            dateAdded: Date(),
            pricePerUnit: Decimal(1.99),
            unit: "piece"
        )
        
        let item2 = Item(
            name: "Apple",
            quantity: Decimal(6),
            category: .fruits,
            isCompleted: true,
            notes: "Red apples",
            dateAdded: Date(),
            pricePerUnit: Decimal(0.50),
            unit: "piece"
        )
        
        let list = ShoppingList(
            name: "Fruit & Veg List",
            items: [item1, item2],
            category: .groceries
        )
        
        // Generate shareable content
        let content = viewModel.generateShareableContent(for: list, currency: .USD)
        
        // Verify items are sorted alphabetically and have serial numbers
        XCTAssertTrue(content.contains("1. ✅ Apple (6) piece - $0.50 (Red apples)"))
        XCTAssertTrue(content.contains("2. ⭕ Zucchini (3) piece - $1.99"))
        
        // Verify no category information is included
        XCTAssertFalse(content.contains("Category:"))
        XCTAssertFalse(content.contains("Fruits:"))
        XCTAssertFalse(content.contains("Vegetables:"))
    }
    
    func testCSVSerialNumberFormatting() {
        // Create a test shopping list
        let item1 = Item(
            name: "Banana",
            quantity: Decimal(5),
            category: .fruits,
            isCompleted: false,
            notes: nil,
            dateAdded: Date(),
            pricePerUnit: Decimal(0.25),
            unit: "piece"
        )
        
        let item2 = Item(
            name: "Carrot",
            quantity: Decimal(2),
            category: .vegetables,
            isCompleted: true,
            notes: "Organic",
            dateAdded: Date(),
            pricePerUnit: Decimal(1.50),
            unit: "bunch"
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item1, item2],
            category: .groceries
        )
        
        // Generate CSV content
        let csv = viewModel.generateCSVContent(for: list, currency: .USD)
        
        // Verify CSV has correct header and serial numbers
        XCTAssertTrue(csv.contains("No.,Name,Quantity,Unit,Price ($),Notes,Completed"))
        XCTAssertTrue(csv.contains("1,Banana,5,piece,0.25,,No"))
        XCTAssertTrue(csv.contains("2,Carrot,2,bunch,1.50,Organic,Yes"))
        
        // Verify no category column
        XCTAssertFalse(csv.contains("Category"))
    }
} 