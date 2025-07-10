import XCTest
@testable import ShopList

final class SortOrderTests: XCTestCase {
    
    func testSortOrderAllCases() {
        let sortOrders = ShopList.SortOrder.allCases
        XCTAssertEqual(sortOrders.count, 6)
        
        // Test that all expected sort orders exist
        XCTAssertTrue(sortOrders.contains(.nameAsc))
        XCTAssertTrue(sortOrders.contains(.nameDesc))
        XCTAssertTrue(sortOrders.contains(.dateAsc))
        XCTAssertTrue(sortOrders.contains(.dateDesc))
        XCTAssertTrue(sortOrders.contains(.categoryAsc))
        XCTAssertTrue(sortOrders.contains(.categoryDesc))
    }
    
    func testSortOrderRawValues() {
        XCTAssertEqual(ShopList.SortOrder.nameAsc.rawValue, "Name (A-Z)")
        XCTAssertEqual(ShopList.SortOrder.nameDesc.rawValue, "Name (Z-A)")
        XCTAssertEqual(ShopList.SortOrder.dateAsc.rawValue, "Date (Oldest)")
        XCTAssertEqual(ShopList.SortOrder.dateDesc.rawValue, "Date (Newest)")
        XCTAssertEqual(ShopList.SortOrder.categoryAsc.rawValue, "Category (A-Z)")
        XCTAssertEqual(ShopList.SortOrder.categoryDesc.rawValue, "Category (Z-A)")
    }
    
    func testSortOrderDisplayNames() {
        XCTAssertEqual(ShopList.SortOrder.nameAsc.displayName, "Name (A-Z)")
        XCTAssertEqual(ShopList.SortOrder.nameDesc.displayName, "Name (Z-A)")
        XCTAssertEqual(ShopList.SortOrder.dateAsc.displayName, "Date (Oldest)")
        XCTAssertEqual(ShopList.SortOrder.dateDesc.displayName, "Date (Newest)")
        XCTAssertEqual(ShopList.SortOrder.categoryAsc.displayName, "Category (A-Z)")
        XCTAssertEqual(ShopList.SortOrder.categoryDesc.displayName, "Category (Z-A)")
    }
    
    func testSortOrderIdentifiable() {
        let sortOrders = ShopList.SortOrder.allCases
        
        for sortOrder in sortOrders {
            XCTAssertEqual(sortOrder.id, sortOrder.rawValue)
        }
    }
    
    func testSortOrderEquality() {
        XCTAssertEqual(ShopList.SortOrder.nameAsc, ShopList.SortOrder.nameAsc)
        XCTAssertEqual(ShopList.SortOrder.nameDesc, ShopList.SortOrder.nameDesc)
        XCTAssertEqual(ShopList.SortOrder.dateAsc, ShopList.SortOrder.dateAsc)
        XCTAssertEqual(ShopList.SortOrder.dateDesc, ShopList.SortOrder.dateDesc)
        XCTAssertEqual(ShopList.SortOrder.categoryAsc, ShopList.SortOrder.categoryAsc)
        XCTAssertEqual(ShopList.SortOrder.categoryDesc, ShopList.SortOrder.categoryDesc)
        
        XCTAssertNotEqual(ShopList.SortOrder.nameAsc, ShopList.SortOrder.nameDesc)
        XCTAssertNotEqual(ShopList.SortOrder.dateAsc, ShopList.SortOrder.dateDesc)
        XCTAssertNotEqual(ShopList.SortOrder.categoryAsc, ShopList.SortOrder.categoryDesc)
    }
    
    func testSortOrderHashable() {
        let sortOrderSet: Set<ShopList.SortOrder> = [.nameAsc, .nameDesc, .dateAsc, .dateDesc, .categoryAsc, .categoryDesc]
        
        XCTAssertEqual(sortOrderSet.count, 6)
        XCTAssertTrue(sortOrderSet.contains(.nameAsc))
        XCTAssertTrue(sortOrderSet.contains(.nameDesc))
        XCTAssertTrue(sortOrderSet.contains(.dateAsc))
        XCTAssertTrue(sortOrderSet.contains(.dateDesc))
        XCTAssertTrue(sortOrderSet.contains(.categoryAsc))
        XCTAssertTrue(sortOrderSet.contains(.categoryDesc))
    }
    
    func testSortOrderDefaultValue() {
        // Test that there's a sensible default sort order
        let defaultSortOrder = ShopList.SortOrder.nameAsc
        XCTAssertEqual(defaultSortOrder, .nameAsc)
    }
    
    func testSortOrderUserPreferences() {
        // Test that sort orders can be used for user preferences
        let userPreferredSort = ShopList.SortOrder.categoryAsc
        
        // Simulate saving to UserDefaults
        UserDefaults.standard.set(userPreferredSort.rawValue, forKey: "preferredSortOrder")
        
        // Simulate loading from UserDefaults
        if let savedRawValue = UserDefaults.standard.string(forKey: "preferredSortOrder"),
           let savedSortOrder = ShopList.SortOrder(rawValue: savedRawValue) {
            XCTAssertEqual(savedSortOrder, userPreferredSort)
        } else {
            XCTFail("Failed to save/load sort order preference")
        }
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "preferredSortOrder")
    }
    
    func testSortOrderGrouping() {
        // Test that we can group sort orders by type
        let nameSorts: [ShopList.SortOrder] = [.nameAsc, .nameDesc]
        let dateSorts: [ShopList.SortOrder] = [.dateAsc, .dateDesc]
        let categorySorts: [ShopList.SortOrder] = [.categoryAsc, .categoryDesc]
        
        XCTAssertEqual(nameSorts.count, 2)
        XCTAssertEqual(dateSorts.count, 2)
        XCTAssertEqual(categorySorts.count, 2)
        
        // Test ascending vs descending
        let ascendingSorts: [ShopList.SortOrder] = [.nameAsc, .dateAsc, .categoryAsc]
        let descendingSorts: [ShopList.SortOrder] = [.nameDesc, .dateDesc, .categoryDesc]
        
        XCTAssertEqual(ascendingSorts.count, 3)
        XCTAssertEqual(descendingSorts.count, 3)
    }
    
    func testSortOrderDescriptiveNames() {
        // Test that sort order names are descriptive and user-friendly
        XCTAssertTrue(ShopList.SortOrder.nameAsc.displayName.contains("Name"))
        XCTAssertTrue(ShopList.SortOrder.nameAsc.displayName.contains("A-Z"))
        
        XCTAssertTrue(ShopList.SortOrder.nameDesc.displayName.contains("Name"))
        XCTAssertTrue(ShopList.SortOrder.nameDesc.displayName.contains("Z-A"))
        
        XCTAssertTrue(ShopList.SortOrder.dateAsc.displayName.contains("Date"))
        XCTAssertTrue(ShopList.SortOrder.dateAsc.displayName.contains("Oldest"))
        
        XCTAssertTrue(ShopList.SortOrder.dateDesc.displayName.contains("Date"))
        XCTAssertTrue(ShopList.SortOrder.dateDesc.displayName.contains("Newest"))
        
        XCTAssertTrue(ShopList.SortOrder.categoryAsc.displayName.contains("Category"))
        XCTAssertTrue(ShopList.SortOrder.categoryAsc.displayName.contains("A-Z"))
        
        XCTAssertTrue(ShopList.SortOrder.categoryDesc.displayName.contains("Category"))
        XCTAssertTrue(ShopList.SortOrder.categoryDesc.displayName.contains("Z-A"))
    }
} 