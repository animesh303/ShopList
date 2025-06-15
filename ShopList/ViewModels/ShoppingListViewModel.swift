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
    @Published var itemSuggestions: [String: (item: Item, count: Int)] = [:] // item name: (full item, usage count)
    
    private let userDefaults = UserDefaults.standard
    private let listsKey = "shoppingLists"
    private let suggestionsKey = "itemSuggestions"
    
    init() {
        do {
            try loadShoppingLists()
            
            // If no lists exist, create a sample list with some items
            if shoppingLists.isEmpty {
                addSampleItems()
            }
        } catch {
            handleError(error)
        }
    }
    
    private func addSampleItems() {
        print("Adding sample items for testing...")
        let sampleItems = [
            ("Milk", ItemCategory.dairy, 1),
            ("Eggs", ItemCategory.dairy, 2),
            ("Bread", ItemCategory.bakery, 1),
            ("Apples", ItemCategory.produce, 6),
            ("Chicken", ItemCategory.meat, 1)
        ]
        
        var sampleList = ShoppingList(
            name: "Grocery List",
            items: [],
            dateCreated: Date(),
            isShared: false,
            category: .groceries
        )
        
        // Create items and add them to the sample list
        var items = [Item]()
        for (name, category, quantity) in sampleItems {
            let item = Item(
                name: name,
                quantity: quantity,
                category: category,
                isCompleted: false,
                notes: nil,
                dateAdded: Date(),
                estimatedPrice: nil,
                barcode: nil,
                brand: nil,
                unit: nil,
                lastPurchasedPrice: nil,
                lastPurchasedDate: nil,
                imageURL: nil,
                priority: .normal
            )
            items.append(item)
            addOrUpdateSuggestion(item)
        }
        
        // Update the sample list with the items
        sampleList.items = items
        
        do {
            try addShoppingList(sampleList)
            print("Successfully added sample list with \(sampleList.items.count) items")
        } catch {
            print("Failed to add sample list: \(error.localizedDescription)")
        }
    }
    
    private func loadShoppingLists() throws {
        print("Loading shopping lists from UserDefaults...")
        // Load shopping lists
        if let data = userDefaults.data(forKey: listsKey) {
            do {
                let decodedLists = try JSONDecoder().decode([ShoppingList].self, from: data)
                print("Successfully loaded \(decodedLists.count) shopping lists")
                self.shoppingLists = decodedLists
                
                // Update suggestions based on existing items
                updateSuggestionsFromLists(decodedLists)
            } catch {
                print("Error decoding shopping lists: \(error.localizedDescription)")
                throw AppError.dataDecodingError("Failed to load shopping lists: \(error.localizedDescription)")
            }
        } else {
            print("No shopping lists found in UserDefaults")
        }
        
        // Load saved suggestions
        if let data = userDefaults.data(forKey: suggestionsKey) {
            if let savedSuggestions = try? JSONDecoder().decode([String: [String: Data]].self, from: data) {
                var newSuggestions: [String: (Item, Int)] = [:] 
                for (itemName, value) in savedSuggestions {
                    if let itemData = value["item"],
                       let countData = value["count"],
                       let count = Int(String(data: countData, encoding: .utf8) ?? "1") {
                        do {
                            let item = try JSONDecoder().decode(Item.self, from: itemData)
                            newSuggestions[itemName] = (item, count)
                        } catch {
                            print("Failed to decode item \(itemName): \(error)")
                        }
                    }
                }
                self.itemSuggestions = newSuggestions
            }
        }
    }
    
    private func saveSuggestions() {
        var dictToSave: [String: [String: Data]] = [:]  // Store encoded item data
        
        for (itemName, data) in itemSuggestions {
            do {
                // Encode the item
                let itemData = try JSONEncoder().encode(data.item)
                // Store both the item data and count
                dictToSave[itemName] = [
                    "item": itemData,
                    "count": String(data.count).data(using: .utf8)!
                ]
            } catch {
                print("Failed to encode item \(itemName): \(error)")
            }
        }
        
        if let data = try? JSONEncoder().encode(dictToSave) {
            userDefaults.set(data, forKey: suggestionsKey)
        }
    }
    
    private func updateSuggestionsFromLists(_ lists: [ShoppingList]) {
        print("Updating suggestions from \(lists.count) lists")
        var itemCounts: [String: (Item, Int)] = [:]
        
        for list in lists {
            for item in list.items {
                let name = item.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if name.isEmpty { continue }
                
                if let existing = itemCounts[name] {
                    itemCounts[name] = (existing.0, existing.1 + 1)
                } else {
                    itemCounts[name] = (item, 1)
                }
            }
        }
        
        // Merge with existing suggestions, preserving higher counts
        var updatedCount = 0
        for (item, data) in itemCounts {
            if let existing = itemSuggestions[item] {
                // Keep the existing item but update the count
                itemSuggestions[item] = (existing.item, max(existing.count, data.1))
                updatedCount += 1
            } else {
                itemSuggestions[item] = data
                updatedCount += 1
            }
        }
        print("Updated \(updatedCount) suggestions. Total suggestions now: \(itemSuggestions.count)")
        
        saveSuggestions()
    }
    
    func getSuggestions(for query: String) -> [Item] {
        guard !query.isEmpty else {
            print("Query is empty, returning no suggestions")
            return []
        }
        
        let query = query.lowercased()
        print("Getting suggestions for query: \(query)")
        print("Current itemSuggestions: \(itemSuggestions.keys)")
        
        // Get matching items, sorted by usage count
        let suggestions = itemSuggestions
            .filter { $0.key.lowercased().contains(query) }
            .sorted { $0.value.count > $1.value.count }
            .prefix(5)
            .map { $0.value.item }
        
        print("Found \(suggestions.count) suggestions")
        return suggestions
    }
    
    func addOrUpdateSuggestion(_ item: Item) {
        let name = item.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !name.isEmpty else { return }
        
        if let existing = itemSuggestions[name] {
            // Update the count but keep the existing item data
            itemSuggestions[name] = (existing.item, existing.count + 1)
        } else {
            // Create a new suggestion with the item and initial count of 1
            itemSuggestions[name] = (item, 1)
        }
        saveSuggestions()
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