import Foundation

struct ShoppingList: Identifiable, Codable {
    let id: UUID
    var name: String
    var items: [Item]
    var dateCreated: Date
    var isShared: Bool
    var sharedWith: [String]?
    
    init(id: UUID = UUID(), name: String, items: [Item] = [], dateCreated: Date = Date(), isShared: Bool = false) {
        self.id = id
        self.name = name
        self.items = items
        self.dateCreated = dateCreated
        self.isShared = isShared
    }
    
    var completedItems: [Item] {
        items.filter { $0.isCompleted }
    }
    
    var pendingItems: [Item] {
        items.filter { !$0.isCompleted }
    }
    
    var itemsByCategory: [ItemCategory: [Item]] {
        Dictionary(grouping: items) { $0.category }
    }
    
    mutating func addItem(_ item: Item) {
        items.append(item)
    }
    
    mutating func removeItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }
    
    mutating func toggleItemCompletion(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }
    
    mutating func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
} 