import XCTest
@testable import ShopList
import CoreLocation

final class LocationReminderTests: XCTestCase {
    
    func testLocationReminderCreation() {
        let location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let reminder = LocationReminder(
            id: UUID(),
            listId: UUID(),
            location: location,
            radius: 100.0,
            message: "Don't forget to buy groceries!"
        )
        
        XCTAssertEqual(reminder.location.latitude, 37.7749, accuracy: 0.0001)
        XCTAssertEqual(reminder.location.longitude, -122.4194, accuracy: 0.0001)
        XCTAssertEqual(reminder.radius, 100.0)
        XCTAssertEqual(reminder.message, "Don't forget to buy groceries!")
    }
    
    func testLocationReminderCreationWithDefaults() {
        let location = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let reminder = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 50.0,
            message: "Shopping reminder"
        )
        
        XCTAssertEqual(reminder.location.latitude, 40.7128, accuracy: 0.0001)
        XCTAssertEqual(reminder.location.longitude, -74.0060, accuracy: 0.0001)
        XCTAssertEqual(reminder.radius, 50.0)
        XCTAssertEqual(reminder.message, "Shopping reminder")
    }
    
    func testLocationReminderUniqueID() {
        let location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let reminder1 = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 100.0,
            message: "Test reminder 1"
        )
        
        let reminder2 = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 100.0,
            message: "Test reminder 2"
        )
        
        XCTAssertNotEqual(reminder1.id, reminder2.id)
    }
    
    func testLocationReminderCodable() {
        let location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let originalReminder = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 100.0,
            message: "Test reminder"
        )
        
        do {
            let encoded = try JSONEncoder().encode(originalReminder)
            let decoded = try JSONDecoder().decode(LocationReminder.self, from: encoded)
            
            XCTAssertEqual(originalReminder.id, decoded.id)
            XCTAssertEqual(originalReminder.listId, decoded.listId)
            XCTAssertEqual(originalReminder.location.latitude, decoded.location.latitude, accuracy: 0.0001)
            XCTAssertEqual(originalReminder.location.longitude, decoded.location.longitude, accuracy: 0.0001)
            XCTAssertEqual(originalReminder.radius, decoded.radius)
            XCTAssertEqual(originalReminder.message, decoded.message)
        } catch {
            XCTFail("Failed to encode/decode LocationReminder: \(error)")
        }
    }
    
    func testLocationReminderRadiusValidation() {
        let location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // Test minimum radius
        let minRadiusReminder = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 10.0,
            message: "Minimum radius"
        )
        XCTAssertEqual(minRadiusReminder.radius, 10.0)
        
        // Test maximum radius
        let maxRadiusReminder = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 10000.0,
            message: "Maximum radius"
        )
        XCTAssertEqual(maxRadiusReminder.radius, 10000.0)
        
        // Test default radius
        let defaultRadiusReminder = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 100.0,
            message: "Default radius"
        )
        XCTAssertEqual(defaultRadiusReminder.radius, 100.0)
    }
    
    func testLocationReminderMessageValidation() {
        let location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // Test empty message
        let emptyMessageReminder = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 100.0,
            message: ""
        )
        XCTAssertEqual(emptyMessageReminder.message, "")
        
        // Test long message
        let longMessage = String(repeating: "A", count: 500)
        let longMessageReminder = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 100.0,
            message: longMessage
        )
        XCTAssertEqual(longMessageReminder.message, longMessage)
        
        // Test special characters
        let specialMessage = "Don't forget! 🛒 Buy groceries at 123 Main St."
        let specialMessageReminder = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 100.0,
            message: specialMessage
        )
        XCTAssertEqual(specialMessageReminder.message, specialMessage)
    }
    
    func testLocationReminderEquality() {
        let location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let listId = UUID()
        
        let reminder1 = LocationReminder(
            id: UUID(),
            listId: listId,
            location: location,
            radius: 100.0,
            message: "Test reminder"
        )
        
        let reminder2 = LocationReminder(
            id: reminder1.id, // Same ID
            listId: listId,
            location: location,
            radius: 100.0,
            message: "Test reminder"
        )
        
        XCTAssertEqual(reminder1.id, reminder2.id)
        XCTAssertEqual(reminder1.listId, reminder2.listId)
        XCTAssertEqual(reminder1.location.latitude, reminder2.location.latitude, accuracy: 0.0001)
        XCTAssertEqual(reminder1.location.longitude, reminder2.location.longitude, accuracy: 0.0001)
        XCTAssertEqual(reminder1.radius, reminder2.radius)
        XCTAssertEqual(reminder1.message, reminder2.message)
    }
    
    func testLocationReminderCoordinateAccuracy() {
        let latitude = 37.7749
        let longitude = -122.4194
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let reminder = LocationReminder(
            listId: UUID(),
            location: location,
            radius: 100.0,
            message: "Test reminder"
        )
        
        // Test coordinate accuracy
        XCTAssertEqual(reminder.location.latitude, latitude, accuracy: 0.0001)
        XCTAssertEqual(reminder.location.longitude, longitude, accuracy: 0.0001)
        
        // Test coordinate validity
        XCTAssertTrue(reminder.location.latitude >= -90 && reminder.location.latitude <= 90)
        XCTAssertTrue(reminder.location.longitude >= -180 && reminder.location.longitude <= 180)
    }
} 