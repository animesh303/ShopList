import XCTest
import CoreLocation
@testable import ShopList

@MainActor
final class LocationSearchTests: XCTestCase {
    
    var locationManager: LocationManager!
    var settingsManager: UserSettingsManager!
    
    override func setUpWithError() throws {
        locationManager = LocationManager.shared
        settingsManager = UserSettingsManager.shared
        
        // Reset all relevant settings to known state
        settingsManager.restrictSearchToLocality = false
        settingsManager.useCurrentLocationForSearch = true
        settingsManager.searchRadius = 5000
        settingsManager.savedSearchLocation = nil
        
        print("LocationSearchTests setUp: restrictSearchToLocality=\(settingsManager.restrictSearchToLocality), useCurrentLocationForSearch=\(settingsManager.useCurrentLocationForSearch), searchRadius=\(settingsManager.searchRadius)")
    }
    
    override func tearDownWithError() throws {
        // Reset settings
        settingsManager.restrictSearchToLocality = false
        settingsManager.useCurrentLocationForSearch = true
        settingsManager.searchRadius = 5000
        settingsManager.savedSearchLocation = nil
        
        print("LocationSearchTests tearDown: Settings reset")
    }
    
    func testLocationSearchRestrictionDisabled() throws {
        // Given: Location search restriction is disabled
        settingsManager.restrictSearchToLocality = false
        
        // When: Checking if a location is within search radius
        let testLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let isWithinRadius = locationManager.isLocationWithinSearchRadius(testLocation)
        
        // Then: Should return true (no restrictions)
        XCTAssertTrue(isWithinRadius, "Location should be within radius when restrictions are disabled")
    }
    
    func testLocationSearchRestrictionEnabled() throws {
        // Given: Location search restriction is enabled with a custom location
        settingsManager.restrictSearchToLocality = true
        settingsManager.useCurrentLocationForSearch = false
        settingsManager.savedSearchLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        settingsManager.searchRadius = 1000 // 1km radius
        
        print("testLocationSearchRestrictionEnabled: restrictSearchToLocality=\(settingsManager.restrictSearchToLocality), useCurrentLocationForSearch=\(settingsManager.useCurrentLocationForSearch), savedSearchLocation=\(String(describing: settingsManager.savedSearchLocation)), searchRadius=\(settingsManager.searchRadius)")
        
        // When: Checking locations within and outside the radius
        // Using coordinates that are definitely within 1km (approximately 0.5km away)
        let nearbyLocation = CLLocationCoordinate2D(latitude: 37.7799, longitude: -122.4194) // ~0.55km away
        let farLocation = CLLocationCoordinate2D(latitude: 37.8749, longitude: -122.4194) // ~11km away
        
        let isNearbyWithinRadius = locationManager.isLocationWithinSearchRadius(nearbyLocation)
        let isFarWithinRadius = locationManager.isLocationWithinSearchRadius(farLocation)
        
        print("testLocationSearchRestrictionEnabled: isNearbyWithinRadius=\(isNearbyWithinRadius), isFarWithinRadius=\(isFarWithinRadius)")
        
        // Then: Only nearby location should be within radius
        XCTAssertTrue(isNearbyWithinRadius, "Nearby location should be within 1km radius")
        XCTAssertFalse(isFarWithinRadius, "Far location should not be within 1km radius")
    }
    
    func testSearchRegionGeneration() throws {
        // Given: Location search restriction is enabled with a custom location
        settingsManager.restrictSearchToLocality = true
        settingsManager.useCurrentLocationForSearch = false
        settingsManager.savedSearchLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        settingsManager.searchRadius = 5000 // 5km radius
        
        // When: Getting search region
        let searchRegion = locationManager.getSearchRegion()
        
        // Then: Should return a valid region
        XCTAssertNotNil(searchRegion, "Search region should not be nil when restrictions are enabled")
        if let region = searchRegion {
            XCTAssertEqual(region.center.latitude, 37.7749, accuracy: 0.0001)
            XCTAssertEqual(region.center.longitude, -122.4194, accuracy: 0.0001)
        }
    }
    
    func testSearchRegionDisabled() throws {
        // Given: Location search restriction is disabled
        settingsManager.restrictSearchToLocality = false
        
        // When: Getting search region
        let searchRegion = locationManager.getSearchRegion()
        
        // Then: Should return nil
        XCTAssertNil(searchRegion, "Search region should be nil when restrictions are disabled")
    }
    
    func testDistanceCalculation() throws {
        // Given: Two locations
        let location1 = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let location2 = CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4194)
        
        // When: Calculating distance
        let distance = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
            .distance(from: CLLocation(latitude: location2.latitude, longitude: location2.longitude))
        
        // Then: Distance should be approximately 1.1km
        XCTAssertEqual(distance, 1110, accuracy: 100, "Distance should be approximately 1.1km")
    }
} 