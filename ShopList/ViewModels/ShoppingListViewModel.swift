import Foundation
import SwiftUI

@MainActor
class ShoppingListViewModel: ObservableObject {
    static let shared = ShoppingListViewModel()
    
    @Published var shoppingLists: [ShoppingList] = []
    @Published var selectedList: ShoppingList?
    @Published var newListName: String = ""
    @Published var newItemName: String = ""
    @Published var newItemQuantity: Int = 1
    @Published var newItemCategory: ItemCategory = .other
    @Published var newItemNotes: String = ""
    @Published var showingAddListSheet = false
    @Published var showingAddItemSheet = false
    @Published var showingShareSheet = false
    @Published var listToShare: ShoppingList?
    
    // Error handling properties
    @Published var currentError: AppError?
    @Published var showingError = false
    
    private let userDefaults = UserDefaults.standard
    private let listsKey = "shoppingLists"
    
    init() {
        do {
            try loadShoppingLists()
        } catch {
            handleError(error)
        }
    }
    
    private func loadShoppingLists() throws {
        guard let data = userDefaults.data(forKey: listsKey) else {
            return // No data yet, not an error
        }
        
        do {
            let decodedLists = try JSONDecoder().decode([ShoppingList].self, from: data)
            self.shoppingLists = decodedLists
        } catch {
            throw AppError.dataDecodingError("Failed to load shopping lists: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Siri Intent Methods
    
    static func addItemToShoppingList(
        itemName: String,
        listName: String,
        quantity: Int,
        category: ItemCategory,
        priority: ItemPriority,
        notes: String?
    ) async throws {
        let viewModel = shared
        
        guard !itemName.isEmpty else {
            throw AppError.invalidInput("Item name cannot be empty")
        }
        
        guard let list = viewModel.findList(byName: listName) else {
            throw AppError.listNotFound
        }
        
        guard quantity > 0 else {
            throw AppError.invalidQuantity
        }
        
        let item = Item(
            name: itemName,
            quantity: quantity,
            category: category,
            isCompleted: false,
            notes: notes,
            dateAdded: Date(),
            priority: priority
        )
        
        try viewModel.addItem(item, to: list)
    }
    
    static func createShoppingList(name: String, category: ListCategory) async throws {
        let viewModel = shared
        
        guard !name.isEmpty else {
            throw AppError.invalidListName
        }
        
        guard viewModel.findList(byName: name) == nil else {
            throw AppError.listAlreadyExists
        }
        
        let newList = ShoppingList(
            name: name,
            items: [],
            dateCreated: Date(),
            isShared: false,
            category: category
        )
        
        try viewModel.addShoppingList(newList)
    }
    
    // MARK: - List Management
    
    func addShoppingList(_ list: ShoppingList) throws {
        shoppingLists.append(list)
        try saveShoppingLists()
    }
    
    func deleteList(at indexSet: IndexSet) {
        do {
            shoppingLists.remove(atOffsets: indexSet)
            try saveShoppingLists()
        } catch {
            handleError(error)
        }
    }
    
    func updateList(_ list: ShoppingList) throws {
        guard let index = shoppingLists.firstIndex(where: { $0.id == list.id }) else {
            throw AppError.dataNotFound("List not found for update")
        }
        
        shoppingLists[index] = list
        try saveShoppingLists()
    }
    
    func addItem(_ item: Item, to list: ShoppingList) throws {
        var updatedList = list
        updatedList.addItem(item)
        try updateList(updatedList)
    }
    
    func findList(byName name: String) -> ShoppingList? {
        shoppingLists.first { $0.name.lowercased() == name.lowercased() }
    }
    
    private func saveShoppingLists() throws {
        do {
            let encoded = try JSONEncoder().encode(shoppingLists)
            userDefaults.set(encoded, forKey: listsKey)
        } catch {
            throw AppError.dataSaveError("Failed to save shopping lists: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error Handling
    
    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            currentError = appError
        } else {
            currentError = AppError.uiError(error.localizedDescription)
        }
        showingError = true
    }
}

// MARK: - Intent Errors
enum IntentError: LocalizedError {
    case listNotFound
    case invalidQuantity
    case invalidListName
    case listAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .listNotFound:
            return "Shopping list not found"
        case .invalidQuantity:
            return "Invalid quantity specified"
        case .invalidListName:
            return "Invalid list name"
        case .listAlreadyExists:
            return "A list with this name already exists"
        }
    }
} 