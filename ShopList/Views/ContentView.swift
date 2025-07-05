import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lists: [ShoppingList]
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showingAddList = false
    @State private var showingSettings = false
    @State private var showingSortPicker = false
    @State private var searchText = ""
    @State private var sortOrder: ListSortOrder = .dateDesc
    @State private var isExpanded = false
    @State private var fabTimer: Timer?
    @State private var navigationPath = NavigationPath()
    @State private var showingUpgradePrompt = false
    @State private var showingPremiumUpgrade = false
    @State private var upgradePromptMessage = ""
    @State private var showingShareSheet = false
    @State private var listToShare: ShoppingList?

    
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
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Show usage limit view for free users
                    if subscriptionManager.shouldShowUpgradePrompt() {
                        UsageLimitView()
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                    }
                    
                    if sortedLists.isEmpty {
                        // Enhanced empty state view with card design
                        VStack(spacing: 0) {
                            Spacer()
                            
                            // Main empty state card
                            VStack(spacing: DesignSystem.Spacing.xxl) {
                                // Icon container with gradient background
                                ZStack {
                                    // Gradient background circle with enhanced contrast
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    DesignSystem.Colors.primary.opacity(0.25),
                                                    DesignSystem.Colors.secondary.opacity(0.2),
                                                    DesignSystem.Colors.accent1.opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                        .shadow(
                                            color: DesignSystem.Colors.primary.opacity(0.4),
                                            radius: 25,
                                            x: 0,
                                            y: 15
                                        )
                                        .shadow(
                                            color: Color.black.opacity(0.2),
                                            radius: 15,
                                            x: 0,
                                            y: 8
                                        )
                                    
                                    // Main icon with enhanced contrast
                                    Image(systemName: "list.bullet.clipboard.fill")
                                        .font(.system(size: 50, weight: .semibold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    DesignSystem.Colors.primary,
                                                    DesignSystem.Colors.primary.opacity(0.8),
                                                    DesignSystem.Colors.secondary
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(
                                            color: Color.black.opacity(0.3),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                                
                                // Text content with enhanced contrast
                                VStack(spacing: DesignSystem.Spacing.md) {
                                    Text("No Shopping Lists")
                                        .font(DesignSystem.Typography.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(DesignSystem.Colors.primaryText)
                                        .multilineTextAlignment(.center)
                                        .shadow(
                                            color: Color.black.opacity(0.1),
                                            radius: 2,
                                            x: 0,
                                            y: 1
                                        )
                                    
                                    Text("Start organizing your shopping by creating your first list")
                                        .font(DesignSystem.Typography.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(3)
                                        .padding(.horizontal, DesignSystem.Spacing.lg)
                                        .shadow(
                                            color: Color.black.opacity(0.05),
                                            radius: 1,
                                            x: 0,
                                            y: 0.5
                                        )
                                }
                                
                                // Action button with enhanced contrast and shadows
                                Button {
                                    if subscriptionManager.canCreateList() {
                                        showingAddList = true
                                    } else {
                                        showingPremiumUpgrade = true
                                    }
                                } label: {
                                    HStack(spacing: DesignSystem.Spacing.sm) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                        Text("Create First List")
                                            .font(DesignSystem.Typography.headline)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, DesignSystem.Spacing.xxl)
                                    .padding(.vertical, DesignSystem.Spacing.lg)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                DesignSystem.Colors.primary,
                                                DesignSystem.Colors.primary.opacity(0.9),
                                                DesignSystem.Colors.primary.opacity(0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(DesignSystem.CornerRadius.xl)
                                    .shadow(
                                        color: DesignSystem.Colors.primary.opacity(0.6),
                                        radius: 15,
                                        x: 0,
                                        y: 8
                                    )
                                    .shadow(
                                        color: Color.black.opacity(0.3),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.4),
                                                        Color.white.opacity(0.1)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                                }
                            }
                            .padding(DesignSystem.Spacing.xxxl)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(.systemBackground),
                                                Color(.secondarySystemBackground).opacity(0.5)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color(.separator).opacity(0.5),
                                                        Color(.separator).opacity(0.2)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                                    .shadow(
                                        color: Color.black.opacity(0.25),
                                        radius: 25,
                                        x: 0,
                                        y: 12
                                    )
                                    .shadow(
                                        color: DesignSystem.Colors.primary.opacity(0.15),
                                        radius: 35,
                                        x: 0,
                                        y: 18
                                    )
                            )
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                            
                            Spacer()
                        }
                    } else {
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
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                
                // Enhanced Floating Action Buttons with vibrant design
                VStack {
                    Spacer()
                    HStack {
                        // Back Button FAB at bottom left
                        VStack {
                            Spacer()
                            BackButtonFAB(isVisible: !navigationPath.isEmpty) {
                                navigationPath.removeLast()
                            }
                        }
                        .padding(.leading, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                        
                        Spacer()
                        
                        // Right FAB at bottom right
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Spacer() // Push FAB to bottom
                            
                            if isExpanded {
                                // Sort button with vibrant design
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingSortPicker = true
                                    withAnimation(DesignSystem.Animations.spring) {
                                        isExpanded = false
                                    }
                                    stopFabTimer()
                                } label: {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                        .background(
                                            DesignSystem.Colors.info.opacity(0.8)
                                        )
                                        .clipShape(Circle())
                                        .shadow(
                                            color: DesignSystem.Colors.info.opacity(0.4),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                                .transition(.scale.combined(with: .opacity))
                                
                                // Share All Lists button with vibrant design
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    // Create a combined list for sharing
                                    let combinedContent = createCombinedShareContent()
                                    let shareItems: [Any] = [combinedContent]
                                    
                                    // Present share sheet
                                    let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                                    
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first {
                                        window.rootViewController?.present(activityVC, animated: true)
                                    }
                                    
                                    withAnimation(DesignSystem.Animations.spring) {
                                        isExpanded = false
                                    }
                                    stopFabTimer()
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                                        .background(
                                            DesignSystem.Colors.success.opacity(0.8)
                                        )
                                        .clipShape(Circle())
                                        .shadow(
                                            color: DesignSystem.Colors.success.opacity(0.4),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                                .transition(.scale.combined(with: .opacity))
                                
                                // Settings button with vibrant design
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
                                            DesignSystem.Colors.secondaryButtonGradient
                                        )
                                        .clipShape(Circle())
                                        .shadow(
                                            color: DesignSystem.Colors.secondary.opacity(0.4),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                                .transition(.scale.combined(with: .opacity))
                                
                                // Add button with vibrant design
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    // Check if user can create a new list
                                    if subscriptionManager.canCreateList() {
                                        showingAddList = true
                                    } else {
                                        showingPremiumUpgrade = true
                                    }
                                    
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
                                            DesignSystem.Colors.primaryButtonGradient
                                        )
                                        .clipShape(Circle())
                                        .shadow(
                                            color: DesignSystem.Colors.primary.opacity(0.4),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // Enhanced toggle button with vibrant design
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
                                        DesignSystem.Colors.accentButtonGradient
                                    )
                                    .clipShape(Circle())
                                    .shadow(
                                        color: DesignSystem.Colors.accent1.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                        }
                        .padding(.trailing, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                    }
                }
            }
            .enhancedNavigation(
                title: "Shopping Lists",
                subtitle: "Manage your shopping lists",
                icon: "app_icon",
                style: .primary,
                showBanner: true,
                searchText: $searchText,
                searchPrompt: "Search lists"
            )
            .overlay(
                Group {
                    if settingsManager.restrictSearchToLocality && !searchText.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(DesignSystem.Colors.info)
                                Text("Search restricted to local area")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                }
            )
            .sheet(isPresented: $showingAddList) {
                AddListView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingSortPicker) {
                SortPickerView(sortOrder: $sortOrder)
            }
            .sheet(isPresented: $showingPremiumUpgrade) {
                PremiumUpgradeView()
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
    
    private func createCombinedShareContent() -> String {
        var content = "🛒 My Shopping Lists\n"
        content += "📅 Generated on: \(formatDate(Date()))\n"
        content += "📊 Total Lists: \(sortedLists.count)\n\n"
        
        if sortedLists.isEmpty {
            content += "No shopping lists found.\n"
        } else {
            for (index, list) in sortedLists.enumerated() {
                content += "\(index + 1). \(list.name)\n"
                content += "   📊 Category: \(list.category.rawValue)\n"
                content += "   📋 Items: \(list.items.count) total, \(list.completedItems.count) completed\n"
                
                if let budget = list.budget {
                    content += "   💰 Budget: \(settingsManager.currency.symbol)\(String(format: "%.2f", budget))\n"
                    content += "   💳 Estimated: \(settingsManager.currency.symbol)\(String(format: "%.2f", list.totalEstimatedCost))\n"
                }
                
                if let location = list.location {
                    content += "   📍 Store: \(location.name)\n"
                }
                
                content += "\n"
            }
        }
        
        content += "---\n"
        content += "Shared from ShopList App"
        
        return content
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    
    private var cardGradient: LinearGradient {
        DesignSystem.Colors.cardBackground(for: list.category)
    }
    
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [
                list.category.color,
                list.category.color.opacity(0.8),
                list.category.color.opacity(0.6)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Enhanced Header with colorful category badge
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(list.name)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .strikethrough(list.items.allSatisfy { $0.isCompleted })
                    .foregroundColor(list.items.allSatisfy { $0.isCompleted } ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                
                // Enhanced Category Badge with gradient and more prominence
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: list.category.icon)
                        .font(.caption2)
                        .foregroundColor(.white)
                    Text(list.category.rawValue)
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)  // Increased padding
                .padding(.vertical, DesignSystem.Spacing.sm)    // Increased padding
                .background(
                    DesignSystem.Colors.categoryGradient(for: list.category)
                )
                .cornerRadius(DesignSystem.CornerRadius.md)  // Increased corner radius
                .shadow(
                    color: list.category.color.opacity(0.4),  // Increased shadow opacity
                    radius: 4,  // Increased shadow radius
                    x: 0,
                    y: 2
                )
            }
            
            Spacer(minLength: DesignSystem.Spacing.xs)
            
            // Enhanced progress bar with gradient and more distinct colors
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
                            // Enhanced background track with more contrast
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(DesignSystem.Colors.tertiaryBackground)
                                .frame(height: 10)  // Increased height
                            
                            // Enhanced progress fill with gradient and more distinct colors
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(progressGradient)
                                .frame(width: geometry.size.width * completionPercentage, height: 10)
                                .animation(DesignSystem.Animations.standard, value: completionPercentage)
                                .shadow(
                                    color: list.category.color.opacity(0.5),  // Increased shadow opacity
                                    radius: 3,  // Increased shadow radius
                                    x: 0,
                                    y: 2
                                )
                        }
                    }
                    .frame(height: 10)
                }
            }
            
            // Enhanced footer with more colorful and distinct icons
            HStack(spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "cart.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(5)  // Increased padding
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.info)
                        )
                        .shadow(
                            color: DesignSystem.Colors.info.opacity(0.4),
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                    Text("\(list.pendingItems.count)")
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                if list.budget != nil {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: isOverBudget ? "exclamationmark.circle.fill" : settingsManager.currency.icon)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(5)  // Increased padding
                            .background(
                                Circle()
                                    .fill(isOverBudget ? DesignSystem.Colors.error : DesignSystem.Colors.success)
                            )
                            .shadow(
                                color: (isOverBudget ? DesignSystem.Colors.error : DesignSystem.Colors.success).opacity(0.4),
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                        Text(settingsManager.currency.symbol + String(format: "%.0f", list.totalEstimatedCost))
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(isOverBudget ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)  // Increased padding
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)  // Increased corner radius
                .fill(cardGradient)
                .shadow(
                    color: DesignSystem.Shadows.colorfulMedium.color,
                    radius: DesignSystem.Shadows.colorfulMedium.radius,
                    x: DesignSystem.Shadows.colorfulMedium.x,
                    y: DesignSystem.Shadows.colorfulMedium.y
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .stroke(list.category.color.opacity(0.25), lineWidth: 1.5)  // Increased border opacity and width
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ShoppingList.self, inMemory: true)
        .environmentObject(SubscriptionManager.shared)
} 