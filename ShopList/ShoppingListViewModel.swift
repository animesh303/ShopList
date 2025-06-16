import Foundation
import SwiftUI
import SwiftData
import PhotosUI

@MainActor
final class ShoppingListViewModel: ObservableObject {
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
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext ?? ModelContext(try! ModelContainer(for: ShoppingList.self, Item.self))
        
        // Initialize with empty state
        self.shoppingLists = []
        
        // Load data asynchronously
        Task {
            await loadShoppingLists()
            
            // If no lists exist, create a sample list with some items
            if shoppingLists.isEmpty {
                await addSampleItems()
            }
        }
    }
    
    private func addSampleItems() async {
        print("Adding sample items for testing...")
        let sampleItems = [
            ("Milk", ItemCategory.dairy, 1),
            ("Eggs", ItemCategory.dairy, 2),
            ("Bread", ItemCategory.bakery, 1),
            ("Apples", ItemCategory.produce, 6),
            ("Chicken", ItemCategory.meat, 1)
        ]
        
        let sampleList = ShoppingList(
            name: "Grocery List",
            items: [],
            dateCreated: Date(),
            isShared: false,
            category: .groceries
        )
        
        // Create items and add them to the sample list
        for (name, category, quantity) in sampleItems {
            let item = Item(
                name: name,
                quantity: Decimal(quantity),
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
            sampleList.addItem(item)
            addOrUpdateSuggestion(item)
        }
        
        do {
            try await addShoppingList(sampleList)
            print("Successfully added sample list with \(sampleList.items.count) items")
        } catch {
            print("Failed to add sample list: \(error.localizedDescription)")
        }
    }
    
    private func loadShoppingLists() async {
        print("Loading shopping lists from SwiftData...")
        let descriptor = FetchDescriptor<ShoppingList>()
        
        do {
            let lists = try modelContext.fetch(descriptor)
            print("Successfully loaded \(lists.count) shopping lists")
            self.shoppingLists = lists
            
            // Update suggestions based on existing items
            updateSuggestionsFromLists(lists)
        } catch {
            print("Error loading shopping lists: \(error.localizedDescription)")
            handleError(error)
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
    }
    
    // MARK: - CRUD Operations
    
    func addShoppingList(_ list: ShoppingList) async throws {
        modelContext.insert(list)
        try modelContext.save()
        shoppingLists.append(list)
    }
    
    func updateShoppingList(_ list: ShoppingList) async throws {
        try modelContext.save()
        if let index = shoppingLists.firstIndex(where: { $0.id == list.id }) {
            shoppingLists[index] = list
        }
    }
    
    func deleteShoppingList(_ list: ShoppingList) async throws {
        modelContext.delete(list)
        try modelContext.save()
        shoppingLists.removeAll { $0.id == list.id }
    }
    
    func addItem(_ item: Item, to list: ShoppingList) async throws {
        list.addItem(item)
        try modelContext.save()
        addOrUpdateSuggestion(item)
    }
    
    func updateItem(_ item: Item, in list: ShoppingList) async throws {
        list.updateItem(item)
        try modelContext.save()
    }
    
    func deleteItem(_ item: Item, from list: ShoppingList) async throws {
        list.removeItem(item)
        try modelContext.save()
    }
    
    func toggleItemCompletion(_ item: Item, in list: ShoppingList) async throws {
        list.toggleItemCompletion(item)
        try modelContext.save()
    }
    
    // MARK: - Helper Methods
    
    func findList(byName name: String) async -> ShoppingList? {
        shoppingLists.first { $0.name.lowercased() == name.lowercased() }
    }
    
    private func handleError(_ error: Error) {
        currentError = AppError.unknown(error.localizedDescription)
        showingError = true
    }
    
    // MARK: - Image Handling
    
    func saveImage(from item: PhotosPickerItem) async throws -> URL? {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw AppError.dataSaveError("Failed to load image data")
        }
        
        guard let image = UIImage(data: data) else {
            throw AppError.dataSaveError("Failed to create image from data")
        }
        
        // Create a unique filename
        let filename = UUID().uuidString + ".jpg"
        
        // Get the documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AppError.dataSaveError("Failed to access documents directory")
        }
        
        // Create the file URL
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        // Save the image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AppError.dataSaveError("Failed to convert image to JPEG data")
        }
        
        try imageData.write(to: fileURL)
        return fileURL
    }
    
    func deleteImage(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
} 