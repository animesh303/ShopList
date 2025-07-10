import Foundation

// Test the move method behavior
var items = ["Milk", "Bread", "Eggs"]
print("Before move: \(items)")

// Simulate moving index 0 to position 2
let itemToMove = items.remove(at: 0)
items.insert(itemToMove, at: 2)

print("After move: \(items)")
print("Expected: [Bread, Eggs, Milk]")
print("Actual: \(items)")

// Test with different positions
items = ["Milk", "Bread", "Eggs"]
print("\nTest 2 - Before move: \(items)")

// Move index 0 to position 1
let itemToMove2 = items.remove(at: 0)
items.insert(itemToMove2, at: 1)

print("After move index 0 to 1: \(items)")
print("Expected: [Bread, Milk, Eggs]")
print("Actual: \(items)") 