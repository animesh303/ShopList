import Foundation

struct Item: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
    var category: ItemCategory
    var isCompleted: Bool
    var notes: String?
    var dateAdded: Date
    
    init(id: UUID = UUID(), name: String, quantity: Int, category: ItemCategory, isCompleted: Bool = false, notes: String? = nil, dateAdded: Date = Date()) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.isCompleted = isCompleted
        self.notes = notes
        self.dateAdded = dateAdded
    }
} 