import SwiftUI

struct UsageLimitView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showingPremiumUpgrade = false
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                // Expanded view with full details
                expandedView
            } else {
                // Compact view
                compactView
            }
        }
        .background(DesignSystem.Colors.cardGradient)
        .cornerRadius(12)
        .shadow(
            color: DesignSystem.Shadows.colorfulSmall.color,
            radius: DesignSystem.Shadows.colorfulSmall.radius,
            x: DesignSystem.Shadows.colorfulSmall.x,
            y: DesignSystem.Shadows.colorfulSmall.y
        )
        .sheet(isPresented: $showingPremiumUpgrade) {
            PremiumUpgradeView()
                .onAppear {
                    print("PremiumUpgradeView appeared")
                }
        }
        .onChange(of: showingPremiumUpgrade) { _, newValue in
            print("showingPremiumUpgrade changed to: \(newValue)")
        }
    }
    
    private var compactView: some View {
        HStack(spacing: 12) {
            // Icon and title
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.warning)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Free Plan")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text("\(subscriptionManager.getFreeTierUsage().lists)/\(subscriptionManager.getFreeTierUsage().maxLists) lists used")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            
            Spacer()
            
            // Quick upgrade button
            Button {
                print("Upgrade button tapped - showingPremiumUpgrade: \(showingPremiumUpgrade)")
                showingPremiumUpgrade = true
                print("After setting showingPremiumUpgrade: \(showingPremiumUpgrade)")
            } label: {
                Text("Upgrade")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expand button
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
        }
        .padding(12)
    }
    
    private var expandedView: some View {
        VStack(spacing: 16) {
            // Header
            headerSection
            
            // Usage stats
            usageStatsSection
            
            // Upgrade button
            upgradeButtonSection
            
            // Feature comparison
            featureComparisonSection
        }
        .padding(16)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.warning)
                
                Text("Free Plan Usage")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Spacer()
                
                // Collapse button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = false
                    }
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            
            Text("You're using the free version of ShopList. Upgrade to Premium for unlimited features!")
                .font(.subheadline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var usageStatsSection: some View {
        let usage = subscriptionManager.getFreeTierUsage()
        
        return VStack(spacing: 16) {
            // Lists usage
            UsageProgressCard(
                title: "Shopping Lists",
                current: usage.lists,
                max: usage.maxLists,
                icon: "list.bullet",
                color: DesignSystem.Colors.primary
            )
            
            // Notifications usage
            UsageProgressCard(
                title: "Daily Notifications",
                current: usage.notifications,
                max: usage.maxNotifications,
                icon: "bell.fill",
                color: DesignSystem.Colors.accent1
            )
        }
    }
    
    private var upgradeButtonSection: some View {
        Button {
            print("Expanded upgrade button tapped - showingPremiumUpgrade: \(showingPremiumUpgrade)")
            showingPremiumUpgrade = true
            print("After setting showingPremiumUpgrade: \(showingPremiumUpgrade)")
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
    }
    
    private var featureComparisonSection: some View {
        VStack(spacing: 12) {
            Text("What you get with Premium:")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(Array(PremiumFeature.allCases.prefix(6))) { feature in
                    FeatureComparisonRow(feature: feature)
                }
            }
        }
    }
}

struct UsageProgressCard: View {
    let title: String
    let current: Int
    let max: Int
    let icon: String
    let color: Color
    
    private var progress: Double {
        guard max > 0 else { return 0 }
        return min(Double(current) / Double(max), 1.0)
    }
    
    private var progressColor: Color {
        switch progress {
        case 0..<0.7:
            return DesignSystem.Colors.success
        case 0.7..<0.9:
            return DesignSystem.Colors.warning
        default:
            return DesignSystem.Colors.error
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Spacer()
                
                Text("\(current)/\(max)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(progressColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(DesignSystem.Colors.tertiaryBackground)
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [progressColor, progressColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(DesignSystem.Colors.secondaryBackground.opacity(0.5))
        .cornerRadius(8)
    }
}

struct FeatureComparisonRow: View {
    let feature: PremiumFeature
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: feature.icon)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.accent1)
                .frame(width: 16, height: 16)
            
            Text(feature.rawValue)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(1)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.success)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

#Preview {
    UsageLimitView()
        .padding()
        .background(DesignSystem.Colors.backgroundGradient)
} 