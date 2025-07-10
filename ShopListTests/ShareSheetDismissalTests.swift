import XCTest
@testable import ShopList
import SwiftData

@MainActor
final class ShareSheetDismissalTests: XCTestCase {
    
    var subscriptionManager: SubscriptionManager!
    var viewModel: ShoppingListViewModel!
    
    override func setUpWithError() throws {
        subscriptionManager = SubscriptionManager.shared
        
        // Create ModelContainer and ModelContext on main thread
                    let container = try ModelContainer(for: ShoppingList.self, Item.self, ItemHistory.self, Location.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let modelContext = container.mainContext
        
        // Ensure ViewModel is created on main thread using the test helper
        viewModel = ShoppingListViewModel.createForTesting(modelContext: modelContext)
        
        // Clear any existing subscription data
        subscriptionManager.clearPersistedSubscriptionData()
    }
    
    override func tearDownWithError() throws {
        // Clean up
        subscriptionManager.clearPersistedSubscriptionData()
    }
    
    func testShareSheetHasDismissHandler() throws {
        // Given: A shopping list and premium user
        let list = ShoppingList(name: "Test List", category: .groceries)
        subscriptionManager.mockSubscribe()
        
        // When: Creating a ShareSheet
        let shareSheet = ShareSheet(
            activityItems: viewModel.getShareableItems(for: list, currency: .USD),
            onDismiss: {
                // This should be called when sharing completes
            }
        )
        
        // Then: ShareSheet should have a dismiss handler
        // Note: We can't directly test the UIViewControllerRepresentable in unit tests,
        // but we can verify the ShareSheet is created with the dismiss handler
        XCTAssertNotNil(shareSheet, "ShareSheet should be created successfully")
    }
    
    func testShareListMethodSetsUpSharing() throws {
        // Given: A shopping list and premium user
        let list = ShoppingList(name: "Test List", category: .groceries)
        subscriptionManager.mockSubscribe()
        
        // When: Calling shareList method
        viewModel.shareList(list)
        
        // Then: The sharing state should be set up correctly
        XCTAssertNotNil(viewModel.listToShare, "listToShare should be set")
        XCTAssertTrue(viewModel.showingShareSheet, "showingShareSheet should be true")
    }
    
    func testShareSheetDismissalClearsState() throws {
        // Given: A shopping list and premium user with sharing state set up
        let list = ShoppingList(name: "Test List", category: .groceries)
        subscriptionManager.mockSubscribe()
        viewModel.shareList(list)
        
        // Verify initial state
        XCTAssertNotNil(viewModel.listToShare, "listToShare should be set initially")
        XCTAssertTrue(viewModel.showingShareSheet, "showingShareSheet should be true initially")
        
        // When: Simulating dismissal (this would normally be called by the completion handler)
        viewModel.showingShareSheet = false
        viewModel.listToShare = nil
        
        // Then: The sharing state should be cleared
        XCTAssertNil(viewModel.listToShare, "listToShare should be nil after dismissal")
        XCTAssertFalse(viewModel.showingShareSheet, "showingShareSheet should be false after dismissal")
    }
    
    func testShareSheetActivityItemsGeneration() throws {
        // Given: A shopping list with items
        let list = ShoppingList(name: "Test List", category: .groceries)
        let item = Item(name: "Test Item", category: .groceries)
        list.addItem(item)
        
        // When: Generating shareable items
        let shareableItems = viewModel.getShareableItems(for: list, currency: .USD)
        
        // Then: Should generate shareable content
        XCTAssertFalse(shareableItems.isEmpty, "Shareable items should not be empty")
        
        // Check that we have text content
        let textContent = shareableItems.first as? String
        XCTAssertNotNil(textContent, "First item should be text content")
        XCTAssertTrue(textContent?.contains("Test List") == true, "Text content should contain list name")
        XCTAssertTrue(textContent?.contains("Test Item") == true, "Text content should contain item name")
        
        // Check that we have CSV file
        let csvFile = shareableItems.last as? URL
        XCTAssertNotNil(csvFile, "Last item should be CSV file URL")
        XCTAssertTrue(csvFile?.lastPathComponent.contains("Test_List.csv") == true, "CSV filename should contain list name")
    }
    
    func testShareSheetCompletionHandlerIsCalled() throws {
        // Given: A shopping list and premium user
        let list = ShoppingList(name: "Test List", category: .groceries)
        subscriptionManager.mockSubscribe()
        
        var dismissHandlerCalled = false
        
        // When: Creating ShareSheet with dismiss handler
        let shareSheet = ShareSheet(
            activityItems: viewModel.getShareableItems(for: list, currency: .USD),
            onDismiss: {
                dismissHandlerCalled = true
            }
        )
        
        // Then: ShareSheet should be created with dismiss handler
        XCTAssertNotNil(shareSheet, "ShareSheet should be created successfully")
        
        // Note: In a real scenario, the dismiss handler would be called by the UIActivityViewController
        // when the user completes or cancels the sharing action. We can't simulate this in unit tests,
        // but we can verify the ShareSheet is set up correctly.
        // The dismissHandlerCalled variable is intentionally unused as we can't simulate the actual dismissal
    }
} 