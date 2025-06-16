import SwiftUI
import UIKit
import SwiftData

enum ItemSortOrder: String, CaseIterable {
    case category = "Category"
    case name = "Name"
    case priority = "Priority"
    case dateAdded = "Date Added"
}

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lists: [ShoppingList]
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    @State private var showingAddList = false
    @State private var searchText = ""
    @State private var sortOrder: ListSortOrder = .dateDesc
    @State private var showingCompletedLists = true
    
    private var filteredLists: [ShoppingList] {
        var filtered = lists
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { list in
                list.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply completed lists filter
        if !showingCompletedLists {
            filtered = filtered.filter { !$0.items.allSatisfy { $0.isCompleted } }
        }
        
        // Apply sorting
        switch sortOrder {
        case .nameAsc:
            filtered.sort { $0.name < $1.name }
        case .nameDesc:
            filtered.sort { $0.name > $1.name }
        case .dateDesc:
            filtered.sort { $0.dateCreated > $1.dateCreated }
        case .dateAsc:
            filtered.sort { $0.dateCreated < $1.dateCreated }
        case .categoryAsc:
            filtered.sort { $0.category.rawValue < $1.category.rawValue }
        case .categoryDesc:
            filtered.sort { $0.category.rawValue > $1.category.rawValue }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredLists) { list in
                    NavigationLink(destination: ListDetailView(list: list)) {
                        ListRow(list: list)
                    }
                }
                .onDelete(perform: deleteLists)
            }
            .navigationTitle("Shopping Lists")
            .searchable(text: $searchText, prompt: "Search lists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { showingAddList = true }) {
                            Label("Add List", systemImage: "plus")
                        }
                        
                        Picker("Sort By", selection: $sortOrder) {
                            ForEach(ListSortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                        
                        Toggle("Show Completed", isOn: $showingCompletedLists)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddList) {
                NavigationView {
                    Form {
                        Section {
                            TextField("List Name", text: .constant(""))
                        }
                    }
                    .navigationTitle("New List")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddList = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                // Add list logic here
                                showingAddList = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deleteLists(at offsets: IndexSet) {
        for index in offsets {
            let list = filteredLists[index]
            modelContext.delete(list)
        }
    }
}

struct ListRow: View {
    let list: ShoppingList
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(list.name)
                .strikethrough(list.items.allSatisfy { $0.isCompleted })
                .foregroundColor(list.items.allSatisfy { $0.isCompleted } ? .gray : .primary)
            
            HStack(spacing: 8) {
                Text("\(list.items.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if list.totalEstimatedCost > 0 {
                    Text(list.totalEstimatedCost, format: .currency(code: settingsManager.currency.rawValue))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(list.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(list.category.color.opacity(0.2))
                    .foregroundColor(list.category.color)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    return ShoppingListView()
        .modelContainer(container)
}
