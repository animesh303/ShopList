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
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    @State private var showingAddList = false
    @State private var showingPremiumUpgrade = false
    @State private var searchText = ""
    @State private var sortOrder: ListSortOrder = .dateDesc
    @State private var showingShareSheet = false
    @State private var listToShare: ShoppingList?
    @State private var showingUpgradePrompt = false
    @State private var upgradePromptMessage = ""
    
    private var filteredLists: [ShoppingList] {
        let searchFiltered = applySearchFilter(lists)
        let completedFiltered = applyCompletedFilter(searchFiltered)
        return applySorting(completedFiltered)
    }
    
    private func applySearchFilter(_ lists: [ShoppingList]) -> [ShoppingList] {
        guard !searchText.isEmpty else { return lists }
        return lists.filter { list in
            list.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func applyCompletedFilter(_ lists: [ShoppingList]) -> [ShoppingList] {
        guard !settingsManager.showCompletedItemsByDefault else { return lists }
        return lists.filter { list in
            !list.items.allSatisfy { $0.isCompleted }
        }
    }
    
    private func applySorting(_ lists: [ShoppingList]) -> [ShoppingList] {
        var sorted = lists
        switch sortOrder {
        case .nameAsc:
            sorted.sort { $0.name < $1.name }
        case .nameDesc:
            sorted.sort { $0.name > $1.name }
        case .dateDesc:
            sorted.sort { $0.dateCreated > $1.dateCreated }
        case .dateAsc:
            sorted.sort { $0.dateCreated < $1.dateCreated }
        case .categoryAsc:
            sorted.sort { $0.category.rawValue < $1.category.rawValue }
        case .categoryDesc:
            sorted.sort { $0.category.rawValue > $1.category.rawValue }
        }
        return sorted
    }
    
    var body: some View {
        NavigationView {
            mainListView
        }
    }
    
    private var mainListView: some View {
        List {
            ForEach(filteredLists) { list in
                listRowView(for: list)
            }
            .onDelete(perform: deleteLists)
        }
        .navigationTitle("Shopping Lists")
        .searchable(text: $searchText, prompt: "Search lists")
        .overlay(searchRestrictionOverlay)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingAddList) {
            AddListView()
        }
        .sheet(isPresented: $showingPremiumUpgrade) {
            PremiumUpgradeView()
        }
        .sheet(isPresented: $showingShareSheet) {
            shareSheetContent
        }
        .alert("Upgrade to Premium", isPresented: $showingUpgradePrompt) {
            Button("Upgrade") {
                showingPremiumUpgrade = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(upgradePromptMessage)
        }
    }
    
    private func listRowView(for list: ShoppingList) -> some View {
        NavigationLink(destination: ListDetailView(list: list)) {
            ListRow(list: list)
        }
        .swipeActions(edge: .trailing) {
            swipeActionButtons(for: list)
        }
    }
    
    @ViewBuilder
    private func swipeActionButtons(for list: ShoppingList) -> some View {
        if subscriptionManager.canUseDataSharing() {
            Button {
                listToShare = list
                showingShareSheet = true
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .tint(.blue)
        } else {
            Button {
                upgradePromptMessage = subscriptionManager.getUpgradePrompt(for: .dataSharing)
                showingUpgradePrompt = true
            } label: {
                Label("Upgrade to Share", systemImage: "crown.fill")
            }
            .tint(.orange)
        }
    }
    
    private var searchRestrictionOverlay: some View {
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
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                addListButton
                sortPicker
                showCompletedToggle
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    private var addListButton: some View {
        Button(action: { 
            if subscriptionManager.canCreateList() {
                showingAddList = true
            } else {
                showingPremiumUpgrade = true
            }
        }) {
            Label("Add List", systemImage: "plus")
        }
    }
    
    private var sortPicker: some View {
        Picker("Sort By", selection: $sortOrder) {
            ForEach(ListSortOrder.allCases, id: \.self) { order in
                Text(order.rawValue).tag(order)
            }
        }
    }
    
    private var showCompletedToggle: some View {
        Toggle("Show Completed", isOn: $settingsManager.showCompletedItemsByDefault)
    }
    
    @ViewBuilder
    private var shareSheetContent: some View {
        if let listToShare = listToShare {
            ShareSheet(
                activityItems: ShoppingListViewModel.shared.getShareableItems(for: listToShare, currency: settingsManager.currency),
                onDismiss: {
                    showingShareSheet = false
                    self.listToShare = nil
                }
            )
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
    @Environment(\.colorScheme) private var colorScheme
    
    private var completionPercentage: Double {
        guard !list.items.isEmpty else { return 0 }
        return Double(list.completedItems.count) / Double(list.items.count)
    }
    
    private var isOverBudget: Bool {
        guard let budget = list.budget else { return false }
        return list.totalEstimatedCost > budget
    }
    
    private var cardGradient: LinearGradient {
        let backgroundColor = Color(.tertiarySystemBackground)
        let colors = [
            backgroundColor,
            backgroundColor.opacity(0.8),
            list.category.color.opacity(0.03)
        ]
        
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var progressGradient: LinearGradient {
        let colors: [Color]
        let startPoint: UnitPoint
        let endPoint: UnitPoint
        
        if completionPercentage == 1.0 {
            colors = [DesignSystem.Colors.success, DesignSystem.Colors.accent2]
        } else {
            colors = [
                list.category.color,
                list.category.color.opacity(0.8),
                list.category.color.opacity(0.6)
            ]
        }
        
        startPoint = .leading
        endPoint = .trailing
        
        return LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    
    private var progressShadowColor: Color {
        return completionPercentage == 1.0 ? DesignSystem.Colors.success : list.category.color
    }
    
    private var cardShadowColor: Color {
        return colorScheme == .dark ? Color.black.opacity(0.7) : Color.black.opacity(0.4)
    }
    
    private var cardBorderColor: Color {
        return colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.15)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            statusBadgesSection
            progressSection
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(cardBackground)
        .overlay(cardBorder)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            headerTextSection
            Spacer()
            categoryBadge
        }
    }
    
    private var headerTextSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(list.name)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .foregroundColor(list.items.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
            
            Text("Updated \(list.lastModified, style: .relative)")
                .font(.footnote)
                .foregroundColor(DesignSystem.Colors.primaryText.opacity(0.7))
        }
    }
    
    private var categoryBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: list.category.icon)
                .font(.caption)
                .foregroundColor(.white)
            Text(list.category.rawValue)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(DesignSystem.Colors.categoryGradient(for: list.category))
        .cornerRadius(12)
        .shadow(
            color: list.category.color.opacity(0.4),
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    private var statusBadgesSection: some View {
        HStack(spacing: 12) {
            itemsCountBadge
            completionBadge
            budgetBadge
            emptyListBadge
            Spacer()
        }
    }
    
    private var itemsCountBadge: some View {
        BadgeView(
            icon: "cart.fill",
            text: "\(list.items.count)",
            color: list.items.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.info,
            isCompact: true
        )
    }
    
    @ViewBuilder
    private var completionBadge: some View {
        if !list.items.isEmpty {
            BadgeView(
                icon: completionPercentage == 1.0 ? "checkmark.circle.fill" : "circle",
                text: "\(Int(completionPercentage * 100))%",
                color: completionPercentage == 1.0 ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText,
                isCompact: true
            )
        }
    }
    
    @ViewBuilder
    private var budgetBadge: some View {
        if list.budget != nil {
            BadgeView(
                icon: isOverBudget ? "exclamationmark.circle.fill" : settingsManager.currency.icon,
                text: settingsManager.currency.symbol + String(format: "%.0f", list.totalEstimatedCost),
                color: isOverBudget ? Color.red.opacity(0.8) : Color(red: 0.1, green: 0.5, blue: 0.1),
                isCompact: true
            )
        }
    }
    
    @ViewBuilder
    private var emptyListBadge: some View {
        if list.items.isEmpty {
            BadgeView(
                icon: "tray",
                text: "Empty",
                color: DesignSystem.Colors.tertiaryText,
                isCompact: true
            )
        }
    }
    
    @ViewBuilder
    private var progressSection: some View {
        if !list.items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                progressHeader
                progressBar
            }
        }
    }
    
    private var progressHeader: some View {
        HStack {
            Text("Progress")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText.opacity(0.8))
            Spacer()
            Text("\(list.completedItems.count) of \(list.items.count) completed")
                .font(.footnote)
                .foregroundColor(DesignSystem.Colors.primaryText.opacity(0.7))
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                progressBackground
                progressFill(geometry: geometry)
            }
        }
        .frame(height: 12)
    }
    
    private var progressBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(DesignSystem.Colors.tertiaryBackground)
            .frame(height: 12)
    }
    
    private func progressFill(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(progressGradient)
            .frame(width: geometry.size.width * completionPercentage, height: 12)
            .animation(.easeInOut(duration: 0.3), value: completionPercentage)
            .shadow(
                color: progressShadowColor.opacity(0.5),
                radius: 3,
                x: 0,
                y: 2
            )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(cardGradient)
            .shadow(
                color: cardShadowColor,
                radius: 16,
                x: 0,
                y: 8
            )
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                cardBorderColor,
                lineWidth: 2.5
            )
    }
}

