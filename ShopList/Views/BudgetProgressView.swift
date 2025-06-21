import SwiftUI

struct BudgetProgressView: View {
    let budget: Double
    let spent: Double
    let currency: Currency
    
    private var progress: Double {
        guard budget > 0 else { return 0 }
        return min(spent / budget, 1.0)
    }
    
    private var remaining: Double {
        max(budget - spent, 0)
    }
    
    private var progressColor: Color {
        switch progress {
        case 0..<0.5:
            return DesignSystem.Colors.success
        case 0.5..<0.8:
            return DesignSystem.Colors.warning
        case 0.8..<1.0:
            return DesignSystem.Colors.error.opacity(0.8)
        default:
            return DesignSystem.Colors.error
        }
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Budget Progress")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(DesignSystem.Typography.subheadlineBold)
                    .foregroundColor(progressColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(DesignSystem.Colors.tertiaryBackground)
                        .frame(height: 8)
                        .cornerRadius(DesignSystem.CornerRadius.xs)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(DesignSystem.CornerRadius.xs)
                        .animation(DesignSystem.Animations.standard, value: progress)
                }
            }
            .frame(height: 8)
            
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Spent")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Text(spent, format: .currency(code: currency.rawValue))
                        .font(DesignSystem.Typography.subheadlineBold)
                        .foregroundColor(progressColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                    Text("Remaining")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Text(remaining, format: .currency(code: currency.rawValue))
                        .font(DesignSystem.Typography.subheadlineBold)
                        .foregroundColor(remaining > 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.background)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .shadow(
            color: DesignSystem.Shadows.small.color,
            radius: DesignSystem.Shadows.small.radius,
            x: DesignSystem.Shadows.small.x,
            y: DesignSystem.Shadows.small.y
        )
    }
} 