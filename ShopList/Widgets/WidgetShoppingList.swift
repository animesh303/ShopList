import Foundation

struct WidgetShoppingList: Codable, Identifiable {
    let id: UUID
    let name: String
    let pendingItemsCount: Int
    let dateCreated: Date
    let category: ListCategory
    
    init(from shoppingList: ShoppingList) {
        self.id = shoppingList.id
        self.name = shoppingList.name
        self.pendingItemsCount = shoppingList.pendingItems.count
        self.dateCreated = shoppingList.dateCreated
        self.category = shoppingList.category
    }
} 