// Reusable Badge Component
struct BadgeView: View {
    let icon: String
    let text: String
    let color: Color
    let isCompact: Bool
    
    // Enhanced contrasting colors for better visibility
    private var badgeBackgroundColor: Color {
        let baseColor: Color
        switch color {
        case DesignSystem.Colors.success:
            baseColor = Color.green
        case DesignSystem.Colors.error:
            baseColor = Color.red
        case DesignSystem.Colors.info:
            baseColor = Color.blue
        case DesignSystem.Colors.tertiaryText:
            baseColor = Color.gray
        default:
            baseColor = color
        }
        return baseColor.opacity(0.9)
    }
    
    private var iconBackgroundColor: Color {
        switch color {
        case DesignSystem.Colors.success:
            return Color.green
        case DesignSystem.Colors.error:
            return Color.red
        case DesignSystem.Colors.info:
            return Color.blue
        case DesignSystem.Colors.tertiaryText:
            return Color.gray
        default:
            return color
        }
    }
    
    private var textColor: Color {
        return Color.white
    }
    
    private var badgeCornerRadius: CGFloat {
        return isCompact ? 12 : 16
    }
    
    var body: some View {
        HStack(spacing: isCompact ? 4 : 6) {
            iconView
            textView
        }
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 6 : 8)
        .background(badgeBackground)
    }
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(isCompact ? .caption : .footnote)
            .foregroundColor(.white)
            .padding(isCompact ? 4 : 6)
            .background(iconBackground)
    }
    
    private var iconBackground: some View {
        Circle()
            .fill(iconBackgroundColor)
            .shadow(
                color: iconBackgroundColor.opacity(0.6),
                radius: 3,
                x: 0,
                y: 2
            )
    }
    
    private var textView: some View {
        Text(text)
            .font(isCompact ? .footnote : .subheadline)
            .fontWeight(.semibold)
            .foregroundColor(textColor)
    }
    
    private var badgeBackground: some View {
        RoundedRectangle(cornerRadius: badgeCornerRadius)
            .fill(badgeBackgroundColor)
            .overlay(badgeBorder)
            .shadow(
                color: iconBackgroundColor.opacity(0.2),
                radius: 4,
                x: 0,
                y: 2
            )
    }
    
    private var badgeBorder: some View {
        RoundedRectangle(cornerRadius: isCompact ? 12 : 16)
            .stroke(iconBackgroundColor.opacity(0.3), lineWidth: 1)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    return ShoppingListView()
        .modelContainer(container)
}
