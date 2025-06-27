import SwiftUI
import StoreKit

struct PremiumUpgradeView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Features
                    featuresSection
                    
                    // Pricing
                    pricingSection
                    
                    // Action buttons
                    actionButtonsSection
                    
                    // Terms and privacy
                    termsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(DesignSystem.Colors.backgroundGradient)
            .navigationTitle("Upgrade to Premium")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(subscriptionManager.errorMessage ?? "An error occurred")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Premium icon
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 8) {
                Text("Unlock Premium Features")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("Get unlimited lists, location reminders, widgets, and much more!")
                    .font(.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text("Premium Features")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(PremiumFeature.allCases) { feature in
                    FeatureCard(feature: feature)
                }
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            if subscriptionManager.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                VStack(spacing: 12) {
                    ForEach(subscriptionManager.subscriptionProducts, id: \.id) { product in
                        PricingCard(
                            product: product,
                            isSelected: selectedProduct?.id == product.id
                        ) {
                            selectedProduct = product
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Subscribe button
            Button {
                Task {
                    await subscribe()
                }
            } label: {
                HStack {
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                    }
                    
                    Text(subscriptionManager.isLoading ? "Processing..." : "Subscribe Now")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(selectedProduct == nil || subscriptionManager.isLoading)
            
            // Restore purchases button
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            } label: {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .disabled(subscriptionManager.isLoading)
        }
    }
    
    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.tertiaryText)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button("Terms of Service") {
                    // Open terms of service
                }
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.accent1)
                
                Button("Privacy Policy") {
                    // Open privacy policy
                }
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.accent1)
            }
        }
    }
    
    private func subscribe() async {
        guard let product = selectedProduct else { return }
        
        do {
            try await subscriptionManager.purchase(product)
            if subscriptionManager.isPremium {
                dismiss()
            }
        } catch {
            subscriptionManager.errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

struct FeatureCard: View {
    let feature: PremiumFeature
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(DesignSystem.Colors.accent1)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.accent1.opacity(0.1))
                )
            
            VStack(spacing: 4) {
                Text(feature.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(DesignSystem.Colors.cardGradient)
        .cornerRadius(12)
        .shadow(
            color: DesignSystem.Shadows.colorfulSmall.color,
            radius: DesignSystem.Shadows.colorfulSmall.radius,
            x: DesignSystem.Shadows.colorfulSmall.x,
            y: DesignSystem.Shadows.colorfulSmall.y
        )
    }
}

struct PricingCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void
    
    private var subscriptionPeriodName: String {
        guard let period = product.subscriptionPeriod else { return "Premium" }
        
        switch period.unit {
        case .day:
            return period.value == 1 ? "Daily" : "\(period.value) Days"
        case .week:
            return period.value == 1 ? "Weekly" : "\(period.value) Weeks"
        case .month:
            return period.value == 1 ? "Monthly" : "\(period.value) Months"
        case .year:
            return period.value == 1 ? "Yearly" : "\(period.value) Years"
        @unknown default:
            return "Premium"
        }
    }
    
    private var savings: String? {
        // For yearly subscriptions, we can show a savings badge
        // In a real app, you would compare with monthly pricing
        if let period = product.subscriptionPeriod,
           period.unit == .year {
            return "Best Value"
        }
        return nil
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(subscriptionPeriodName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                    
                    Text(product.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.accent1)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? DesignSystem.Colors.accent1 : DesignSystem.Colors.tertiaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignSystem.Colors.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? DesignSystem.Colors.accent1 : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .shadow(
                color: isSelected ? DesignSystem.Colors.accent1.opacity(0.2) : DesignSystem.Shadows.colorfulSmall.color,
                radius: isSelected ? 8 : DesignSystem.Shadows.colorfulSmall.radius,
                x: 0,
                y: isSelected ? 4 : DesignSystem.Shadows.colorfulSmall.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PremiumUpgradeView()
} 