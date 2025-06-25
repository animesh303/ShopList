import SwiftUI
import SwiftData

struct ItemRow: View {
    @Environment(\.modelContext) private var modelContext
    let item: Item
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    private var priorityIcon: String {
        switch item.priority {
        case .low:
            return "arrow.down.circle"
        case .normal:
            return "circle"
        case .high:
            return "exclamationmark.circle"
        }
    }
    
    private var priorityColor: Color {
        switch item.priority {
        case .low:
            return DesignSystem.Colors.secondaryText
        case .normal:
            return DesignSystem.Colors.primary
        case .high:
            return DesignSystem.Colors.error
        }
    }
    
    var body: some View {
        Group {
            if settingsManager.defaultItemViewStyle == .compact {
                compactView
            } else {
                detailedView
            }
        }
    }
    
    // MARK: - Compact View
    private var compactView: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            Button(action: toggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText)
                    .scaleEffect(item.isCompleted ? 1.1 : 1.0)
                    .animation(DesignSystem.Animations.spring, value: item.isCompleted)
            }
            .buttonStyle(.plain)
            
            // Enhanced Category Icon
            Image(systemName: item.category.icon)
                .font(.title3)
                .foregroundColor(item.category.color)
                .frame(width: 32, height: 32)
                .background(
                    LinearGradient(
                        colors: [item.category.color.opacity(0.2), item.category.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm))
            
            // Item Name and Brand with enhanced typography
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(item.name)
                        .font(DesignSystem.Typography.body)
                        .fontWeight(.medium)
                        .strikethrough(item.isCompleted)
                        .lineLimit(1)
                    
                    if let brand = item.brand, !brand.isEmpty {
                        Text("•")
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                            .font(DesignSystem.Typography.caption1)
                        Text(brand)
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                            .lineLimit(1)
                    }
                }
                
                // Quantity and Price with enhanced styling
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if item.quantity > 0 {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "number.circle.fill")
                                .font(.caption2)
                                .foregroundColor(DesignSystem.Colors.info)
                            Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                                .font(DesignSystem.Typography.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                    
                    if let price = item.estimatedPrice, price > 0 {
                        if item.quantity > 0 {
                            Text("•")
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                                .font(DesignSystem.Typography.caption2)
                        }
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption2)
                                .foregroundColor(DesignSystem.Colors.success)
                            Text(price, format: .currency(code: settingsManager.currency.rawValue))
                                .font(DesignSystem.Typography.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Enhanced Priority indicator
            if item.priority != .normal {
                Image(systemName: priorityIcon)
                    .foregroundColor(priorityColor)
                    .font(.caption)
                    .padding(DesignSystem.Spacing.xs)
                    .background(priorityColor.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.xs)
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
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
    
    // MARK: - Detailed View
    private var detailedView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header with completion button and item name
            HStack(spacing: DesignSystem.Spacing.md) {
                Button(action: toggleCompletion) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(item.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText)
                        .scaleEffect(item.isCompleted ? 1.1 : 1.0)
                        .animation(DesignSystem.Animations.spring, value: item.isCompleted)
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(item.name)
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .strikethrough(item.isCompleted)
                        .lineLimit(2)
                        .foregroundColor(item.isCompleted ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                    
                    if let brand = item.brand, !brand.isEmpty {
                        Text(brand)
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Priority indicator
                if item.priority != .normal {
                    Image(systemName: priorityIcon)
                        .foregroundColor(priorityColor)
                        .font(.title3)
                        .padding(DesignSystem.Spacing.sm)
                        .background(priorityColor.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            // Notes section
            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .lineLimit(3)
                    .padding(.leading, DesignSystem.Spacing.xxxl)
            }
            
            // Category and priority badges
            HStack(spacing: DesignSystem.Spacing.xs) {
                // Category badge with icon
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: item.category.icon)
                        .font(.caption2)
                        .foregroundColor(item.category.color)
                    Text(item.category.rawValue)
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(item.category.color)
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(item.category.color.opacity(0.15))
                .cornerRadius(DesignSystem.CornerRadius.xs)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                
                // Priority badge
                if item.priority != .normal {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: priorityIcon)
                            .font(.caption2)
                            .foregroundColor(priorityColor)
                        Text(item.priority.displayName)
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(priorityColor)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(priorityColor.opacity(0.15))
                    .cornerRadius(DesignSystem.CornerRadius.xs)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                }
                
                Spacer()
            }
            
            // Quantity and price info
            HStack(spacing: DesignSystem.Spacing.md) {
                if item.quantity > 0 {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "number.circle.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.info)
                        Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                
                if let price = item.estimatedPrice, price > 0 {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.success)
                        Text(price, format: .currency(code: settingsManager.currency.rawValue))
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.background)
                .shadow(
                    color: DesignSystem.Shadows.small.color,
                    radius: DesignSystem.Shadows.small.radius,
                    x: DesignSystem.Shadows.small.x,
                    y: DesignSystem.Shadows.small.y
                )
        )
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
    
    private func toggleCompletion() {
        item.isCompleted.toggle()
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("ItemRow Design System Preview")
            .font(DesignSystem.Typography.headline)
            .padding(.top)
        
        // Show design system colors
        HStack(spacing: 16) {
            Circle()
                .fill(DesignSystem.Colors.success)
                .frame(width: 30, height: 30)
            Circle()
                .fill(DesignSystem.Colors.error)
                .frame(width: 30, height: 30)
            Circle()
                .fill(DesignSystem.Colors.warning)
                .frame(width: 30, height: 30)
            Circle()
                .fill(DesignSystem.Colors.info)
                .frame(width: 30, height: 30)
        }
        
        // Show typography
        VStack(alignment: .leading, spacing: 8) {
            Text("Typography Examples")
                .font(DesignSystem.Typography.title2)
            Text("Body text example")
                .font(DesignSystem.Typography.body)
            Text("Caption text example")
                .font(DesignSystem.Typography.caption1)
        }
        
        // Show spacing
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Spacing Examples")
                .font(DesignSystem.Typography.subheadlineBold)
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                Rectangle()
                    .fill(DesignSystem.Colors.primary)
                    .frame(width: 20, height: 20)
                Rectangle()
                    .fill(DesignSystem.Colors.primary)
                    .frame(width: 20, height: 20)
            }
        }
        
        Spacer()
    }
    .padding()
} 