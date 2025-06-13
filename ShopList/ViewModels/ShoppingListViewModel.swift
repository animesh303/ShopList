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
    @Published var errorMessage: String?
    @Published var showingError = false
    
    private let userDefaults = UserDefaults.standard
    private let listsKey = "shoppingLists"
    
    init() {
        loadShoppingLists()
    }
    
    private func loadShoppingLists() {
        if let data = userDefaults.data(forKey: listsKey),
           let decodedLists = try? JSONDecoder().decode([ShoppingList].self, from: data) {
            self.shoppingLists = decodedLists
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
        
        guard let list = viewModel.findList(byName: listName) else {
            throw IntentError.listNotFound
        }
        
        guard quantity > 0 else {
            throw IntentError.invalidQuantity
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
        
        viewModel.addItem(item, to: list)
    }
    
    static func createShoppingList(name: String, category: ListCategory) async throws {
        let viewModel = shared
        
        guard !name.isEmpty else {
            throw IntentError.invalidListName
        }
        
        guard viewModel.findList(byName: name) == nil else {
            throw IntentError.listAlreadyExists
        }
        
        let newList = ShoppingList(
            name: name,
            items: [],
            dateCreated: Date(),
            isShared: false,
            category: category
        )
        
        viewModel.addShoppingList(newList)
    }
    
    // MARK: - List Management
    
    func addShoppingList(_ list: ShoppingList) {
        shoppingLists.append(list)
        saveShoppingLists()
    }
    
    func deleteList(at indexSet: IndexSet) {
        shoppingLists.remove(atOffsets: indexSet)
        saveShoppingLists()
    }
    
    func updateList(_ list: ShoppingList) {
        if let index = shoppingLists.firstIndex(where: { $0.id == list.id }) {
            shoppingLists[index] = list
            saveShoppingLists()
        }
    }
    
    func addItem(_ item: Item, to list: ShoppingList) {
        var updatedList = list
        updatedList.addItem(item)
        updateList(updatedList)
    }
    
    func findList(byName name: String) -> ShoppingList? {
        shoppingLists.first { $0.name.lowercased() == name.lowercased() }
    }
    
    private func saveShoppingLists() {
        if let encoded = try? JSONEncoder().encode(shoppingLists) {
            userDefaults.set(encoded, forKey: listsKey)
        }
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