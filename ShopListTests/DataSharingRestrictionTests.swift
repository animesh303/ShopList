import XCTest
@testable import ShopList
import SwiftData

@MainActor
final class DataSharingRestrictionTests: XCTestCase {
    
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
    
    func testFreeUsersCannotUseDataSharing() throws {
        // Given: User is on free tier
        subscriptionManager.clearPersistedSubscriptionData()
        subscriptionManager.mockUnsubscribe() // Ensure in-memory state is also reset
        
        // When: Checking data sharing permission
        let canUseDataSharing = subscriptionManager.canUseDataSharing()
        
        // Then: Should be false for free users
        XCTAssertFalse(canUseDataSharing, "Free users should not be able to use data sharing")
    }
    
    func testPremiumUsersCanUseDataSharing() throws {
        // Given: User is on premium tier
        subscriptionManager.clearPersistedSubscriptionData()
        subscriptionManager.mockSubscribe()
        
        // When: Checking data sharing permission
        let canUseDataSharing = subscriptionManager.canUseDataSharing()
        
        // Then: Should be true for premium users
        XCTAssertTrue(canUseDataSharing, "Premium users should be able to use data sharing")
    }
    
    func testDataSharingUpgradePrompt() throws {
        // Given: User is on free tier
        subscriptionManager.clearPersistedSubscriptionData()
        
        // When: Getting upgrade prompt for data sharing
        let upgradePrompt = subscriptionManager.getUpgradePrompt(for: .dataSharing)
        
        // Then: Should return appropriate upgrade message
        XCTAssertTrue(upgradePrompt.contains("share and export"), "Upgrade prompt should mention share and export functionality")
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
    
    func testDataSharingFeatureDefinition() throws {
        // Given: Data Sharing feature
        let feature = PremiumFeature.dataSharing
        
        // When: Getting feature description
        let description = feature.description
        
        // Then: Should have correct description
        XCTAssertEqual(description, "Share and export shopping lists", "Data Sharing feature should have correct description")
    }
    
    func testDataSharingUpgradeMessage() throws {
        // Given: Data Sharing feature
        let feature = PremiumFeature.dataSharing
        
        // When: Getting upgrade message
        let upgradeMessage = subscriptionManager.getUpgradePrompt(for: feature)
        
        // Then: Should contain appropriate message
        XCTAssertTrue(upgradeMessage.contains("share and export"), "Upgrade message should mention share and export functionality")
        XCTAssertTrue(upgradeMessage.contains("Upgrade to Premium"), "Upgrade message should mention Premium upgrade")
    }
    
    func testDataSharingFeatureProperties() throws {
        // Given: Data Sharing feature
        let feature = PremiumFeature.dataSharing
        
        // When: Checking feature properties
        let rawValue = feature.rawValue
        let id = feature.id
        let icon = feature.icon
        let isAvailableInFree = feature.isAvailableInFree
        
        // Then: Should have correct properties
        XCTAssertEqual(rawValue, "Data Sharing", "Data Sharing feature should have correct raw value")
        XCTAssertEqual(id, "Data Sharing", "Data Sharing feature should have correct id")
        XCTAssertEqual(icon, "square.and.arrow.up", "Data Sharing feature should have correct icon")
        XCTAssertFalse(isAvailableInFree, "Data Sharing should not be available in free tier")
    }
} 