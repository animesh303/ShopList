import AppIntents
import Foundation

struct AddItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Item to Shopping List"
    static var description: IntentDescription = IntentDescription("Adds an item to your shopping list")
    
    @Parameter(title: "Item Name")
    var itemName: String
    
    @Parameter(title: "List Name")
    var listName: String
    
    @Parameter(title: "Quantity", default: 1)
    var quantity: Int
    
    func perform() async throws -> some IntentResult {
        try await ShoppingListViewModel.addItemToShoppingList(
            itemName: itemName,
            listName: listName,
            quantity: quantity
        )
        return .result()
    }
    
    enum Error: Swift.Error {
        case listNotFound
    }
} 