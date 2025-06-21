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
                // Subtle background gradient
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
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
                    .listStyle(PlainListStyle())
                }
                
                // Enhanced Floating Action Buttons
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            if isExpanded {
                                // Settings button with enhanced design
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingSettings = true
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isExpanded = false
                                    }
                                    stopFabTimer()
                                } label: {
                                    Image(systemName: "gear")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(
                                            LinearGradient(
                                                colors: [Color(.systemGray4), Color(.systemGray3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                }
                                .transition(.scale.combined(with: .opacity))
                                
                                // Add button with enhanced design
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingAddList = true
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isExpanded = false
                                    }
                                    stopFabTimer()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(Circle())
                                        .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // Enhanced toggle button
                            Button {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
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
                                    .frame(width: 56, height: 56)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Shopping Lists")
            .navigationBarTitleDisplayMode(.large)
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
                            .foregroundColor(.accentColor)
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
        VStack(alignment: .leading, spacing: 8) {
            // Header with name and category
            VStack(alignment: .leading, spacing: 6) {
                Text(list.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .strikethrough(list.items.allSatisfy { $0.isCompleted })
                    .foregroundColor(list.items.allSatisfy { $0.isCompleted } ? .gray : .primary)
                
                HStack(spacing: 4) {
                    Image(systemName: list.category.icon)
                        .font(.caption2)
                        .foregroundColor(list.category.color)
                    Text(list.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(list.category.color)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(list.category.color.opacity(0.15))
                .cornerRadius(6)
            }
            
            Spacer(minLength: 4)
            
            // Compact progress bar
            if !list.items.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(Int(completionPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(list.completedItems.count)/\(list.items.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 4)
                                .fill(list.category.color)
                                .frame(width: geometry.size.width * completionPercentage, height: 6)
                                .animation(.easeInOut(duration: 0.3), value: completionPercentage)
                        }
                    }
                    .frame(height: 6)
                }
            }
            
            // Compact footer
            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    Image(systemName: "cart.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("\(list.pendingItems.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if list.budget != nil {
                    HStack(spacing: 3) {
                        Image(systemName: isOverBudget ? "exclamationmark.circle.fill" : "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(isOverBudget ? .red : .green)
                        Text(settingsManager.currency.symbol + String(format: "%.0f", list.totalEstimatedCost))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(isOverBudget ? .red : .secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray6), lineWidth: 0.5)
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ShoppingList.self, inMemory: true)
} 