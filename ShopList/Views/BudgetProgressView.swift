import SwiftUI

struct BudgetProgressView: View {
    @Environment(\.colorScheme) private var colorScheme
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
    
    private var adaptiveBackground: Color {
        colorScheme == .dark
            ? Color(.secondarySystemBackground).opacity(0.92)
            : Color(.secondarySystemBackground).opacity(0.98)
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Budget Progress")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(DesignSystem.Typography.subheadlineBold)
                    .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
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
                        .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                    Text(spent, format: .currency(code: currency.rawValue))
                        .font(DesignSystem.Typography.subheadlineBold)
                        .foregroundColor(DesignSystem.Colors.adaptiveTextColor())
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                    Text("Remaining")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
                    Text(remaining, format: .currency(code: currency.rawValue))
                        .font(DesignSystem.Typography.subheadlineBold)
                        .foregroundColor(remaining > 0 ? DesignSystem.Colors.adaptiveTextColor() : DesignSystem.Colors.error)
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(adaptiveBackground)
                .shadow(color: DesignSystem.Colors.primary.opacity(0.10), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(DesignSystem.Colors.primary.opacity(0.18), lineWidth: 1.5)
        )
    }
} 