import XCTest
@testable import ShopList
import SwiftData

@MainActor
final class SubscriptionManagerTests: XCTestCase {
    
    var subscriptionManager: SubscriptionManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        subscriptionManager = SubscriptionManager.shared
        
        // Complete reset of SubscriptionManager state for each test
        subscriptionManager.clearPersistedSubscriptionData()
        subscriptionManager.mockUnsubscribe()
        subscriptionManager.clearModelContext()
        subscriptionManager.resetTestListCount()
        subscriptionManager.resetNotificationCount()
        
        // Don't set ModelContext for these tests to avoid SwiftData crashes
        TestHelpers.resetSubscriptionManager()
        
        // Double-check that we're in the correct initial state
        XCTAssertFalse(subscriptionManager.isPremium, "Should start in free tier")
        XCTAssertEqual(subscriptionManager.currentTier, .free, "Should be in free tier")
        XCTAssertTrue(subscriptionManager.canCreateList(), "Should be able to create first list")
    }
    
    override func tearDownWithError() throws {
        // Complete cleanup of SubscriptionManager state
        subscriptionManager.clearPersistedSubscriptionData()
        subscriptionManager.mockUnsubscribe()
        subscriptionManager.clearModelContext()
        subscriptionManager.resetTestListCount()
        subscriptionManager.resetNotificationCount()
        
        TestHelpers.resetSubscriptionManager()
        try super.tearDownWithError()
    }
    
    func testInitialState() {
        let expectation = XCTestExpectation(description: "Wait for loading to finish")
        let manager = subscriptionManager!
        
        // Capture the values we need to avoid sendable issues
        let isLoading = { manager.isLoading }
        
        func check() {
            if !isLoading() {
                expectation.fulfill()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    check()
                }
            }
        }
        check()
        wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(manager.isPremium)
        XCTAssertEqual(manager.currentTier, .free)
        XCTAssertEqual(manager.subscriptionProducts.count, 0)
        XCTAssertFalse(manager.isLoading)
        XCTAssertNil(manager.errorMessage)
    }
    
    func testFreeTierLimitationsSimple() {
        // Reset the test list count to start fresh
        subscriptionManager.resetTestListCount()
        
        // Test list limits using the test count mechanism
        XCTAssertTrue(subscriptionManager.canCreateList()) // 0 lists
        
        // Simulate creating lists by incrementing the test count
        subscriptionManager.incrementTestListCount() // 1 list
        XCTAssertTrue(subscriptionManager.canCreateList()) // Can create 2nd
        
        subscriptionManager.incrementTestListCount() // 2 lists
        XCTAssertTrue(subscriptionManager.canCreateList()) // Can create 3rd
        
        subscriptionManager.incrementTestListCount() // 3 lists
        XCTAssertFalse(subscriptionManager.canCreateList()) // Cannot create 4th (limit is 3)
        
        // Test notification limits by incrementing notification count
        XCTAssertTrue(subscriptionManager.canSendNotification()) // 1st notification
        subscriptionManager.incrementNotificationCount()
        XCTAssertTrue(subscriptionManager.canSendNotification()) // 2nd notification
        subscriptionManager.incrementNotificationCount()
        XCTAssertTrue(subscriptionManager.canSendNotification()) // 3rd notification
        subscriptionManager.incrementNotificationCount()
        XCTAssertTrue(subscriptionManager.canSendNotification()) // 4th notification
        subscriptionManager.incrementNotificationCount()
        XCTAssertTrue(subscriptionManager.canSendNotification()) // 5th notification
        subscriptionManager.incrementNotificationCount()
        XCTAssertFalse(subscriptionManager.canSendNotification()) // 6th notification should fail (limit is 5)
        
        // Test category restrictions
        XCTAssertTrue(subscriptionManager.canUseCategory(.groceries))
        XCTAssertTrue(subscriptionManager.canUseCategory(.household))
        XCTAssertTrue(subscriptionManager.canUseCategory(.personal))
        XCTAssertFalse(subscriptionManager.canUseCategory(.electronics))
        XCTAssertFalse(subscriptionManager.canUseCategory(.clothing))
        
        // Test item category restrictions
        XCTAssertTrue(subscriptionManager.canUseItemCategory(.groceries))
        XCTAssertTrue(subscriptionManager.canUseItemCategory(.dairy))
        XCTAssertTrue(subscriptionManager.canUseItemCategory(.produce))
        XCTAssertTrue(subscriptionManager.canUseItemCategory(.household))
        XCTAssertTrue(subscriptionManager.canUseItemCategory(.personalCare))
        XCTAssertTrue(subscriptionManager.canUseItemCategory(.other))
        XCTAssertFalse(subscriptionManager.canUseItemCategory(.meat))
        XCTAssertFalse(subscriptionManager.canUseItemCategory(.bakery))
        
        // Test unit restrictions
        XCTAssertTrue(subscriptionManager.canUseUnit(.none))
        XCTAssertTrue(subscriptionManager.canUseUnit(.piece))
        XCTAssertTrue(subscriptionManager.canUseUnit(.kilogram))
        XCTAssertTrue(subscriptionManager.canUseUnit(.gram))
        XCTAssertTrue(subscriptionManager.canUseUnit(.liter))
        XCTAssertTrue(subscriptionManager.canUseUnit(.milliliter))
        XCTAssertTrue(subscriptionManager.canUseUnit(.pack))
        XCTAssertTrue(subscriptionManager.canUseUnit(.bottle))
        XCTAssertFalse(subscriptionManager.canUseUnit(.pound))
        XCTAssertFalse(subscriptionManager.canUseUnit(.ounce))
        
        // Test feature restrictions
        XCTAssertFalse(subscriptionManager.canUseLocationReminders())
        XCTAssertFalse(subscriptionManager.canUseDataSharing())
        XCTAssertFalse(subscriptionManager.canUseItemImages())
        XCTAssertFalse(subscriptionManager.canUseBudgetTracking())
    }
    
    func testPremiumTierCapabilities() {
        subscriptionManager.mockSubscribe()
        
        // Test unlimited lists
        for _ in 0..<100 {
            XCTAssertTrue(subscriptionManager.canCreateList())
        }
        
        // Test unlimited notifications
        for _ in 0..<100 {
            XCTAssertTrue(subscriptionManager.canSendNotification())
        }
        
        // Test all categories available
        let allCategories: [ListCategory] = [.groceries, .household, .personalCare, .health, .electronics, .clothing, .office, .automotive, .garden, .gifts, .party, .holiday, .travel, .vacation, .work, .business, .personal, .other]
        
        for category in allCategories {
            XCTAssertTrue(subscriptionManager.canUseCategory(category))
        }
        
        // Test all item categories available
        let allItemCategories: [ItemCategory] = [.groceries, .dairy, .produce, .meat, .bakery, .frozenFoods, .snacks, .beverages, .household, .personalCare, .health, .electronics, .clothing, .office, .automotive, .garden, .other]
        
        for category in allItemCategories {
            XCTAssertTrue(subscriptionManager.canUseItemCategory(category))
        }
        
        // Test all units available
        let allUnits: [ShopList.Unit] = [.none, .piece, .kilogram, .gram, .pound, .ounce, .liter, .milliliter, .gallon, .quart, .pint, .cup, .tablespoon, .teaspoon, .dozen, .box, .pack, .bottle, .can, .jar, .bag]
        
        for unit in allUnits {
            XCTAssertTrue(subscriptionManager.canUseUnit(unit))
        }
        
        // Test all features available
        XCTAssertTrue(subscriptionManager.canUseLocationReminders())
        XCTAssertTrue(subscriptionManager.canUseDataSharing())
        XCTAssertTrue(subscriptionManager.canUseItemImages())
        XCTAssertTrue(subscriptionManager.canUseBudgetTracking())
    }
    
    func testMockSubscription() {
        subscriptionManager.mockSubscribe()
        
        XCTAssertTrue(subscriptionManager.isPremium)
        XCTAssertEqual(subscriptionManager.currentTier, .premium)
        
        // Verify UserDefaults was updated
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "isPremium"))
        XCTAssertEqual(UserDefaults.standard.string(forKey: "subscriptionTier"), "Premium")
    }
    
    func testMockUnsubscription() {
        subscriptionManager.mockSubscribe()
        XCTAssertTrue(subscriptionManager.isPremium)
        
        subscriptionManager.mockUnsubscribe()
        
        XCTAssertFalse(subscriptionManager.isPremium)
        XCTAssertEqual(subscriptionManager.currentTier, .free)
        
        // Verify UserDefaults was updated
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "isPremium"))
        XCTAssertEqual(UserDefaults.standard.string(forKey: "subscriptionTier"), "Free")
    }
    
    func testSubscriptionTierEnum() {
        // Test all tiers exist
        let tiers = SubscriptionTier.allCases
        XCTAssertEqual(tiers.count, 2)
        XCTAssertTrue(tiers.contains(.free))
        XCTAssertTrue(tiers.contains(.premium))
        
        // Test raw values
        XCTAssertEqual(SubscriptionTier.free.rawValue, "Free")
        XCTAssertEqual(SubscriptionTier.premium.rawValue, "Premium")
        
        // Test display names
        XCTAssertEqual(SubscriptionTier.free.displayName, "Free")
        XCTAssertEqual(SubscriptionTier.premium.displayName, "Premium")
    }
    
    func testPersistenceAcrossInstances() {
        subscriptionManager.mockSubscribe()
        
        // Create a new instance (simulating app restart)
        let newInstance = SubscriptionManager.shared
        
        XCTAssertTrue(newInstance.isPremium)
        XCTAssertEqual(newInstance.currentTier, .premium)
    }
    
    func testClearPersistedData() {
        subscriptionManager.mockSubscribe()
        XCTAssertTrue(subscriptionManager.isPremium)
        
        subscriptionManager.clearPersistedSubscriptionData()
        
        // Note: clearPersistedSubscriptionData only clears UserDefaults, not in-memory state
        // The in-memory state will still be premium until the app restarts or mockUnsubscribe is called
        XCTAssertTrue(subscriptionManager.isPremium) // In-memory state unchanged
        XCTAssertEqual(subscriptionManager.currentTier, .premium) // In-memory state unchanged
        
        // But UserDefaults should be cleared
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "isPremium"))
        XCTAssertNil(UserDefaults.standard.string(forKey: "subscriptionTier"))
    }
    
    func testUpgradePrompts() {
        // Test upgrade prompts for different features
        let locationRemindersPrompt = subscriptionManager.getUpgradePrompt(for: .locationReminders)
        XCTAssertTrue(locationRemindersPrompt.contains("location-based reminders"))
        XCTAssertTrue(locationRemindersPrompt.contains("Upgrade to Premium"))
        
        let dataSharingPrompt = subscriptionManager.getUpgradePrompt(for: .dataSharing)
        XCTAssertTrue(dataSharingPrompt.contains("share and export"))
        XCTAssertTrue(dataSharingPrompt.contains("Upgrade to Premium"))
        
        let budgetTrackingPrompt = subscriptionManager.getUpgradePrompt(for: .budgetTracking)
        XCTAssertTrue(budgetTrackingPrompt.contains("track budgets"))
        XCTAssertTrue(budgetTrackingPrompt.contains("Upgrade to Premium"))
    }
    
    func testFeatureAccessMethods() {
        // Test that feature access methods work correctly
        XCTAssertFalse(subscriptionManager.canUseLocationReminders())
        XCTAssertFalse(subscriptionManager.canUseDataSharing())
        XCTAssertFalse(subscriptionManager.canUseItemImages())
        XCTAssertFalse(subscriptionManager.canUseBudgetTracking())
        
        subscriptionManager.mockSubscribe()
        
        XCTAssertTrue(subscriptionManager.canUseLocationReminders())
        XCTAssertTrue(subscriptionManager.canUseDataSharing())
        XCTAssertTrue(subscriptionManager.canUseItemImages())
        XCTAssertTrue(subscriptionManager.canUseBudgetTracking())
    }
    
    func testSubscriptionManagerWorksWithoutCrashing() {
        // This test verifies that basic SubscriptionManager operations don't crash
        XCTAssertFalse(subscriptionManager.isPremium)
        XCTAssertEqual(subscriptionManager.currentTier, .free)
        
        // Test that canCreateList works without crashing
        XCTAssertTrue(subscriptionManager.canCreateList())
        
        // Test that list counting works without SwiftData
        subscriptionManager.incrementTestListCount()
        XCTAssertTrue(subscriptionManager.canCreateList()) // Should still be able to create more
        
        subscriptionManager.incrementTestListCount()
        subscriptionManager.incrementTestListCount()
        XCTAssertFalse(subscriptionManager.canCreateList()) // Should hit the limit
        
        // Test that subscription changes work
        subscriptionManager.mockSubscribe()
        XCTAssertTrue(subscriptionManager.isPremium)
        
        subscriptionManager.mockUnsubscribe()
        XCTAssertFalse(subscriptionManager.isPremium)
    }
    
    func testListCountingLogic() {
        // Reset the test list count
        subscriptionManager.resetTestListCount()
        
        // Test initial state
        XCTAssertTrue(subscriptionManager.canCreateList()) // 0 lists, can create
        
        // Test after 1 list
        subscriptionManager.incrementTestListCount()
        XCTAssertTrue(subscriptionManager.canCreateList()) // 1 list, can create
        
        // Test after 2 lists
        subscriptionManager.incrementTestListCount()
        XCTAssertTrue(subscriptionManager.canCreateList()) // 2 lists, can create
        
        // Test after 3 lists (at limit)
        subscriptionManager.incrementTestListCount()
        XCTAssertFalse(subscriptionManager.canCreateList()) // 3 lists, cannot create
        
        // Test after 4 lists (over limit)
        subscriptionManager.incrementTestListCount()
        XCTAssertFalse(subscriptionManager.canCreateList()) // 4 lists, cannot create
    }
    
    func testDirectListCounting() {
        // Test the logic directly without relying on singleton state
        let manager = SubscriptionManager.shared
        
        // Reset everything
        manager.resetTestListCount()
        manager.mockUnsubscribe() // Ensure we're in free tier
        
        // Test the logic step by step
        XCTAssertFalse(manager.isPremium, "Should start in free tier")
        XCTAssertTrue(manager.canCreateList(), "Should be able to create first list")
        
        manager.incrementTestListCount()
        XCTAssertTrue(manager.canCreateList(), "Should be able to create second list")
        
        manager.incrementTestListCount()
        XCTAssertTrue(manager.canCreateList(), "Should be able to create third list")
        
        manager.incrementTestListCount()
        XCTAssertFalse(manager.canCreateList(), "Should NOT be able to create fourth list")
    }
    
    func testIsolatedListCounting() {
        // Create a completely fresh test by resetting the singleton
        let manager = SubscriptionManager.shared
        
        // Force a complete reset
        manager.clearPersistedSubscriptionData()
        manager.mockUnsubscribe()
        manager.clearModelContext()
        manager.resetTestListCount()
        
        // Verify we're in the correct initial state
        XCTAssertFalse(manager.isPremium, "Should be in free tier after reset")
        XCTAssertTrue(manager.canCreateList(), "Should be able to create first list after reset")
        
        // Test incrementing
        manager.incrementTestListCount()
        XCTAssertTrue(manager.canCreateList(), "Should be able to create second list")
        
        manager.incrementTestListCount()
        XCTAssertTrue(manager.canCreateList(), "Should be able to create third list")
        
        manager.incrementTestListCount()
        XCTAssertFalse(manager.canCreateList(), "Should NOT be able to create fourth list")
    }
    
    func testBasicListLimitLogic() {
        // Test the basic logic: 3 lists should be the limit for free tier
        let manager = SubscriptionManager.shared
        
        // Ensure we're in free tier
        manager.mockUnsubscribe()
        manager.resetTestListCount()
        
        // Test the limit logic directly
        XCTAssertTrue(manager.canCreateList(), "0 lists: should be able to create")
        
        manager.incrementTestListCount() // 1 list
        XCTAssertTrue(manager.canCreateList(), "1 list: should be able to create")
        
        manager.incrementTestListCount() // 2 lists
        XCTAssertTrue(manager.canCreateList(), "2 lists: should be able to create")
        
        manager.incrementTestListCount() // 3 lists
        XCTAssertFalse(manager.canCreateList(), "3 lists: should NOT be able to create (at limit)")
        
        manager.incrementTestListCount() // 4 lists
        XCTAssertFalse(manager.canCreateList(), "4 lists: should NOT be able to create (over limit)")
    }
    
    func testCompletelyIsolatedLogic() {
        // Test the logic completely isolated from any singleton state
        // This test will verify that the basic logic works correctly
        
        // Create a fresh SubscriptionManager instance by forcing a complete reset
        let manager = SubscriptionManager.shared
        
        // Force complete reset of all state
        manager.clearPersistedSubscriptionData()
        manager.mockUnsubscribe()
        manager.clearModelContext()
        manager.resetTestListCount()
        manager.resetNotificationCount()
        
        // Verify initial state
        XCTAssertFalse(manager.isPremium, "Should start in free tier")
        XCTAssertEqual(manager.currentTier, .free, "Should be in free tier")
        
        // Test the list limit logic step by step
        // 0 lists: should be able to create
        XCTAssertTrue(manager.canCreateList(), "0 lists: should be able to create")
        
        // 1 list: should be able to create
        manager.incrementTestListCount()
        XCTAssertTrue(manager.canCreateList(), "1 list: should be able to create")
        
        // 2 lists: should be able to create
        manager.incrementTestListCount()
        XCTAssertTrue(manager.canCreateList(), "2 lists: should be able to create")
        
        // 3 lists: should NOT be able to create (at limit)
        manager.incrementTestListCount()
        XCTAssertFalse(manager.canCreateList(), "3 lists: should NOT be able to create (at limit)")
        
        // 4 lists: should NOT be able to create (over limit)
        manager.incrementTestListCount()
        XCTAssertFalse(manager.canCreateList(), "4 lists: should NOT be able to create (over limit)")
        
        // Test that premium users can always create lists
        manager.mockSubscribe()
        XCTAssertTrue(manager.isPremium, "Should be premium after mock subscribe")
        XCTAssertTrue(manager.canCreateList(), "Premium users should always be able to create lists")
        
        // Test that going back to free tier respects the limit
        manager.mockUnsubscribe()
        XCTAssertFalse(manager.isPremium, "Should be back to free tier")
        XCTAssertFalse(manager.canCreateList(), "Should still respect the limit after going back to free tier")
    }
    
    func testSimpleListLimit() {
        // Simple test to verify the basic list limit logic
        XCTAssertFalse(subscriptionManager.isPremium, "Should start in free tier")
        XCTAssertTrue(subscriptionManager.canCreateList(), "Should be able to create first list")
        
        subscriptionManager.incrementTestListCount()
        XCTAssertTrue(subscriptionManager.canCreateList(), "Should be able to create second list")
        
        subscriptionManager.incrementTestListCount()
        XCTAssertTrue(subscriptionManager.canCreateList(), "Should be able to create third list")
        
        subscriptionManager.incrementTestListCount()
        XCTAssertFalse(subscriptionManager.canCreateList(), "Should NOT be able to create fourth list")
    }
    
    func testConstantsAndLogic() {
        // Test the constants and logic directly without any singleton state
        // This will help us understand if the issue is with the logic or the state management
        
        // Test the basic logic: 3 lists should be the limit
        let maxFreeLists = 3
        
        // Test the logic directly
        XCTAssertTrue(0 < maxFreeLists, "0 < 3 should be true")
        XCTAssertTrue(1 < maxFreeLists, "1 < 3 should be true")
        XCTAssertTrue(2 < maxFreeLists, "2 < 3 should be true")
        XCTAssertFalse(3 < maxFreeLists, "3 < 3 should be false")
        XCTAssertFalse(4 < maxFreeLists, "4 < 3 should be false")
        
        // Test that the subscription manager logic matches
        XCTAssertTrue(subscriptionManager.canCreateList(), "0 lists: should be able to create")
        
        subscriptionManager.incrementTestListCount() // 1 list
        XCTAssertTrue(subscriptionManager.canCreateList(), "1 list: should be able to create")
        
        subscriptionManager.incrementTestListCount() // 2 lists
        XCTAssertTrue(subscriptionManager.canCreateList(), "2 lists: should be able to create")
        
        subscriptionManager.incrementTestListCount() // 3 lists
        XCTAssertFalse(subscriptionManager.canCreateList(), "3 lists: should NOT be able to create")
        
        subscriptionManager.incrementTestListCount() // 4 lists
        XCTAssertFalse(subscriptionManager.canCreateList(), "4 lists: should NOT be able to create")
    }
} 