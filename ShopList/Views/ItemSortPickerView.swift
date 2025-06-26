import SwiftUI

struct ItemSortPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sortOrder: ListSortOrder
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.largeTitle)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text("Sort Items")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Text("Choose how to organize items in this list")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DesignSystem.Spacing.xl)
                    
                    // Sort Options
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(ListSortOrder.allCases, id: \.self) { order in
                            ItemSortOptionRow(order: order, selectedOrder: sortOrder) {
                                sortOrder = order
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    Spacer()
                }
            }
            .enhancedNavigation(
                title: "Sort Items",
                subtitle: "Organize your list items",
                icon: "arrow.up.arrow.down",
                style: .info,
                showBanner: true
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
}

// MARK: - Item Sort Option Row
struct ItemSortOptionRow: View {
    let order: ListSortOrder
    let selectedOrder: ListSortOrder
    let action: () -> Void
    
    private var isSelected: Bool {
        order == selectedOrder
    }
    
    private var backgroundColor: Color {
        isSelected ? DesignSystem.Colors.success.opacity(0.1) : Color.clear
    }
    
    private var borderColor: Color {
        isSelected ? DesignSystem.Colors.success : DesignSystem.Colors.borderLight
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(order.displayName)
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text(order.description)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.success)
                        .font(.title3)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct ItemSortPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ItemSortPickerView(sortOrder: .constant(.dateDesc))
    }
} 