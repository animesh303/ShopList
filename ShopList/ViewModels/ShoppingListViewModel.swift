import Foundation
import SwiftUI

@MainActor
class ShoppingListViewModel: ObservableObject {
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
    private var isInitialized = false
    
    init() {
        loadShoppingLists()
    }
    
    private func loadShoppingLists() {
        if let data = userDefaults.data(forKey: listsKey),
           let decodedLists = try? JSONDecoder().decode([ShoppingList].self, from: data) {
            self.shoppingLists = decodedLists
        }
        isInitialized = true
    }
    
    static func addItemToShoppingList(itemName: String, listName: String, quantity: Int) async throws {
        let viewModel = ShoppingListViewModel()
        // Wait for initialization
        while !viewModel.isInitialized {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        if let list = viewModel.findList(byName: listName) {
            let item = Item(
                name: itemName,
                quantity: quantity,
                category: .other,
                isCompleted: false,
                notes: nil,
                dateAdded: Date()
            )
            await viewModel.addItem(item, to: list)
        } else {
            throw AddItemIntent.Error.listNotFound
        }
    }
    
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
    
    func addItem(_ item: Item, to list: ShoppingList) async {
        if let index = shoppingLists.firstIndex(where: { $0.id == list.id }) {
            var updatedList = list
            updatedList.addItem(item)
            shoppingLists[index] = updatedList
            saveShoppingLists()
        }
    }
    
    func updateItem(_ item: Item, in list: ShoppingList) {
        if let listIndex = shoppingLists.firstIndex(where: { $0.id == list.id }) {
            var updatedList = shoppingLists[listIndex]
            updatedList.updateItem(item)
            shoppingLists[listIndex] = updatedList
            saveShoppingLists()
        }
    }
    
    func deleteItem(_ item: Item, from list: ShoppingList) {
        if let listIndex = shoppingLists.firstIndex(where: { $0.id == list.id }) {
            var updatedList = shoppingLists[listIndex]
            updatedList.removeItem(item)
            shoppingLists[listIndex] = updatedList
            saveShoppingLists()
        }
    }
    
    func findList(byName name: String) -> ShoppingList? {
        return shoppingLists.first { $0.name == name }
    }
    
    private func saveShoppingLists() {
        if let encoded = try? JSONEncoder().encode(shoppingLists) {
            userDefaults.set(encoded, forKey: listsKey)
        }
    }
}

enum ShoppingListError: Error {
    case listNotFound
} 