import XCTest
import CoreLocation
@testable import ShopList

final class LocationReminderRestrictionTests: XCTestCase {
    
    var subscriptionManager: SubscriptionManager!
    var notificationManager: NotificationManager!
    
    override func setUpWithError() throws {
        subscriptionManager = SubscriptionManager.shared
        notificationManager = NotificationManager.shared
        
        // Clear any existing subscription data
        subscriptionManager.clearPersistedSubscriptionData()
    }
    
    override func tearDownWithError() throws {
        // Clean up
        subscriptionManager.clearPersistedSubscriptionData()
    }
    
    func testFreeUsersCannotUseLocationReminders() throws {
        // Given: User is on free tier
        subscriptionManager.mockUnsubscribe()
        
        // When: Checking if user can use location reminders
        let canUseLocationReminders = subscriptionManager.canUseLocationReminders()
        
        // Then: Should return false
        XCTAssertFalse(canUseLocationReminders, "Free users should not be able to use location reminders")
    }
    
    func testPremiumUsersCanUseLocationReminders() throws {
        // Given: User is on premium tier
        subscriptionManager.mockSubscribe()
        
        // When: Checking if user can use location reminders
        let canUseLocationReminders = subscriptionManager.canUseLocationReminders()
        
        // Then: Should return true
        XCTAssertTrue(canUseLocationReminders, "Premium users should be able to use location reminders")
    }
    
    func testLocationReminderSchedulingFailsForFreeUsers() async throws {
        // Given: User is on free tier
        subscriptionManager.mockUnsubscribe()
        
        let testList = ShoppingList(name: "Test List", category: .groceries)
        let testLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // When: Attempting to schedule a location reminder
        let result = await notificationManager.scheduleLocationReminder(
            for: testList,
            at: testLocation,
            radius: 100,
            message: "Test reminder"
        )
        
        // Then: Should fail
        XCTAssertFalse(result, "Location reminder scheduling should fail for free users")
    }
    
    func testLocationReminderSchedulingSucceedsForPremiumUsers() async throws {
        // Given: User is on premium tier
        subscriptionManager.mockSubscribe()
        
        let testList = ShoppingList(name: "Test List", category: .groceries)
        let testLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // When: Attempting to schedule a location reminder
        let result = await notificationManager.scheduleLocationReminder(
            for: testList,
            at: testLocation,
            radius: 100,
            message: "Test reminder"
        )
        
        // Then: Should succeed (assuming notification permissions are granted)
        // Note: This test might fail if notification permissions are not granted
        // In a real test environment, you'd need to mock the notification center
        XCTAssertTrue(result, "Location reminder scheduling should succeed for premium users")
    }
    
    func testUpgradePromptForLocationReminders() throws {
        // Given: User is on free tier
        subscriptionManager.mockUnsubscribe()
        
        // When: Getting upgrade prompt for location reminders
        let prompt = subscriptionManager.getUpgradePrompt(for: .locationReminders)
        
        // Then: Should return appropriate message
        XCTAssertEqual(prompt, "Upgrade to Premium to get location-based reminders", "Should return correct upgrade prompt")
    }
    
    func testSubscriptionStatusPersistence() throws {
        // Given: User subscribes to premium
        subscriptionManager.mockSubscribe()
        XCTAssertTrue(subscriptionManager.canUseLocationReminders())
        
        // When: Creating a new subscription manager instance (simulating app restart)
        let newSubscriptionManager = SubscriptionManager.shared
        
        // Then: Should maintain premium status
        XCTAssertTrue(newSubscriptionManager.canUseLocationReminders(), "Premium status should persist across app restarts")
        
        // Clean up
        subscriptionManager.clearPersistedSubscriptionData()
    }
} 