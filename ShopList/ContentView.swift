//
//  ContentView.swift
//  ShopList
//
//  Created by Animesh Naskar on 13/06/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ShoppingListViewModel
    @State private var showingAddListSheet = false
    @State private var showingAddItemSheet = false
    @State private var showingShareSheet = false
    @State private var listToShare: ShoppingList?
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .dateCreated
    @State private var selectedCategory: ListCategory?
    @State private var showingFilters = false
    
    var filteredLists: [ShoppingList] {
        var lists = viewModel.shoppingLists
        
        // Apply search filter
        if !searchText.isEmpty {
            lists = lists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            lists = lists.filter { $0.category == category }
        }
        
        // Apply sorting
        switch sortOrder {
        case .dateCreated:
            lists.sort { $0.dateCreated > $1.dateCreated }
        case .name:
            lists.sort { $0.name < $1.name }
        case .itemCount:
            lists.sort { $0.items.count > $1.items.count }
        case .lastModified:
            lists.sort { $0.lastModified > $1.lastModified }
        }
        
        return lists
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
                                    Text(budget, format: .currency(code: "USD").precision(.fractionLength(0...2)))
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
                    viewModel.deleteList(at: indexSet)
                }
            }
            .searchable(text: $searchText, prompt: "Search lists")
            .navigationTitle("Shopping Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddListSheet = true }) {
                            Label("New List", systemImage: "plus")
                        }
                        
                        Button(action: { showingFilters.toggle() }) {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort by", selection: $sortOrder) {
                            Text("Date Created").tag(SortOrder.dateCreated)
                            Text("Name").tag(SortOrder.name)
                            Text("Item Count").tag(SortOrder.itemCount)
                            Text("Last Modified").tag(SortOrder.lastModified)
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showingAddListSheet) {
                AddListView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(selectedCategory: $selectedCategory)
            }
        }
        .errorAlert(error: $viewModel.currentError, isPresented: $viewModel.showingError)
    }
}

enum SortOrder {
    case dateCreated
    case name
    case itemCount
    case lastModified
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: ListCategory?
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Category")) {
                    Button("All Categories") {
                        selectedCategory = nil
                        dismiss()
                    }
                    
                    ForEach(ListCategory.allCases, id: \.self) { category in
                        Button(category.rawValue) {
                            selectedCategory = category
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Filter Lists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
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
