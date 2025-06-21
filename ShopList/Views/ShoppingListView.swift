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
    
    private var filteredLists: [ShoppingList] {
        var filtered = lists
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { list in
                list.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply completed lists filter
        if !settingsManager.showCompletedItemsByDefault {
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
            .overlay(
                Group {
                    if settingsManager.restrictSearchToLocality && !searchText.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                Text("Search restricted to local area")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                }
            )
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
                        
                        Toggle("Show Completed", isOn: $settingsManager.showCompletedItemsByDefault)
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
    
    private var completionPercentage: Double {
        guard !list.items.isEmpty else { return 0 }
        return Double(list.completedItems.count) / Double(list.items.count)
    }
    
    private var isOverBudget: Bool {
        guard let budget = list.budget else { return false }
        return list.totalEstimatedCost > budget
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with name and category
            HStack(alignment: .center) {
                Text(list.name)
                    .font(.headline)
                    .lineLimit(1)
                    .strikethrough(list.items.allSatisfy { $0.isCompleted })
                    .foregroundColor(list.items.allSatisfy { $0.isCompleted } ? .gray : .primary)
                
                Spacer()
                
                Text(list.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(list.category.color.opacity(0.2))
                    .foregroundColor(list.category.color)
                    .cornerRadius(8)
            }
            
            // Progress bar for completion
            if !list.items.isEmpty {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(completionPercentage == 1.0 ? Color.green : Color.blue)
                            .frame(width: geometry.size.width * completionPercentage, height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            // Details row
            HStack(spacing: 12) {
                // Items count
                HStack(spacing: 4) {
                    Image(systemName: "cart")
                        .font(.caption)
                    Text("\(list.items.count)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                // Completion status
                if !list.items.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                            .font(.caption)
                        Text("\(Int(completionPercentage * 100))%")
                            .font(.caption)
                    }
                    .foregroundColor(completionPercentage == 1.0 ? .green : .secondary)
                }
                
                // Budget status
                if list.budget != nil {
                    HStack(spacing: 4) {
                        Image(systemName: isOverBudget ? "exclamationmark.circle.fill" : "dollarsign.circle")
                            .font(.caption)
                        Text(settingsManager.currency.symbol + String(format: "%.2f", list.totalEstimatedCost))
                            .font(.caption)
                    }
                    .foregroundColor(isOverBudget ? .red : .secondary)
                }
                
                Spacer()
                
                // Last modified date
                Text(list.lastModified, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    return ShoppingListView()
        .modelContainer(container)
}
