import AppIntents
import Foundation
import SwiftData

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
        let viewModel = await ShoppingListViewModel.shared
        
        guard !itemName.isEmpty else {
            throw AppError.invalidInput("Item name cannot be empty")
        }
        
        let listInfo = await viewModel.findListInfo(byName: listName)
        guard let listInfo = listInfo else {
            throw AppError.listNotFound
        }
        
        guard quantity > 0 else {
            throw AppError.invalidQuantity
        }
        
        let item = Item(
            name: itemName,
            quantity: Decimal(quantity),
            category: category,
            isCompleted: false,
            notes: nil,
            dateAdded: Date(),
            pricePerUnit: nil,
            brand: nil,
            unit: nil,
            lastPurchasedPrice: nil,
            lastPurchasedDate: nil,
            imageData: nil,
            priority: .normal
        )
        
        // Add the item directly using the persistent model ID
        try await viewModel.addItemToPersistentID(item, persistentID: listInfo.persistentModelID)
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
        let viewModel = await ShoppingListViewModel.shared
        
        guard !listName.isEmpty else {
            throw AppError.invalidListName
        }
        
        let existingListInfo = await viewModel.findListInfo(byName: listName)
        guard existingListInfo == nil else {
            throw AppError.listAlreadyExists
        }
        
        let newList = ShoppingList(
            name: listName,
            items: [],
            dateCreated: Date(),
            isShared: false,
            category: category
        )
        
        try await viewModel.addShoppingList(newList)
        return .result()
    }
} 