import SwiftUI
import SwiftData

struct ItemRow: View {
    @Environment(\.modelContext) private var modelContext
    let item: Item
    @StateObject private var settingsManager = UserSettingsManager.shared
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
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
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                // Left Column: Checkbox (top), Image (below)
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Button(action: toggleCompletion) {
                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(item.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText)
                            .animation(DesignSystem.Animations.spring, value: item.isCompleted)
                    }
                    .buttonStyle(.plain)
                    
                    // Image or Category Icon
                    Group {
                        if subscriptionManager.canUseItemImages() && settingsManager.showItemImagesByDefault {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                                        .fill(LinearGradient(
                                            colors: [item.category.color.opacity(0.1), item.category.color.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: item.category.icon)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(DesignSystem.Colors.categoryGradient(for: item.category))
                                        .clipShape(Circle())
                                }
                            }
                        } else {
                            Image(systemName: item.category.icon)
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(DesignSystem.Colors.categoryGradient(for: item.category))
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
                        }
                    }
                }
                
                // Right Column: Details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    // Item Name
                    Text(item.name)
                        .font(DesignSystem.Typography.body)
                        .fontWeight(.semibold)
                        .strikethrough(item.isCompleted)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(item.isCompleted ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                    // Brand
                    if let brand = item.brand, !brand.isEmpty {
                        Text(brand)
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.adaptiveTextColor().opacity(0.85))
                            .lineLimit(1)
                    }
                    // Category & Priority Row
                    HStack {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: item.category.icon)
                                .font(.caption2)
                                .foregroundColor(.white)
                            Text(item.category.rawValue)
                                .font(DesignSystem.Typography.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(DesignSystem.Colors.categoryGradient(for: item.category))
                        .cornerRadius(DesignSystem.CornerRadius.sm)
                        .shadow(
                            color: item.category.color.opacity(0.3),
                            radius: 3,
                            x: 0,
                            y: 1
                        )
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        Spacer(minLength: 8)
                        if item.priority != .normal {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: priorityIcon)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                Text(item.priority.displayName)
                                    .font(DesignSystem.Typography.caption1)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, DesignSystem.Spacing.xs)
                            .background(
                                LinearGradient(
                                    colors: [priorityColor, priorityColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(DesignSystem.CornerRadius.sm)
                            .shadow(
                                color: priorityColor.opacity(0.3),
                                radius: 3,
                                x: 0,
                                y: 1
                            )
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
            }
            // Bottom Row: Quantity (left), Cost (right)
            HStack {
                if item.quantity > 0 {
                    Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Spacer()
                if let price = item.pricePerUnit, price > 0 {
                    Text(price, format: .currency(code: settingsManager.currency.rawValue))
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.cardBackground(for: item.category))
                .shadow(
                    color: DesignSystem.Shadows.colorfulSmall.color,
                    radius: DesignSystem.Shadows.colorfulSmall.radius,
                    x: DesignSystem.Shadows.colorfulSmall.x,
                    y: DesignSystem.Shadows.colorfulSmall.y
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(item.category.color.opacity(0.15), lineWidth: 1)
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
