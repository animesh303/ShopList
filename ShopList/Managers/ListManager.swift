import Foundation
import SwiftData

@MainActor
final class ListManager {
    static let shared = ListManager()
    private let modelContext: ModelContext
    
    private init() {
        guard let modelContainer = try? ModelContainer(for: ShoppingList.self) else {
            fatalError("Failed to create ModelContainer for ShoppingList")
        }
        self.modelContext = modelContainer.mainContext
    }
    
    func addList(_ list: ShoppingList) {
        modelContext.insert(list)
        try? modelContext.save()
    }
    
    func updateList(_ list: ShoppingList) {
        try? modelContext.save()
    }
    
    func deleteList(_ list: ShoppingList) {
        modelContext.delete(list)
        try? modelContext.save()
    }
    
    func fetchLists() -> [ShoppingList] {
        let descriptor = FetchDescriptor<ShoppingList>(sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
} 