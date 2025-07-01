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
        let checkboxWidth: CGFloat = 28
        let imageWidth: CGFloat = 40
        let priorityWidth: CGFloat = 28
        return VStack(alignment: .leading, spacing: 2) {
            // Top row: Checkbox | Image | Name | Priority
            HStack(spacing: DesignSystem.Spacing.xs) {
                // Checkbox
                Button(action: toggleCompletion) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(item.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText)
                        .frame(width: checkboxWidth, height: checkboxWidth)
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
                                .frame(width: imageWidth, height: imageWidth)
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                                    .fill(LinearGradient(
                                        colors: [item.category.color.opacity(0.1), item.category.color.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: imageWidth, height: imageWidth)
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
                            .frame(width: imageWidth, height: imageWidth)
                            .background(DesignSystem.Colors.categoryGradient(for: item.category))
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
                    }
                }
                // Name (single line)
                Text(item.name)
                    .font(DesignSystem.Typography.body)
                    .fontWeight(.medium)
                    .strikethrough(item.isCompleted)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(item.isCompleted ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // Priority
                if item.priority != .normal {
                    Image(systemName: priorityIcon)
                        .foregroundColor(.white)
                        .font(.caption)
                        .frame(width: priorityWidth, height: priorityWidth)
                        .background(
                            LinearGradient(
                                colors: [priorityColor, priorityColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                } else {
                    Spacer().frame(width: priorityWidth)
                }
            }
            // Bottom row: Quantity (left) | Cost (right)
            HStack(spacing: DesignSystem.Spacing.xs) {
                Spacer().frame(width: checkboxWidth)
                Spacer().frame(width: imageWidth)
                if item.quantity > 0 {
                    Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity * 0.25, alignment: .leading)
                }
                if let price = item.pricePerUnit, price > 0 {
                    Text(price, format: .currency(code: settingsManager.currency.rawValue))
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                Spacer().frame(width: priorityWidth)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.cardBackground(for: item.category))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(item.category.color.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 1)
    }
    
    // MARK: - Detailed View
    private var detailedView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
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
                
                // Item Image (Premium Feature)
                if subscriptionManager.canUseItemImages() && settingsManager.showItemImagesByDefault {
                    if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm))
                            .shadow(
                                color: DesignSystem.Shadows.colorfulSmall.color,
                                radius: DesignSystem.Shadows.colorfulSmall.radius,
                                x: DesignSystem.Shadows.colorfulSmall.x,
                                y: DesignSystem.Shadows.colorfulSmall.y
                            )
                    } else {
                        // Enhanced placeholder for items without images
                        ZStack {
                            // Background with subtle gradient
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            item.category.color.opacity(0.1),
                                            item.category.color.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            // Category icon with gradient background
                            Image(systemName: item.category.icon)
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    DesignSystem.Colors.categoryGradient(for: item.category)
                                )
                                .clipShape(Circle())
                                .shadow(
                                    color: item.category.color.opacity(0.3),
                                    radius: 3,
                                    x: 0,
                                    y: 2
                                )
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(item.name)
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .strikethrough(item.isCompleted)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(item.isCompleted ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                    
                    if let brand = item.brand, !brand.isEmpty {
                        Text(brand)
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .lineLimit(1)
                    }
                    // Category badge row, left-aligned
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
                        .background(
                            DesignSystem.Colors.categoryGradient(for: item.category)
                        )
                        .cornerRadius(DesignSystem.CornerRadius.sm)
                        .shadow(
                            color: item.category.color.opacity(0.3),
                            radius: 3,
                            x: 0,
                            y: 1
                        )
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                }
                
                Spacer()
                
                // VStack for right-aligned badges (priority only)
                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                    // Priority badge (icon + label) at the right (if present)
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
                                colors: [
                                    priorityColor,
                                    priorityColor.opacity(0.8)
                                ],
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
            
            // Enhanced Quantity and price info with colorful icons
            HStack(spacing: DesignSystem.Spacing.lg) {
                if item.quantity > 0 {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "number.circle.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.info)
                            )
                        Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                            .font(.body)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                
                Spacer()
                
                if let price = item.pricePerUnit, price > 0 {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: settingsManager.currency.icon)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.success)
                            )
                        Text(price, format: .currency(code: settingsManager.currency.rawValue))
                            .font(.body)
                            .foregroundColor(.green)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(Color.green.opacity(0.1))
                    )
                }
            }
            
            // Notes section - Enhanced styling
            if let notes = item.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "note.text")
                            .font(.body)
                            .foregroundColor(DesignSystem.Colors.primary)
                        Text("Notes")
                            .font(DesignSystem.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    Text(notes)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(Color.blue.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1.5)
                        )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
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
