import Foundation
import SwiftUI
import SwiftData
import PhotosUI

@MainActor
final class ShoppingListViewModel: ObservableObject {
    private static var sharedInstance: ShoppingListViewModel?
    
    static var shared: ShoppingListViewModel {
        if let instance = sharedInstance {
            return instance
        }
        let instance = ShoppingListViewModel()
        sharedInstance = instance
        return instance
    }
    
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
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        if let modelContext = modelContext {
            self.modelContext = modelContext
        } else {
            do {
                let config = ModelConfiguration(isStoredInMemoryOnly: false)
                let container = try ModelContainer(for: ShoppingList.self, Item.self, ItemHistory.self, configurations: config)
                self.modelContext = container.mainContext
            } catch {
                fatalError("Failed to initialize ModelContainer: \(error)")
            }
        }
        
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
        } catch {
            print("Error loading shopping lists: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    func getSuggestions(for query: String) -> [Item] {
        guard !query.isEmpty else {
            print("Query is empty, returning no suggestions")
            return []
        }
        
        let query = query.lowercased()
        print("Getting suggestions for query: \(query)")
        
        // Fetch matching items from history
        let descriptor = FetchDescriptor<ItemHistory>(
            predicate: #Predicate { $0.lowercaseName.contains(query) },
            sortBy: [SortDescriptor(\.usageCount, order: .reverse), SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        
        do {
            let historyItems = try modelContext.fetch(descriptor)
            print("Found \(historyItems.count) suggestions in history")
            
            // Convert history items to Item objects for the UI
            return historyItems.prefix(5).map { history in
                Item(
                    name: history.name,
                    quantity: 1,
                    category: history.category,
                    isCompleted: false,
                    notes: nil,
                    dateAdded: Date(),
                    brand: history.brand,
                    unit: history.unit
                )
            }
        } catch {
            print("Error fetching suggestions: \(error)")
            return []
        }
    }
    
    func addOrUpdateSuggestion(_ item: Item) {
        let name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercaseName = name.lowercased()
        guard !name.isEmpty else { return }
        
        // Check if item exists in history
        let descriptor = FetchDescriptor<ItemHistory>(
            predicate: #Predicate { $0.lowercaseName == lowercaseName }
        )
        
        do {
            if let existingHistory = try modelContext.fetch(descriptor).first {
                // Update existing history
                existingHistory.usageCount += 1
                existingHistory.lastUsedDate = Date()
                existingHistory.brand = item.brand
                existingHistory.unit = item.unit
            } else {
                // Create new history entry
                let history = ItemHistory(
                    name: name,
                    category: item.category,
                    brand: item.brand,
                    unit: item.unit
                )
                modelContext.insert(history)
            }
            try modelContext.save()
        } catch {
            print("Error updating item history: \(error)")
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
        // Update history for all items before deleting the list
        for item in list.items {
            addOrUpdateSuggestion(item)
        }
        
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