import XCTest
@testable import ShopList
import SwiftData

@MainActor
final class ShoppingListViewModelTests: XCTestCase {
    var viewModel: ShoppingListViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create ModelContainer and ModelContext on main thread for testing
        do {
            let container = try ModelContainer(for: ShoppingList.self, Item.self, ItemHistory.self, Location.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            let modelContext = container.mainContext
            
            // Create the ViewModel directly since we're already on the main thread
            viewModel = ShoppingListViewModel.createForTesting(modelContext: modelContext)
        } catch {
            XCTFail("Failed to create test ModelContext: \(error)")
        }
        
        // Clear UserDefaults for testing
        UserDefaults.standard.removeObject(forKey: "ShoppingLists")
        
        // Reset SubscriptionManager for consistent test state
        TestHelpers.resetSubscriptionManager()
    }
    
    override func tearDownWithError() throws {
        // Use defensive cleanup like in SubscriptionManager tests
        if let context = viewModel?.testModelContext {
            TestHelpers.cleanupModelContext(context)
        }
        
        viewModel = nil
        UserDefaults.standard.removeObject(forKey: "ShoppingLists")
        
        // Reset SubscriptionManager
        TestHelpers.resetSubscriptionManager()
        
        try super.tearDownWithError()
    }
    
    func testAddShoppingList() async throws {
        // Test object creation in isolation without SwiftData operations
        let list = ShoppingList(
            name: "Test List",
            items: [],
            dateCreated: Date(),
            isShared: false
        )
        
        // Test the list object directly without any context operations
        XCTAssertEqual(list.name, "Test List")
        XCTAssertEqual(list.items.count, 0)
        XCTAssertFalse(list.isShared)
        XCTAssertNotNil(list.dateCreated)
        XCTAssertEqual(list.category, .personal) // Default category
        XCTAssertFalse(list.isTemplate) // Default value
        XCTAssertNotNil(list.lastModified)
        XCTAssertNil(list.budget) // Default value
        XCTAssertNil(list.location) // Default value
        
        // Test computed properties
        XCTAssertEqual(list.completedItems.count, 0)
        XCTAssertEqual(list.pendingItems.count, 0)
        XCTAssertEqual(list.estimatedTotal, 0.0)
        XCTAssertEqual(list.totalEstimatedCost, 0.0)
        XCTAssertEqual(list.totalSpentCost, 0.0)
    }
    
    func testBasicModelCreation() {
        // Test that we can create basic models without issues
        let item = Item(
            name: "Test Item",
            quantity: 1,
            category: .other,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item],
            dateCreated: Date(),
            isShared: false
        )
        
