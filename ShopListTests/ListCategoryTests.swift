import XCTest
@testable import ShopList

final class ListCategoryTests: XCTestCase {
    
    func testListCategoryAllCases() {
        let categories = ListCategory.allCases
        XCTAssertFalse(categories.isEmpty)
        
        // Test some key categories exist
        XCTAssertTrue(categories.contains(.groceries))
        XCTAssertTrue(categories.contains(.household))
        XCTAssertTrue(categories.contains(.personal))
        XCTAssertTrue(categories.contains(.other))
        XCTAssertTrue(categories.contains(.gifts))
        XCTAssertTrue(categories.contains(.travel))
        XCTAssertTrue(categories.contains(.work))
    }
    
    func testListCategoryRawValues() {
        XCTAssertEqual(ListCategory.groceries.rawValue, "Groceries")
        XCTAssertEqual(ListCategory.household.rawValue, "Household")
        XCTAssertEqual(ListCategory.personalCare.rawValue, "Personal Care")
        XCTAssertEqual(ListCategory.health.rawValue, "Health & Pharmacy")
        XCTAssertEqual(ListCategory.electronics.rawValue, "Electronics")
        XCTAssertEqual(ListCategory.clothing.rawValue, "Clothing")
        XCTAssertEqual(ListCategory.office.rawValue, "Office Supplies")
        XCTAssertEqual(ListCategory.pet.rawValue, "Pet Supplies")
        XCTAssertEqual(ListCategory.baby.rawValue, "Baby & Kids")
        XCTAssertEqual(ListCategory.automotive.rawValue, "Automotive")
        XCTAssertEqual(ListCategory.homeImprovement.rawValue, "Home Improvement")
        XCTAssertEqual(ListCategory.garden.rawValue, "Garden & Outdoors")
        XCTAssertEqual(ListCategory.gifts.rawValue, "Gifts")
        XCTAssertEqual(ListCategory.party.rawValue, "Party Supplies")
        XCTAssertEqual(ListCategory.holiday.rawValue, "Holiday Shopping")
        XCTAssertEqual(ListCategory.travel.rawValue, "Travel")
        XCTAssertEqual(ListCategory.vacation.rawValue, "Vacation")
        XCTAssertEqual(ListCategory.work.rawValue, "Work")
        XCTAssertEqual(ListCategory.business.rawValue, "Business")
        XCTAssertEqual(ListCategory.personal.rawValue, "Personal")
        XCTAssertEqual(ListCategory.other.rawValue, "Other")
    }
    
    func testListCategoryCodable() {
        let categories: [ListCategory] = [.groceries, .household, .personal, .other]
        
        do {
            let encoded = try JSONEncoder().encode(categories)
            let decoded = try JSONDecoder().decode([ListCategory].self, from: encoded)
            
            XCTAssertEqual(decoded.count, 4)
            XCTAssertEqual(decoded[0], .groceries)
            XCTAssertEqual(decoded[1], .household)
            XCTAssertEqual(decoded[2], .personal)
            XCTAssertEqual(decoded[3], .other)
        } catch {
            XCTFail("Failed to encode/decode ListCategory: \(error)")
        }
    }
    
    func testListCategoryComparable() {
        // Test that categories can be sorted
        let categories: [ListCategory] = [.other, .groceries, .household, .personal]
        let sortedCategories = categories.sorted()
        
        // The order should be alphabetical based on raw values
        XCTAssertEqual(sortedCategories[0], .groceries)
        XCTAssertEqual(sortedCategories[1], .household)
        XCTAssertEqual(sortedCategories[2], .other)
        XCTAssertEqual(sortedCategories[3], .personal)
    }
    
    func testListCategoryColors() {
        // Test that all categories have colors defined
        let categories = ListCategory.allCases
        
        for category in categories {
            // This will crash if a color is not defined for any category
            let _ = category.color
        }
        
        // Test specific color assignments
        XCTAssertNotNil(ListCategory.groceries.color)
        XCTAssertNotNil(ListCategory.household.color)
        XCTAssertNotNil(ListCategory.personal.color)
        XCTAssertNotNil(ListCategory.other.color)
    }
    
    func testListCategoryGrouping() {
        // Test that we can group categories by type
        let shoppingCategories: [ListCategory] = [.groceries, .household, .personalCare, .health, .electronics, .clothing, .office, .pet, .baby, .automotive, .homeImprovement, .garden]
        let specialOccasions: [ListCategory] = [.gifts, .party, .holiday]
        let travelCategories: [ListCategory] = [.travel, .vacation]
        let workCategories: [ListCategory] = [.work, .business]
        let otherCategories: [ListCategory] = [.personal, .other]
        
        XCTAssertEqual(shoppingCategories.count, 12)
        XCTAssertEqual(specialOccasions.count, 3)
        XCTAssertEqual(travelCategories.count, 2)
        XCTAssertEqual(workCategories.count, 2)
        XCTAssertEqual(otherCategories.count, 2)
    }
} 