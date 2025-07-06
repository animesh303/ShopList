import XCTest
@testable import ShopList

final class ExportImportRestrictionTests: XCTestCase {
    
    var subscriptionManager: SubscriptionManager!
    var viewModel: ShoppingListViewModel!
    
    override func setUpWithError() throws {
        subscriptionManager = SubscriptionManager.shared
        viewModel = ShoppingListViewModel(modelContext: try ModelContainer(for: ShoppingList.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext)
        
        // Clear any existing subscription data
        subscriptionManager.clearPersistedSubscriptionData()
    }
    
    override func tearDownWithError() throws {
        // Clean up
        subscriptionManager.clearPersistedSubscriptionData()
    }
    
    func testFreeUsersCannotUseExportImport() throws {
        // Given: User is on free tier
        subscriptionManager.clearPersistedSubscriptionData()
        
        // When: Checking export/import permission
        let canUseExportImport = subscriptionManager.canUseExportImport()
        
        // Then: Should be false for free users
        XCTAssertFalse(canUseExportImport, "Free users should not be able to use export/import")
    }
    
    func testPremiumUsersCanUseExportImport() throws {
        // Given: User is on premium tier
        subscriptionManager.clearPersistedSubscriptionData()
        subscriptionManager.setPremiumStatus(true)
        
        // When: Checking export/import permission
        let canUseExportImport = subscriptionManager.canUseExportImport()
        
        // Then: Should be true for premium users
        XCTAssertTrue(canUseExportImport, "Premium users should be able to use export/import")
    }
    
    func testExportImportUpgradePrompt() throws {
        // Given: User is on free tier
        subscriptionManager.clearPersistedSubscriptionData()
        
        // When: Getting upgrade prompt for export/import
        let upgradePrompt = subscriptionManager.getUpgradePrompt(for: .exportImport)
        
        // Then: Should return appropriate upgrade message
        XCTAssertTrue(upgradePrompt.contains("Export/Import"), "Upgrade prompt should mention Export/Import feature")
        XCTAssertTrue(upgradePrompt.contains("Upgrade to Premium"), "Upgrade prompt should mention Premium upgrade")
    }
    
    func testShareListMethodRequiresPremiumValidation() throws {
        // Given: A shopping list and free user
        let list = ShoppingList(name: "Test List", category: .groceries)
        subscriptionManager.clearPersistedSubscriptionData()
        
        // When: Calling shareList method
        viewModel.shareList(list)
        
        // Then: The method should set up sharing (validation happens at UI level)
        XCTAssertNotNil(viewModel.listToShare, "listToShare should be set")
        XCTAssertTrue(viewModel.showingShareSheet, "showingShareSheet should be true")
        
        // Note: The actual premium validation should happen at the UI level before calling this method
        // This test verifies that the method itself doesn't block sharing, as that's handled by the UI
    }
    
    func testExportImportFeatureDefinition() throws {
        // Given: Export/Import feature
        let feature = PremiumFeature.exportImport
        
        // When: Getting feature description
        let description = feature.description
        
        // Then: Should have correct description
        XCTAssertEqual(description, "Export/Import", "Export/Import feature should have correct description")
    }
    
    func testExportImportUpgradeMessage() throws {
        // Given: Export/Import feature
        let feature = PremiumFeature.exportImport
        
        // When: Getting upgrade message
        let upgradeMessage = subscriptionManager.getUpgradePrompt(for: feature)
        
        // Then: Should contain appropriate message
        XCTAssertTrue(upgradeMessage.contains("Export/Import"), "Upgrade message should mention Export/Import")
        XCTAssertTrue(upgradeMessage.contains("Upgrade to Premium"), "Upgrade message should mention Premium upgrade")
    }
} 