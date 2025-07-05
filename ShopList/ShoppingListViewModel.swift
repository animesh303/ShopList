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
    
    // Sendable wrapper for list information
    struct ListInfo: Sendable {
        let id: UUID
        let name: String
        let persistentModelID: PersistentIdentifier
    }
    
    func findListInfo(byName name: String) async -> ListInfo? {
        guard let list = shoppingLists.first(where: { $0.name.lowercased() == name.lowercased() }) else {
            return nil
        }
        return ListInfo(
            id: list.id,
            name: list.name,
            persistentModelID: list.persistentModelID
        )
    }
    
    func addItemToPersistentID(_ item: Item, persistentID: PersistentIdentifier) async throws {
        guard let list = shoppingLists.first(where: { $0.persistentModelID == persistentID }) else {
            throw AppError.listNotFound
        }
        list.addItem(item)
        try modelContext.save()
        addOrUpdateSuggestion(item)
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
    
    // MARK: - Sharing Methods
    
    func generateShareableContent(for list: ShoppingList, currency: Currency = .USD) -> String {
        var content = "🛒 \(list.name)\n"
        content += "📅 Created: \(formatDate(list.dateCreated))\n\n"
        
        if let budget = list.budget {
            content += "💰 Budget: \(currency.symbol)\(formatDecimal(Decimal(budget)))\n"
            content += "💳 Estimated Total: \(currency.symbol)\(formatDecimal(Decimal(list.totalEstimatedCost)))\n"
            content += "✅ Spent: \(currency.symbol)\(formatDecimal(Decimal(list.totalSpentCost)))\n\n"
        }
        
        if let location = list.location {
            content += "📍 Store: \(location.name)\n\n"
        }
        
        content += "📋 Items (\(list.items.count) total):\n\n"
        
        // Sort items by name and add serial numbers
        let sortedItems = list.items.sorted(by: { $0.name < $1.name })
        
        for (index, item) in sortedItems.enumerated() {
            let serialNumber = index + 1
            let checkmark = item.isCompleted ? "✅" : "⭕"
            let quantity = item.quantity > Decimal(1) ? " (\(item.quantity))" : ""
            let unit = (item.unit?.isEmpty == false) ? " \(item.unit!)" : ""
            
            // Debug logging
            print("DEBUG: Item '\(item.name)' - pricePerUnit: \(item.pricePerUnit?.description ?? "nil")")
            
            let price = item.pricePerUnit != nil ? " - \(currency.symbol)\(formatDecimal(item.pricePerUnit!))" : ""
            let notes = (item.notes?.isEmpty == false) ? " (\(item.notes!))" : ""
            
            content += "\(serialNumber). \(checkmark) \(item.name)\(quantity)\(unit)\(price)\(notes)\n"
        }
        
        content += "\n---\n"
        content += "Shared from ShopList App"
        
        return content
    }
    
    func generateCSVContent(for list: ShoppingList, currency: Currency = .USD) -> String {
        var csv = "No.,Name,Quantity,Unit,Price (\(currency.symbol)),Notes,Completed\n"
        
        let sortedItems = list.items.sorted(by: { $0.name < $1.name })
        
        for (index, item) in sortedItems.enumerated() {
            let serialNumber = index + 1
            let name = item.name.replacingOccurrences(of: ",", with: ";")
            let quantity = String(describing: item.quantity)
            let unit = item.unit ?? ""
            
            // Debug logging
            print("DEBUG CSV: Item '\(item.name)' - pricePerUnit: \(item.pricePerUnit?.description ?? "nil")")
            
            let price = item.pricePerUnit != nil ? formatDecimal(item.pricePerUnit!) : ""
            let notes = item.notes?.replacingOccurrences(of: ",", with: ";") ?? ""
            let completed = item.isCompleted ? "Yes" : "No"
            
            csv += "\(serialNumber),\(name),\(quantity),\(unit),\(price),\(notes),\(completed)\n"
        }
        
        return csv
    }
    
    func createCSVFile(for list: ShoppingList, currency: Currency = .USD) -> URL? {
        let csvContent = generateCSVContent(for: list, currency: currency)
        let filename = "\(list.name.replacingOccurrences(of: " ", with: "_")).csv"
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error creating CSV file: \(error)")
            return nil
        }
    }
    
    func shareList(_ list: ShoppingList) {
        listToShare = list
        showingShareSheet = true
    }
    
    func getShareableItems(for list: ShoppingList, currency: Currency = .USD) -> [Any] {
        var items: [Any] = []
        
        // Add text content
        items.append(generateShareableContent(for: list, currency: currency))
        
        // Add CSV file if available
        if let csvURL = createCSVFile(for: list, currency: currency) {
            items.append(csvURL)
        }
        
        return items
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDecimal(_ decimal: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSDecimalNumber(decimal: decimal)) ?? "0.00"
    }
} 