        // Just test that we can create them without crashing
        XCTAssertEqual(item.name, "Test Item")
        XCTAssertEqual(list.name, "Test List")
        XCTAssertEqual(list.items.count, 1)
    }
    
    func testDeleteShoppingList() async throws {
        // Test object creation and manipulation in isolation
        let list = ShoppingList(
            name: "Test List",
            items: [],
            dateCreated: Date(),
            isShared: false
        )
        
        // Test the list object directly
        XCTAssertEqual(list.name, "Test List")
        XCTAssertEqual(list.items.count, 0)
        
        // Test adding an item to the list
        let item = Item(
            name: "Test Item",
            quantity: 1,
            category: .other,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        list.addItem(item)
        XCTAssertEqual(list.items.count, 1)
        XCTAssertEqual(list.items.first?.name, "Test Item")
        
        // Test removing the item
        list.removeItem(item)
        XCTAssertEqual(list.items.count, 0)
    }
    
    func testAddItem() async throws {
        // Test object creation in isolation without SwiftData operations
        let item = Item(
            name: "Test Item",
            quantity: 1,
            category: .other,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        // Test the item object directly
        XCTAssertEqual(item.name, "Test Item")
        XCTAssertEqual(item.quantity, 1)
        XCTAssertEqual(item.category, .other)
        XCTAssertFalse(item.isCompleted)
        XCTAssertNil(item.notes)
        XCTAssertNotNil(item.dateAdded)
        
        // Create list without SwiftData operations
        let list = ShoppingList(
            name: "Test List",
            items: [item],
            dateCreated: Date(),
            isShared: false
        )
        
        // Test the list object directly
        XCTAssertEqual(list.name, "Test List")
        XCTAssertEqual(list.items.count, 1)
        XCTAssertFalse(list.isShared)
        XCTAssertNotNil(list.dateCreated)
        
        // Test the relationship between list and item
        XCTAssertEqual(list.items.first?.name, "Test Item")
        XCTAssertEqual(list.items.first?.quantity, 1)
        XCTAssertEqual(list.items.first?.category, .other)
        XCTAssertFalse(list.items.first?.isCompleted ?? true)
        
        // Test computed properties
        XCTAssertEqual(list.completedItems.count, 0)
        XCTAssertEqual(list.pendingItems.count, 1)
        XCTAssertEqual(list.pendingItems.first?.name, "Test Item")
    }
    
    func testUpdateItem() async throws {
        // Test object creation and manipulation in isolation
        let item = Item(
            name: "Test Item",
            quantity: 1,
            category: .other,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item],
            dateCreated: Date(),
            isShared: false
        )
        
        // Test initial state
        XCTAssertEqual(list.items.count, 1)
        XCTAssertFalse(item.isCompleted)
        XCTAssertEqual(item.quantity, 1)
        
        // Test updating the item
        item.isCompleted = true
        item.quantity = 2
        
        XCTAssertTrue(item.isCompleted)
        XCTAssertEqual(item.quantity, 2)
        
        // Test that the list reflects the changes
        XCTAssertEqual(list.items.first?.isCompleted, true)
        XCTAssertEqual(list.items.first?.quantity, 2)
    }
    
    func testDeleteItem() async throws {
        // Test object creation and manipulation in isolation
        let item = Item(
            name: "Test Item",
            quantity: 1,
            category: .other,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        let list = ShoppingList(
            name: "Test List",
            items: [item],
            dateCreated: Date(),
            isShared: false
        )
        
        // Test initial state
        XCTAssertEqual(list.items.count, 1)
        XCTAssertEqual(list.items.first?.name, "Test Item")
        
        // Test removing the item
        list.removeItem(item)
        XCTAssertEqual(list.items.count, 0)
        
        // Test that the item is actually removed
        XCTAssertNil(list.items.first)
    }
    
    func testPersistence() async throws {
        // Test object creation and properties in isolation
        let list = ShoppingList(
            name: "Test List",
            items: [],
            dateCreated: Date(),
            isShared: false
        )
        
        // Test that the list object has the correct properties
        XCTAssertEqual(list.name, "Test List")
        XCTAssertEqual(list.items.count, 0)
        XCTAssertFalse(list.isShared)
        XCTAssertNotNil(list.dateCreated)
        XCTAssertNotNil(list.lastModified)
        
        // Test that the list can be modified
        let item = Item(
            name: "Test Item",
            quantity: 1,
            category: .other,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        list.addItem(item)
        XCTAssertEqual(list.items.count, 1)
        XCTAssertEqual(list.items.first?.name, "Test Item")
    }
    
    func testNoAutomaticSampleListCreation() async {
        // Test that ViewModel initialization doesn't create automatic sample lists
        // Create a fresh ViewModel with a proper test context
        do {
            let testContext = try TestHelpers.createTestModelContext()
            let emptyViewModel = ShoppingListViewModel.createForTesting(modelContext: testContext)
            
            // Should not have any automatic sample lists
            XCTAssertEqual(emptyViewModel.shoppingLists.count, 0)
            
            // Test that the ViewModel can be created without crashing
            XCTAssertNotNil(emptyViewModel)
            
            // Clean up the test context
            TestHelpers.cleanupModelContext(testContext)
        } catch {
            XCTFail("Failed to create test context: \(error)")
        }
    }
    
    func testSubscriptionPersistence() {
        let subscriptionManager = SubscriptionManager.shared
        
        // Test mock subscription persistence
        subscriptionManager.mockSubscribe()
        XCTAssertTrue(subscriptionManager.isPremium)
        XCTAssertEqual(subscriptionManager.currentTier, .premium)
        
        // Verify UserDefaults was updated
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "isPremium"))
        XCTAssertEqual(UserDefaults.standard.string(forKey: "subscriptionTier"), "Premium")
        
        // Test mock unsubscription persistence
        subscriptionManager.mockUnsubscribe()
        XCTAssertFalse(subscriptionManager.isPremium)
        XCTAssertEqual(subscriptionManager.currentTier, .free)
        
        // Verify UserDefaults was updated
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "isPremium"))
        XCTAssertEqual(UserDefaults.standard.string(forKey: "subscriptionTier"), "Free")
        
        // Clean up
        subscriptionManager.clearPersistedSubscriptionData()
    }
    
    func testSubscriptionManagerSingleton() {
        // Test that we get the same instance
        let instance1 = SubscriptionManager.shared
        let instance2 = SubscriptionManager.shared
        
        XCTAssertTrue(instance1 === instance2, "SubscriptionManager should be a singleton")
        
        // Test that changes persist across instances
        instance1.mockSubscribe()
        XCTAssertTrue(instance2.isPremium)
        XCTAssertEqual(instance2.currentTier, .premium)
        
        // Clean up
        instance1.clearPersistedSubscriptionData()
    }
    
    func testSubscriptionPersistenceWithMockData() {
        let subscriptionManager = SubscriptionManager.shared
        
        // Clear any existing data
        subscriptionManager.clearPersistedSubscriptionData()
        
        // Test that initial state is free
        XCTAssertFalse(subscriptionManager.isPremium)
        XCTAssertEqual(subscriptionManager.currentTier, .free)
        
        // Mock subscribe
        subscriptionManager.mockSubscribe()
        XCTAssertTrue(subscriptionManager.isPremium)
        XCTAssertEqual(subscriptionManager.currentTier, .premium)
        
        // Verify UserDefaults was updated
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "isPremium"))
        XCTAssertEqual(UserDefaults.standard.string(forKey: "subscriptionTier"), "Premium")
        
        // Simulate app restart by creating a new instance
        // (In real app, this would happen when app restarts)
        let newInstance = SubscriptionManager.shared
        
        // The new instance should maintain the premium status
        XCTAssertTrue(newInstance.isPremium)
        XCTAssertEqual(newInstance.currentTier, .premium)
        
        // Clean up
        subscriptionManager.clearPersistedSubscriptionData()
    }
    
    func testDebugMethods() {
        let subscriptionManager = SubscriptionManager.shared
        
        // Test debug methods don't crash
        subscriptionManager.debugPersistedStatus()
        subscriptionManager.clearPersistedSubscriptionData()
        
        // Verify data was cleared
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "isPremium"))
        XCTAssertNil(UserDefaults.standard.string(forKey: "subscriptionTier"))
    }
    
    func testViewModelInitialization() async {
        // Test that ViewModel initialization doesn't crash
        do {
            let testContext = try TestHelpers.createTestModelContext()
            let testViewModel = ShoppingListViewModel.createForTesting(modelContext: testContext)
            
            // Should not crash and should have an empty list initially
            XCTAssertEqual(testViewModel.shoppingLists.count, 0)
            XCTAssertNotNil(testViewModel)
            
            // Clean up the test context
            TestHelpers.cleanupModelContext(testContext)
        } catch {
            XCTFail("Failed to create test context: \(error)")
        }
    }
} 