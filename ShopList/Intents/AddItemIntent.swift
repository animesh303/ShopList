import AppIntents
import Foundation

struct AddItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Item to Shopping List"
    static var description: IntentDescription = IntentDescription("Adds an item to your shopping list")
    
    @Parameter(title: "Item Name", description: "The name of the item to add")
    var itemName: String
    
    @Parameter(title: "List Name", description: "The name of the shopping list")
    var listName: String
    
    @Parameter(title: "Quantity", description: "The quantity of the item", default: 1)
    var quantity: Int
    
    @Parameter(title: "Category", description: "The category of the item", default: .other)
    var category: ItemCategory
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$itemName) to \(\.$listName)")
    }
    
    func perform() async throws -> some IntentResult {
        try await ShoppingListViewModel.addItemToShoppingList(
            itemName: itemName,
            listName: listName,
            quantity: quantity,
            category: category,
            priority: .normal,
            notes: nil
        )
        return .result()
    }
}

struct CreateListIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Shopping List"
    static var description: IntentDescription = IntentDescription("Creates a new shopping list")
    
    @Parameter(title: "List Name", description: "The name of the new shopping list")
    var listName: String
    
    @Parameter(title: "Category", description: "The category of the list", default: .personal)
    var category: ListCategory
    
    static var parameterSummary: some ParameterSummary {
        Summary("Create shopping list \(\.$listName)")
    }
    
    func perform() async throws -> some IntentResult {
        try await ShoppingListViewModel.createShoppingList(
            name: listName,
            category: category
        )
        return .result()
    }
} 