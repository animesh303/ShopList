import SwiftUI
import SwiftData

struct ItemRow: View {
    @Environment(\.modelContext) private var modelContext
    let item: Item
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
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
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Main content row
            HStack(spacing: DesignSystem.Spacing.md) {
                // Completion button
                Button(action: toggleCompletion) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(item.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText)
                        .scaleEffect(item.isCompleted ? 1.1 : 1.0)
                        .animation(DesignSystem.Animations.spring, value: item.isCompleted)
                }
                .buttonStyle(.plain)
                
                // Item Image or Category Icon
                Group {
                    if subscriptionManager.canUseItemImages() && settingsManager.showItemImagesByDefault {
                        if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
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
                                    .frame(width: 44, height: 44)
                                
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
                                        radius: 2,
                                        x: 0,
                                        y: 1
                                    )
                            }
                        }
                    } else {
                        // Category icon when images are disabled
                        Image(systemName: item.category.icon)
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                DesignSystem.Colors.categoryGradient(for: item.category)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm))
                            .shadow(
                                color: item.category.color.opacity(0.4),
                                radius: 4,
                                x: 0,
                                y: 2
                            )
                    }
                }
                
                // Item name and brand
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text(item.name)
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.medium)
                            .strikethrough(item.isCompleted)
                            .lineLimit(1)
                            .foregroundColor(item.isCompleted ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                        
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
                }
                
                Spacer()
                
                // Priority indicator
                if item.priority != .normal {
                    Image(systemName: priorityIcon)
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(DesignSystem.Spacing.sm)
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
                        .clipShape(Circle())
                        .shadow(
                            color: priorityColor.opacity(0.4),
                            radius: 3,
                            x: 0,
                            y: 1
                        )
                }
            }
            
            // Quantity and Price Details Row
            if item.quantity > 0 || (item.pricePerUnit ?? 0) > 0 {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Spacer to align with content above
                    Spacer()
                        .frame(width: 44 + DesignSystem.Spacing.md) // Match button + image width + spacing
                    
                    // Quantity and price info with optimized spacing
                    LazyHStack(spacing: DesignSystem.Spacing.lg) {
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
                                    .shadow(
                                        color: DesignSystem.Colors.info.opacity(0.3),
                                        radius: 2,
                                        x: 0,
                                        y: 1
                                    )
                                Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                                    .font(DesignSystem.Typography.caption1)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                            .fixedSize(horizontal: true, vertical: false) // Keep quantity compact
                        }
                        
                        if let price = item.pricePerUnit, price > 0 {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: settingsManager.currency.icon)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(
                                        Circle()
                                            .fill(DesignSystem.Colors.success)
                                    )
                                    .shadow(
                                        color: DesignSystem.Colors.success.opacity(0.3),
                                        radius: 2,
                                        x: 0,
                                        y: 1
                                    )
                                Text(price, format: .currency(code: settingsManager.currency.rawValue))
                                    .font(DesignSystem.Typography.caption1)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Give price more space
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.cardBackground(for: item.category))
                .shadow(
                    color: DesignSystem.Shadows.colorfulSmall.color,
                    radius: DesignSystem.Shadows.colorfulSmall.radius,
                    x: DesignSystem.Shadows.colorfulSmall.x,
                    y: DesignSystem.Shadows.colorfulSmall.y
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(item.category.color.opacity(0.15), lineWidth: 1)
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
                
                // Enhanced Priority indicator with gradient
                if item.priority != .normal {
                    Image(systemName: priorityIcon)
                        .foregroundColor(.white)
                        .font(.title3)
                        .padding(DesignSystem.Spacing.sm)
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
                        .clipShape(Circle())
                        .shadow(
                            color: priorityColor.opacity(0.3),
                            radius: 3,
                            x: 0,
                            y: 1
                        )
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
            
            // Enhanced Category and priority badges with gradients
            HStack(spacing: DesignSystem.Spacing.xs) {
                // Enhanced Category badge with gradient
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
                
                // Enhanced Priority badge with gradient
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
                
                Spacer()
            }
            
            // Enhanced Quantity and price info with colorful icons
            LazyHStack(spacing: DesignSystem.Spacing.md) {
                if item.quantity > 0 {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "number.circle.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.info)
                            )
                        Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .fixedSize(horizontal: true, vertical: false) // Keep quantity compact
                }
                
                if let price = item.pricePerUnit, price > 0 {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: settingsManager.currency.icon)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.success)
                            )
                        Text(price, format: .currency(code: settingsManager.currency.rawValue))
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // Give price more space
                }
                
                Spacer()
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