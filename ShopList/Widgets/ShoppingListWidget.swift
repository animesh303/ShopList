import WidgetKit
import SwiftUI

struct ShoppingListWidgetEntry: TimelineEntry {
    let date: Date
    let lists: [ShoppingList]
}

struct ShoppingListWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShoppingListWidgetEntry {
        ShoppingListWidgetEntry(date: Date(), lists: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ShoppingListWidgetEntry) -> Void) {
        let entry = ShoppingListWidgetEntry(date: Date(), lists: loadLists())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ShoppingListWidgetEntry>) -> Void) {
        let entry = ShoppingListWidgetEntry(date: Date(), lists: loadLists())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    private func loadLists() -> [ShoppingList] {
        if let data = UserDefaults.standard.data(forKey: "shoppingLists"),
           let lists = try? JSONDecoder().decode([ShoppingList].self, from: data) {
            return lists
        }
        return []
    }
}

struct ShoppingListWidgetEntryView: View {
    let entry: ShoppingListWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(entry.lists.prefix(3)) { list in
                VStack(alignment: .leading) {
                    Text(list.name)
                        .font(.headline)
                    Text("\(list.pendingItems.count) items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if list.id != entry.lists.prefix(3).last?.id {
                    Divider()
                }
            }
        }
        .padding()
    }
}

struct ShoppingListWidget: Widget {
    let kind: String = "ShoppingListWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShoppingListWidgetProvider()) { entry in
            ShoppingListWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Shopping Lists")
        .description("View your shopping lists")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
} 