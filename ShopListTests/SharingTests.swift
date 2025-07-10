import XCTest
@testable import ShopList
import SwiftData

@MainActor
final class SharingTests: XCTestCase {
    var viewModel: ShoppingListViewModel!
    
    override func setUp() {
        super.setUp()
        // Create a test ModelContext for the view model
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ShoppingList.self, Item.self, ItemHistory.self, Location.self, configurations: config)
            let modelContext = container.mainContext
            viewModel = ShoppingListViewModel.createForTesting(modelContext: modelContext)
        } catch {
            XCTFail("Failed to create test ModelContext: \(error)")
        }
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testGenerateShareableContent() {
        // Create a simple test with minimal data
        let item1 = Item(
            name: "Milk",
            quantity: Decimal(1),
            category: .dairy,
            isCompleted: false,
            notes: nil,
            dateAdded: Date(),
            pricePerUnit: nil,
            unit: nil
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item1],
            category: .groceries,
            budget: nil
        )
        
        // Generate shareable content
        let content = viewModel.generateShareableContent(for: list, currency: .USD)
        
        // Debug: Print the actual content to see what we're getting
        print("DEBUG: Generated content:")
        print(content)
        
        // Basic assertions that should definitely work
        XCTAssertTrue(content.contains("🛒 Test List"))
        XCTAssertTrue(content.contains("📋 Items (1 total):"))
        XCTAssertTrue(content.contains("Milk"))
        XCTAssertTrue(content.contains("Shared from ShopList App"))
    }
    
    func testGenerateCSVContent() {
        // Create a simple test with minimal data
        let item1 = Item(
            name: "Milk",
            quantity: Decimal(1),
            category: .dairy,
            isCompleted: false,
            notes: nil,
            dateAdded: Date(),
            pricePerUnit: nil,
            unit: nil
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item1],
            category: .groceries
        )
        
        // Generate CSV content
        let csv = viewModel.generateCSVContent(for: list, currency: .USD)
        
        // Debug: Print the actual CSV to see what we're getting
        print("DEBUG: Generated CSV:")
        print(csv)
        
        // Basic assertions that should definitely work
        XCTAssertTrue(csv.contains("No.,Name,Quantity,Unit,Price ($),Notes,Completed"))
        XCTAssertTrue(csv.contains("Milk"))
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
            category: .produce,
            isCompleted: false,
            notes: nil,
            dateAdded: Date(),
            pricePerUnit: Decimal(1.99),
            unit: "piece"
        )
        
        let item2 = Item(
            name: "Apple",
            quantity: Decimal(6),
            category: .produce,
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
            category: .produce,
            isCompleted: false,
            notes: nil,
            dateAdded: Date(),
            pricePerUnit: Decimal(0.25),
            unit: "piece"
        )
        
        let item2 = Item(
            name: "Carrot",
            quantity: Decimal(2),
            category: .produce,
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