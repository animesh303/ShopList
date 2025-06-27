import SwiftUI

struct UpgradePromptView: View {
    let feature: PremiumFeature
    let onUpgrade: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: feature.icon)
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Title
            Text("Premium Feature")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            // Feature name
            Text(feature.rawValue)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.accent1)
            
            // Description
            Text(feature.description)
                .font(.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Upgrade message
            Text("Upgrade to Premium to unlock this feature and many more!")
                .font(.subheadline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Action buttons
            VStack(spacing: 12) {
                Button {
                    onUpgrade()
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                        Text("Upgrade to Premium")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                
                Button {
                    onCancel()
                } label: {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            .padding(.horizontal)
        }
        .padding(30)
        .background(DesignSystem.Colors.cardGradient)
        .cornerRadius(20)
        .shadow(
            color: DesignSystem.Shadows.colorfulLarge.color,
            radius: DesignSystem.Shadows.colorfulLarge.radius,
            x: DesignSystem.Shadows.colorfulLarge.x,
            y: DesignSystem.Shadows.colorfulLarge.y
        )
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.backgroundGradient
            .ignoresSafeArea()
        
        UpgradePromptView(
            feature: .locationReminders,
            onUpgrade: { print("Upgrade tapped") },
            onCancel: { print("Cancel tapped") }
        )
        .padding()
    }
} 