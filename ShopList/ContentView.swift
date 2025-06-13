//
//  ContentView.swift
//  ShopList
//
//  Created by Animesh Naskar on 13/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var showingAddListSheet = false
    @State private var showingAddItemSheet = false
    @State private var showingShareSheet = false
    @State private var listToShare: ShoppingList?
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.shoppingLists) { list in
                    NavigationLink(destination: ShoppingListView(list: list, viewModel: viewModel)) {
                        VStack(alignment: .leading) {
                            Text(list.name)
                                .font(.headline)
                            Text("\(list.items.count) items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteList(at: indexSet)
                }
            }
            .navigationTitle("Shopping Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddListSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddListSheet) {
                AddListView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }
}

#Preview {
    ContentView()
}
