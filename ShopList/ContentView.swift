//
//  ContentView.swift
//  ShopList
//
//  Created by Animesh Naskar on 13/06/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var viewModel: ShoppingListViewModel
    @State private var showingAddListSheet = false
    @State private var showingAddItemSheet = false
    @State private var showingShareSheet = false
    @State private var listToShare: ShoppingList?
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .dateCreated
    @State private var selectedCategory: ListCategory?
    @State private var showingFilters = false
    
    private func applySearchFilter(_ lists: [ShoppingList]) -> [ShoppingList] {
        guard !searchText.isEmpty else { return lists }
        return lists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func applyCategoryFilter(_ lists: [ShoppingList]) -> [ShoppingList] {
        guard let category = selectedCategory else { return lists }
        return lists.filter { $0.category == category }
    }
    
    private func applySorting(_ lists: [ShoppingList]) -> [ShoppingList] {
        var sortedLists = lists
        switch sortOrder {
        case .dateCreated:
            sortedLists.sort { $0.dateCreated > $1.dateCreated }
        case .name:
            sortedLists.sort { $0.name < $1.name }
        case .itemCount:
            sortedLists.sort { $0.items.count > $1.items.count }
        case .lastModified:
            sortedLists.sort { $0.lastModified > $1.lastModified }
        }
        return sortedLists
    }
    
    private var filteredLists: [ShoppingList] {
        let lists = viewModel.shoppingLists
        let searchFiltered = applySearchFilter(lists)
        let categoryFiltered = applyCategoryFilter(searchFiltered)
        return applySorting(categoryFiltered)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredLists) { list in
                    NavigationLink(destination: ShoppingListView(list: list, viewModel: viewModel)) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(list.name)
                                    .font(.headline)
                                if list.isTemplate {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                if let budget = list.budget {
                                    Text(budget, format: .currency(code: "USD").precision(.fractionLength(2)))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            HStack {
                                Text("\(list.items.count) items")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                if list.isShared {
                                    Image(systemName: "person.2")
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                Text(list.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    let listsToDelete = indexSet.map { filteredLists[$0] }
                    for list in listsToDelete {
                        Task {
                            try? await viewModel.deleteShoppingList(list)
                        }
                    }
                }
            }
            .navigationTitle("Shopping Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddListSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddListSheet) {
                AddListView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(sortOrder: $sortOrder, selectedCategory: $selectedCategory)
            }
        }
        .errorAlert(error: $viewModel.currentError, isPresented: $viewModel.showingError)
    }
}

enum SortOrder: String, CaseIterable {
    case dateCreated = "Date Created"
    case name = "Name"
    case itemCount = "Item Count"
    case lastModified = "Last Modified"
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sortOrder: SortOrder
    @Binding var selectedCategory: ListCategory?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort By")) {
                    Picker("Sort Order", selection: $sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All").tag(nil as ListCategory?)
                        ForEach(ListCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category as ListCategory?)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
