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
    
    private var filteredLists: [ShoppingList] {
        var filtered = lists
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { list in
                list.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply completed lists filter
        if !settingsManager.showCompletedItemsByDefault {
            filtered = filtered.filter { !$0.items.allSatisfy { $0.isCompleted } }
        }
        
        // Apply sorting
        switch sortOrder {
        case .nameAsc:
            filtered.sort { $0.name < $1.name }
        case .nameDesc:
            filtered.sort { $0.name > $1.name }
        case .dateDesc:
            filtered.sort { $0.dateCreated > $1.dateCreated }
        case .dateAsc:
            filtered.sort { $0.dateCreated < $1.dateCreated }
        case .categoryAsc:
            filtered.sort { $0.category.rawValue < $1.category.rawValue }
        case .categoryDesc:
            filtered.sort { $0.category.rawValue > $1.category.rawValue }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredLists) { list in
                    NavigationLink(destination: ListDetailView(list: list)) {
                        ListRow(list: list)
                    }
                }
                .onDelete(perform: deleteLists)
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
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { 
                            if subscriptionManager.canCreateList() {
                                showingAddList = true
                            } else {
                                showingPremiumUpgrade = true
                            }
                        }) {
                            Label("Add List", systemImage: "plus")
                        }
                        
                        Picker("Sort By", selection: $sortOrder) {
                            ForEach(ListSortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                        
                        Toggle("Show Completed", isOn: $settingsManager.showCompletedItemsByDefault)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddList) {
                AddListView()
            }
            .sheet(isPresented: $showingPremiumUpgrade) {
                PremiumUpgradeView()
            }
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
        if completionPercentage == 1.0 {
            return LinearGradient(
                colors: [DesignSystem.Colors.success, DesignSystem.Colors.accent2],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [
                    list.category.color,
                    list.category.color.opacity(0.8),
                    list.category.color.opacity(0.6)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with list name and category badge
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(list.items.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                    
                    // Last modified date as subtitle
                    Text("Updated \(list.lastModified, style: .relative)")
                        .font(.footnote)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                // Category Badge
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
                .background(
                    DesignSystem.Colors.categoryGradient(for: list.category)
                )
                .cornerRadius(12)
                .shadow(
                    color: list.category.color.opacity(0.4),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            }
            
            // Status badges row
            HStack(spacing: 12) {
                // Items count badge
                BadgeView(
                    icon: "cart.fill",
                    text: "\(list.items.count)",
                    color: list.items.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.info,
                    isCompact: true
                )
                
                // Completion status badge
                if !list.items.isEmpty {
                    BadgeView(
                        icon: completionPercentage == 1.0 ? "checkmark.circle.fill" : "circle",
                        text: "\(Int(completionPercentage * 100))%",
                        color: completionPercentage == 1.0 ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText,
                        isCompact: true
                    )
                }
                
                // Budget status badge
                if list.budget != nil {
                    BadgeView(
                        icon: isOverBudget ? "exclamationmark.circle.fill" : settingsManager.currency.icon,
                        text: settingsManager.currency.symbol + String(format: "%.0f", list.totalEstimatedCost),
                        color: isOverBudget ? DesignSystem.Colors.error : DesignSystem.Colors.success,
                        isCompact: true
                    )
                }
                
                // Empty list indicator
                if list.items.isEmpty {
                    BadgeView(
                        icon: "tray",
                        text: "Empty",
                        color: DesignSystem.Colors.tertiaryText,
                        isCompact: true
                    )
                }
                
                Spacer()
            }
            
            // Progress bar for non-empty lists
            if !list.items.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        Spacer()
                        Text("\(list.completedItems.count) of \(list.items.count) completed")
                            .font(.footnote)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DesignSystem.Colors.tertiaryBackground)
                                .frame(height: 12)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 8)
                                .fill(progressGradient)
                                .frame(width: geometry.size.width * completionPercentage, height: 12)
                                .animation(.easeInOut(duration: 0.3), value: completionPercentage)
                                .shadow(
                                    color: (completionPercentage == 1.0 ? DesignSystem.Colors.success : list.category.color).opacity(0.5),
                                    radius: 3,
                                    x: 0,
                                    y: 2
                                )
                        }
                    }
                    .frame(height: 12)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardGradient)
                .shadow(
                    color: DesignSystem.Shadows.colorfulMedium.color,
                    radius: DesignSystem.Shadows.colorfulMedium.radius,
                    x: DesignSystem.Shadows.colorfulMedium.x,
                    y: DesignSystem.Shadows.colorfulMedium.y
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(list.category.color.opacity(list.items.isEmpty ? 0.1 : 0.25), lineWidth: 1.5)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
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
        switch color {
        case DesignSystem.Colors.success:
            return Color.green.opacity(0.9)
        case DesignSystem.Colors.error:
            return Color.red.opacity(0.9)
        case DesignSystem.Colors.info:
            return Color.blue.opacity(0.9)
        case DesignSystem.Colors.tertiaryText:
            return Color.gray.opacity(0.9)
        default:
            return color.opacity(0.9)
        }
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
        // Use white text for better contrast against opaque backgrounds
        return Color.white
    }
    
    var body: some View {
        HStack(spacing: isCompact ? 4 : 6) {
            Image(systemName: icon)
                .font(isCompact ? .caption : .footnote)
                .foregroundColor(.white)
                .padding(isCompact ? 4 : 6)
                .background(
                    Circle()
                        .fill(iconBackgroundColor)
                        .shadow(
                            color: iconBackgroundColor.opacity(0.6),
                            radius: 3,
                            x: 0,
                            y: 2
                        )
                )
            
            Text(text)
                .font(isCompact ? .footnote : .subheadline)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
        }
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 6 : 8)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 12 : 16)
                .fill(badgeBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 12 : 16)
                        .stroke(iconBackgroundColor.opacity(0.3), lineWidth: 1)
                )
                .shadow(
                    color: iconBackgroundColor.opacity(0.2),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    return ShoppingListView()
        .modelContainer(container)
}
