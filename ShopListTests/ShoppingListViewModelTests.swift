import XCTest
@testable import ShopList

final class ShoppingListViewModelTests: XCTestCase {
    var viewModel: ShoppingListViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ShoppingListViewModel()
        // Clear UserDefaults for testing
        UserDefaults.standard.removeObject(forKey: "ShoppingLists")
    }
    
    override func tearDown() {
        viewModel = nil
        UserDefaults.standard.removeObject(forKey: "ShoppingLists")
        super.tearDown()
    }
    
    func testAddShoppingList() {
        let list = ShoppingList(
            name: "Test List",
            items: [],
            dateCreated: Date(),
            isShared: false
        )
        
        viewModel.addShoppingList(list)
        
        XCTAssertEqual(viewModel.shoppingLists.count, 1)
        XCTAssertEqual(viewModel.shoppingLists.first?.name, "Test List")
    }
    
    func testDeleteShoppingList() {
        let list = ShoppingList(
            name: "Test List",
            items: [],
            dateCreated: Date(),
            isShared: false
        )
        
        viewModel.addShoppingList(list)
        XCTAssertEqual(viewModel.shoppingLists.count, 1)
        
        viewModel.deleteShoppingList(list)
        XCTAssertEqual(viewModel.shoppingLists.count, 0)
    }
    
    func testAddItem() {
        let list = ShoppingList(
            name: "Test List",
            items: [],
            dateCreated: Date(),
            isShared: false
        )
        
        viewModel.addShoppingList(list)
        
        let item = Item(
            name: "Test Item",
            quantity: 1,
            category: .other,
            isCompleted: false,
            notes: nil,
            dateAdded: Date()
        )
        
        viewModel.addItem(item, to: list)
        
        XCTAssertEqual(viewModel.shoppingLists.first?.items.count, 1)
        XCTAssertEqual(viewModel.shoppingLists.first?.items.first?.name, "Test Item")
    }
    
    func testUpdateItem() {
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
        
        viewModel.addShoppingList(list)
        
        var updatedItem = item
        updatedItem.isCompleted = true
        updatedItem.quantity = 2
        
        viewModel.updateItem(updatedItem, in: list)
        
        XCTAssertEqual(viewModel.shoppingLists.first?.items.first?.isCompleted, true)
        XCTAssertEqual(viewModel.shoppingLists.first?.items.first?.quantity, 2)
    }
    
    func testDeleteItem() {
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
        
        viewModel.addShoppingList(list)
        XCTAssertEqual(viewModel.shoppingLists.first?.items.count, 1)
        
        viewModel.deleteItem(item, from: list)
        XCTAssertEqual(viewModel.shoppingLists.first?.items.count, 0)
    }
    
    func testPersistence() {
        let list = ShoppingList(
            name: "Test List",
            items: [],
            dateCreated: Date(),
            isShared: false
        )
        
        viewModel.addShoppingList(list)
        
        // Create a new view model instance to test persistence
        let newViewModel = ShoppingListViewModel()
        
        XCTAssertEqual(newViewModel.shoppingLists.count, 1)
        XCTAssertEqual(newViewModel.shoppingLists.first?.name, "Test List")
    }
    
    func testNoAutomaticSampleListCreation() {
        // Test that no automatic sample list is created when view model is initialized
        let emptyViewModel = ShoppingListViewModel()
        
        // Wait a bit for async operations to complete
        let expectation = XCTestExpectation(description: "Wait for async operations")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Should not have any automatic sample lists
            XCTAssertEqual(emptyViewModel.shoppingLists.count, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
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
} 