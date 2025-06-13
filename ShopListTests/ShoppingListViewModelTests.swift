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
} 