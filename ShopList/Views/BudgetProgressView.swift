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
    
    private var progressGradient: LinearGradient {
        switch progress {
        case 0..<0.5:
            return LinearGradient(
                colors: [DesignSystem.Colors.success, DesignSystem.Colors.accent2],
                startPoint: .leading,
                endPoint: .trailing
            )
        case 0.5..<0.8:
            return LinearGradient(
                colors: [DesignSystem.Colors.warning, DesignSystem.Colors.accent1],
                startPoint: .leading,
                endPoint: .trailing
            )
        case 0.8..<1.0:
            return LinearGradient(
                colors: [DesignSystem.Colors.error, DesignSystem.Colors.accent3],
                startPoint: .leading,
                endPoint: .trailing
            )
        default:
            return LinearGradient(
                colors: [DesignSystem.Colors.error, DesignSystem.Colors.accent3],
                startPoint: .leading,
                endPoint: .trailing
            )
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
                        .frame(height: 12)
                        .cornerRadius(DesignSystem.CornerRadius.sm)
                    
                    Rectangle()
                        .fill(progressGradient)
                        .frame(width: geometry.size.width * progress, height: 12)
                        .cornerRadius(DesignSystem.CornerRadius.sm)
                        .animation(DesignSystem.Animations.standard, value: progress)
                        .shadow(
                            color: progressColor.opacity(0.3),
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                }
            }
            .frame(height: 12)
            
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
        .background(DesignSystem.Colors.cardGradient)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .shadow(
            color: DesignSystem.Shadows.colorfulMedium.color,
            radius: DesignSystem.Shadows.colorfulMedium.radius,
            x: DesignSystem.Shadows.colorfulMedium.x,
            y: DesignSystem.Shadows.colorfulMedium.y
        )
    }
} 