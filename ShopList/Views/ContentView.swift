import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lists: [ShoppingList]
    @StateObject private var settingsManager = UserSettingsManager.shared
    @State private var showingAddList = false
    @State private var showingSettings = false
    @State private var searchText = ""
    @State private var sortOrder: ListSortOrder = .dateDesc
    
    private var filteredLists: [ShoppingList] {
        if searchText.isEmpty {
            return lists
        }
        return lists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var sortedLists: [ShoppingList] {
        filteredLists.sorted { first, second in
            switch sortOrder {
            case .nameAsc:
                return first.name < second.name
            case .nameDesc:
                return first.name > second.name
            case .dateAsc:
                return first.dateCreated < second.dateCreated
            case .dateDesc:
                return first.dateCreated > second.dateCreated
            case .categoryAsc:
                return first.category.rawValue < second.category.rawValue
            case .categoryDesc:
                return first.category.rawValue > second.category.rawValue
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(sortedLists) { list in
                        NavigationLink(value: list) {
                            ListRow(list: list)
                        }
                    }
                    .onDelete(perform: deleteLists)
                }
                .navigationTitle("Shopping Lists")
                .searchable(text: $searchText, prompt: "Search lists")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Picker("Sort Order", selection: $sortOrder) {
                                ForEach(ListSortOrder.allCases) { order in
                                    Text(order.displayName).tag(order)
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
                
                // Floating Action Button for adding new lists
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingAddList = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showingAddList) {
                AddListView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(for: ShoppingList.self) { list in
                ListDetailView(list: list)
            }
        }
    }
    
    private func deleteLists(at offsets: IndexSet) {
        for index in offsets {
            let list = sortedLists[index]
            modelContext.delete(list)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ShoppingList.self, inMemory: true)
} 