import XCTest
@testable import ShopList

final class ItemPriorityTests: XCTestCase {
    
    func testItemPriorityAllCases() {
        let priorities = ItemPriority.allCases
        XCTAssertEqual(priorities.count, 3)
        XCTAssertTrue(priorities.contains(.low))
        XCTAssertTrue(priorities.contains(.normal))
        XCTAssertTrue(priorities.contains(.high))
    }
    
    func testItemPriorityDisplayNames() {
        XCTAssertEqual(ItemPriority.low.displayName, "Low")
        XCTAssertEqual(ItemPriority.normal.displayName, "Normal")
        XCTAssertEqual(ItemPriority.high.displayName, "High")
    }
    
    func testItemPriorityIcons() {
        XCTAssertEqual(ItemPriority.low.icon, "arrow.down.circle.fill")
        XCTAssertEqual(ItemPriority.normal.icon, "circle.fill")
        XCTAssertEqual(ItemPriority.high.icon, "exclamationmark.circle.fill")
    }
    
    func testItemPriorityColors() {
        XCTAssertEqual(ItemPriority.low.color, .gray)
        XCTAssertEqual(ItemPriority.normal.color, .blue)
        XCTAssertEqual(ItemPriority.high.color, .red)
    }
    
    func testItemPriorityRawValues() {
        XCTAssertEqual(ItemPriority.low.rawValue, 0)
        XCTAssertEqual(ItemPriority.normal.rawValue, 1)
        XCTAssertEqual(ItemPriority.high.rawValue, 2)
    }
    
    func testItemPriorityCodable() {
        let priorities: [ItemPriority] = [.low, .normal, .high]
        
        do {
            let encoded = try JSONEncoder().encode(priorities)
            let decoded = try JSONDecoder().decode([ItemPriority].self, from: encoded)
            
            XCTAssertEqual(decoded.count, 3)
            XCTAssertEqual(decoded[0], .low)
            XCTAssertEqual(decoded[1], .normal)
            XCTAssertEqual(decoded[2], .high)
        } catch {
            XCTFail("Failed to encode/decode ItemPriority: \(error)")
        }
    }
} 