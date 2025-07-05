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
        XCTAssertTrue(content.contains("📊 Category: Groceries"))
        XCTAssertTrue(content.contains("💰 Budget: $50.00"))
        XCTAssertTrue(content.contains("📋 Items (2 total):"))
        XCTAssertTrue(content.contains("Dairy:"))
        XCTAssertTrue(content.contains("Bakery:"))
        XCTAssertTrue(content.contains("⭕ Milk (2) gallon - $3.99 (Organic)"))
        XCTAssertTrue(content.contains("✅ Bread (1) loaf - $2.49"))
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
        XCTAssertTrue(csv.contains("Name,Quantity,Unit,Category,Price,Notes,Completed"))
        XCTAssertTrue(csv.contains("Milk,2,gallon,Dairy,3.99,Organic,No"))
        XCTAssertTrue(csv.contains("Bread,1,loaf,Bakery,2.49,,Yes"))
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
} 