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
                // Enhanced background with subtle gradient
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.background,
                        DesignSystem.Colors.secondaryBackground.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if settingsManager.defaultListViewStyle == .grid {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 160, maximum: 200), spacing: DesignSystem.Spacing.lg)
                        ], spacing: DesignSystem.Spacing.lg) {
                            ForEach(sortedLists) { list in
                                NavigationLink(value: list) {
                                    GridListCard(list: list)
                                }
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
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
                
                // Enhanced Floating Action Buttons with improved design
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: DesignSystem.Spacing.md) {
                            if isExpanded {
                                // Settings button with enhanced design
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingSettings = true
                                    withAnimation(DesignSystem.Animations.spring) {
                                        isExpanded = false
                                    }
                                    stopFabTimer()
                                } label: {
                                    Image(systemName: "gear")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                        .background(
                                            LinearGradient(
                                                colors: [DesignSystem.Colors.secondaryText, DesignSystem.Colors.tertiaryText],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(Circle())
                                        .shadow(
                                            color: DesignSystem.Shadows.medium.color,
                                            radius: DesignSystem.Shadows.medium.radius,
                                            x: DesignSystem.Shadows.medium.x,
                                            y: DesignSystem.Shadows.medium.y
                                        )
                                }
                                .transition(.scale.combined(with: .opacity))
                                
                                // Add button with enhanced design
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingAddList = true
                                    withAnimation(DesignSystem.Animations.spring) {
                                        isExpanded = false
                                    }
                                    stopFabTimer()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                        .background(
                                            LinearGradient(
                                                colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(Circle())
                                        .shadow(
                                            color: DesignSystem.Colors.primary.opacity(0.3),
                                            radius: DesignSystem.Shadows.medium.radius,
                                            x: DesignSystem.Shadows.medium.x,
                                            y: DesignSystem.Shadows.medium.y
                                        )
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // Enhanced toggle button
                            Button {
                                withAnimation(DesignSystem.Animations.spring) {
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
                                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                    .background(
                                        LinearGradient(
                                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(
                                        color: DesignSystem.Colors.primary.opacity(0.3),
                                        radius: DesignSystem.Shadows.medium.radius,
                                        x: DesignSystem.Shadows.medium.x,
                                        y: DesignSystem.Shadows.medium.y
                                    )
                            }
                        }
                        .padding(.trailing, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
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
                                    .foregroundColor(DesignSystem.Colors.info)
                                Text("Search restricted to local area")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                Spacer()
                            }
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.bottom, DesignSystem.Spacing.sm)
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
                            .foregroundColor(DesignSystem.Colors.primary)
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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Header with name and category
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(list.name)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .strikethrough(list.items.allSatisfy { $0.isCompleted })
                    .foregroundColor(list.items.allSatisfy { $0.isCompleted } ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: list.category.icon)
                        .font(.caption2)
                        .foregroundColor(list.category.color)
                    Text(list.category.rawValue)
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(list.category.color)
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(list.category.color.opacity(0.15))
                .cornerRadius(DesignSystem.CornerRadius.xs)
            }
            
            Spacer(minLength: DesignSystem.Spacing.xs)
            
            // Compact progress bar
            if !list.items.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text("\(Int(completionPercentage * 100))%")
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        Spacer()
                        Text("\(list.completedItems.count)/\(list.items.count)")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                                .fill(DesignSystem.Colors.tertiaryBackground)
                                .frame(height: 6)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                                .fill(list.category.color)
                                .frame(width: geometry.size.width * completionPercentage, height: 6)
                                .animation(DesignSystem.Animations.standard, value: completionPercentage)
                        }
                    }
                    .frame(height: 6)
                }
            }
            
            // Compact footer
            HStack(spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "cart.fill")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.info)
                    Text("\(list.pendingItems.count)")
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                if list.budget != nil {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: isOverBudget ? "exclamationmark.circle.fill" : "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(isOverBudget ? DesignSystem.Colors.error : DesignSystem.Colors.success)
                        Text(settingsManager.currency.symbol + String(format: "%.0f", list.totalEstimatedCost))
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(isOverBudget ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.background)
                .shadow(
                    color: DesignSystem.Shadows.small.color,
                    radius: DesignSystem.Shadows.small.radius,
                    x: DesignSystem.Shadows.small.x,
                    y: DesignSystem.Shadows.small.y
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(DesignSystem.Colors.borderLight, lineWidth: 0.5)
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ShoppingList.self, inMemory: true)
} 