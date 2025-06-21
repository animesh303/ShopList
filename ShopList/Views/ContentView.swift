import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lists: [ShoppingList]
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingAddList = false
    @State private var showingSettings = false
    @State private var searchText = ""
    @State private var sortOrder: ListSortOrder = .dateDesc
    @State private var isExpanded = false
    @State private var fabTimer: Timer?
    @State private var navigationPath = NavigationPath()
    
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
        NavigationStack(path: $navigationPath) {
            ZStack {
                if settingsManager.defaultListViewStyle == .grid {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
                        ], spacing: 16) {
                            ForEach(sortedLists) { list in
                                NavigationLink(value: list) {
                                    GridListCard(list: list)
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    List {
                        ForEach(sortedLists) { list in
                            NavigationLink(value: list) {
                                ListRow(list: list)
                            }
                        }
                        .onDelete(perform: deleteLists)
                    }
                }
                
                // Floating Action Buttons for adding new lists and opening settings
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        // Collapsible FAB for add and settings
                        VStack {
                            if isExpanded {
                                // Settings button
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingSettings = true
                                    withAnimation {
                                        isExpanded = false
                                    }
                                    stopFabTimer()
                                } label: {
                                    Image(systemName: "gear")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                        .background(Color.secondary)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(.bottom, 10)
                                // Add button
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingAddList = true
                                    withAnimation {
                                        isExpanded = false
                                    }
                                    stopFabTimer()
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
                                .padding(.bottom, 10)
                            }
                            // Toggle button
                            Button {
                                withAnimation {
                                    isExpanded.toggle()
                                }
                                if isExpanded {
                                    startFabTimer()
                                } else {
                                    stopFabTimer()
                                }
                            } label: {
                                Image(systemName: isExpanded ? "chevron.down" : "ellipsis")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.accentColor)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
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
            .onChange(of: notificationManager.listToOpen) { _, list in
                if let list = list {
                    navigationPath.append(list)
                    // Clear the list to open to prevent repeated navigation
                    notificationManager.listToOpen = nil
                }
            }
        }
    }
    
    private func deleteLists(at offsets: IndexSet) {
        for index in offsets {
            let list = sortedLists[index]
            modelContext.delete(list)
        }
    }
    
    // MARK: - FAB Timer Functions
    
    private func startFabTimer() {
        stopFabTimer() // Cancel any existing timer
        fabTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation {
                isExpanded = false
            }
        }
    }
    
    private func stopFabTimer() {
        fabTimer?.invalidate()
        fabTimer = nil
    }
}

struct GridListCard: View {
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
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and category
            VStack(alignment: .leading, spacing: 8) {
                Text(list.name)
                    .font(.headline)
                    .lineLimit(2)
                    .strikethrough(list.items.allSatisfy { $0.isCompleted })
                    .foregroundColor(list.items.allSatisfy { $0.isCompleted } ? .gray : .primary)
                
                Text(list.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(list.category.color.opacity(0.2))
                    .foregroundColor(list.category.color)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // Progress bar
            ProgressView(value: completionPercentage)
                .tint(list.category.color)
            
            // Footer with item count and budget
            HStack {
                Text("\(list.pendingItems.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if list.budget != nil {
                    HStack(spacing: 4) {
                        Image(systemName: isOverBudget ? "exclamationmark.circle.fill" : "dollarsign.circle")
                            .font(.caption)
                        Text(settingsManager.currency.symbol + String(format: "%.2f", list.totalEstimatedCost))
                            .font(.caption)
                    }
                    .foregroundColor(isOverBudget ? .red : .secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ShoppingList.self, inMemory: true)
} 