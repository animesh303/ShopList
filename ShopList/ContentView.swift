//
//  ContentView.swift
//  ShopList
//
//  Created by Animesh Naskar on 13/06/25.
//

import SwiftUI
import SwiftData

struct ListRowView: View {
    let list: ShoppingList
    let onDelete: () -> Void
    let onShare: () -> Void
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(list.name)
                        .font(.headline)
                    Text(list.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(list.budget ?? 0, format: .currency(code: settingsManager.currency.rawValue).precision(.fractionLength(2)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !list.items.isEmpty {
                Text("\(list.items.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let budget = list.budget {
                HStack {
                    Text("Budget:")
                        .foregroundStyle(.secondary)
                    Text(budget, format: .currency(code: settingsManager.currency.rawValue).precision(.fractionLength(2)))
                }
            }
            
            HStack {
                Text("Estimated Total:")
                    .foregroundStyle(.secondary)
                Text(list.estimatedTotal, format: .currency(code: settingsManager.currency.rawValue).precision(.fractionLength(2)))
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                onShare()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .tint(.blue)
        }
    }
}

struct SortFilterMenu: View {
    @Binding var sortOrder: SortOrder
    @Binding var selectedCategory: ListCategory?
    
    var body: some View {
        Menu {
            Picker("Sort By", selection: $sortOrder) {
                Text("Name (A-Z)").tag(SortOrder.nameAsc)
                Text("Name (Z-A)").tag(SortOrder.nameDesc)
                Text("Date (Oldest)").tag(SortOrder.dateAsc)
                Text("Date (Newest)").tag(SortOrder.dateDesc)
                Text("Category (A-Z)").tag(SortOrder.categoryAsc)
                Text("Category (Z-A)").tag(SortOrder.categoryDesc)
            }
            
            Divider()
            
            Menu("Filter by Category") {
                Button("All Categories") {
                    selectedCategory = nil
                }
                
                ForEach(ListCategory.allCases.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { category in
                    Button(category.rawValue) {
                        selectedCategory = category
                    }
                }
            }
        } label: {
            Label("Sort & Filter", systemImage: "arrow.up.arrow.down")
        }
    }
}

struct ListsSection: View {
    let lists: [ShoppingList]
    let viewModel: ShoppingListViewModel
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        ForEach(lists) { list in
            NavigationLink(destination: ShoppingListView(list: list, viewModel: viewModel)) {
                ListRowView(
                    list: list,
                    onDelete: {
                        Task {
                            do {
                                try await viewModel.deleteShoppingList(list)
                            } catch {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    },
                    onShare: {
                        // Share functionality will be implemented later
                    }
                )
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var viewModel: ShoppingListViewModel
    @State private var showingAddList = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var searchText = ""
    @State private var selectedCategory: ListCategory?
    @State private var sortOrder: SortOrder = .nameAsc
    
    private var filteredLists: [ShoppingList] {
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
        case .nameAsc:
            lists.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDesc:
            lists.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .dateAsc:
            lists.sort { $0.dateCreated < $1.dateCreated }
        case .dateDesc:
            lists.sort { $0.dateCreated > $1.dateCreated }
        case .categoryAsc:
            lists.sort { $0.category.rawValue.localizedCaseInsensitiveCompare($1.category.rawValue) == .orderedAscending }
        case .categoryDesc:
            lists.sort { $0.category.rawValue.localizedCaseInsensitiveCompare($1.category.rawValue) == .orderedDescending }
        }
        
        return lists
    }
    
    var body: some View {
        TabView {
            NavigationView {
                List {
                    ListsSection(
                        lists: filteredLists,
                        viewModel: viewModel,
                        showingError: $showingError,
                        errorMessage: $errorMessage
                    )
                }
                .navigationTitle("Shopping Lists")
                .searchable(text: $searchText, prompt: "Search lists")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SortFilterMenu(sortOrder: $sortOrder, selectedCategory: $selectedCategory)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddList = true
                        } label: {
                            Label("Add List", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddList) {
                    AddListView(viewModel: viewModel)
                }
                .alert("Error", isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
            }
            .tabItem {
                Label("Lists", systemImage: "list.bullet")
            }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

enum SortOrder {
    case nameAsc, nameDesc
    case dateAsc, dateDesc
    case categoryAsc, categoryDesc
}

#Preview {
    ContentView()
}
