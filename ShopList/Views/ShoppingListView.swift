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
    
    @State private var showingAddList = false
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
                        Button(action: { showingAddList = true }) {
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
                NavigationView {
                    Form {
                        Section {
                            TextField("List Name", text: .constant(""))
                        }
                    }
                    .navigationTitle("New List")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddList = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                // Add list logic here
                                showingAddList = false
                            }
                        }
                    }
                }
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
        VStack(alignment: .leading, spacing: 12) {
            // Enhanced Header with colorful category badge
            HStack(alignment: .center) {
                Text(list.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(list.items.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                
                Spacer()
                
                // Enhanced Category Badge with gradient and more prominence
                HStack(spacing: 6) {
                    Image(systemName: list.category.icon)
                        .font(.caption2)
                        .foregroundColor(.white)
                    Text(list.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)  // Increased padding for more prominence
                .padding(.vertical, 8)     // Increased padding for more prominence
                .background(
                    DesignSystem.Colors.categoryGradient(for: list.category)
                )
                .cornerRadius(12)  // Increased corner radius
                .shadow(
                    color: list.category.color.opacity(0.4),  // Increased shadow opacity
                    radius: 4,  // Increased shadow radius
                    x: 0,
                    y: 2
                )
            }
            
            // Show "Empty List" indicator for lists without items
            if list.items.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                    Text("Empty list")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignSystem.Colors.tertiaryBackground)
                )
            }
            
            // Enhanced progress bar for completion with more distinct colors
            if !list.items.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(Int(completionPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        Spacer()
                        Text("\(list.completedItems.count)/\(list.items.count)")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Enhanced background track with more contrast
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DesignSystem.Colors.tertiaryBackground)
                                .frame(height: 12)  // Increased height
                            
                            // Enhanced progress fill with gradient and more distinct colors
                            RoundedRectangle(cornerRadius: 8)
                                .fill(progressGradient)
                                .frame(width: geometry.size.width * completionPercentage, height: 12)
                                .animation(.easeInOut(duration: 0.3), value: completionPercentage)
                                .shadow(
                                    color: (completionPercentage == 1.0 ? DesignSystem.Colors.success : list.category.color).opacity(0.5),  // Increased shadow opacity
                                    radius: 3,  // Increased shadow radius
                                    x: 0,
                                    y: 2
                                )
                        }
                    }
                    .frame(height: 12)
                }
            }
            
            // Enhanced details row with more colorful and distinct icons
            HStack(spacing: 16) {
                // Items count with enhanced styling and more distinct colors
                HStack(spacing: 6) {
                    Image(systemName: "cart.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)  // Increased padding
                        .background(
                            Circle()
                                .fill(list.items.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.info)
                        )
                        .shadow(
                            color: (list.items.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.info).opacity(0.4),
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                    Text("\(list.items.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(DesignSystem.Colors.secondaryText)
                
                // Completion status with enhanced styling and more distinct colors
                if !list.items.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)  // Increased padding
                            .background(
                                Circle()
                                    .fill(completionPercentage == 1.0 ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText)
                            )
                            .shadow(
                                color: (completionPercentage == 1.0 ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText).opacity(0.4),
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                        Text("\(Int(completionPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(completionPercentage == 1.0 ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText)
                }
                
                // Budget status with enhanced styling and more distinct colors
                if list.budget != nil {
                    HStack(spacing: 6) {
                        Image(systemName: isOverBudget ? "exclamationmark.circle.fill" : "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)  // Increased padding
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
                        Text(settingsManager.currency.symbol + String(format: "%.2f", list.totalEstimatedCost))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(isOverBudget ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                // Last modified date with enhanced styling
                Text(list.lastModified, style: .relative)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
        .padding(.vertical, 16)  // Increased padding
        .padding(.horizontal, 12)  // Increased padding
        .background(
            RoundedRectangle(cornerRadius: 16)  // Increased corner radius
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
                .stroke(list.category.color.opacity(list.items.isEmpty ? 0.1 : 0.25), lineWidth: 1.5)  // Reduced border opacity for empty lists
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)  // Increased vertical padding for better separation
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    return ShoppingListView()
        .modelContainer(container)
}
