import SwiftUI
import StoreKit

struct PremiumUpgradeView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Any?
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
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
            .onAppear {
                print("PremiumUpgradeView appeared - products count: \(subscriptionManager.subscriptionProducts.count)")
                // Auto-select first product if none is selected
                if selectedProduct == nil && !subscriptionManager.subscriptionProducts.isEmpty {
                    selectedProduct = subscriptionManager.subscriptionProducts.first
                    print("Auto-selected product: \(getProductId() ?? "nil")")
                }
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
            } else if subscriptionManager.subscriptionProducts.isEmpty {
                // Show message when no products are available
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title)
                        .foregroundColor(DesignSystem.Colors.warning)
                    
                    Text("Subscription Products Not Available")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text("To test subscriptions, you need to configure products in App Store Connect and set up StoreKit testing.")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    // Show mock pricing cards for demonstration
                    VStack(spacing: 12) {
                        MockPricingCard(
                            title: "Monthly Premium",
                            price: "$4.99",
                            period: "per month",
                            isSelected: isSelectedProduct("mock_monthly")
                        ) {
                            selectedProduct = MockProduct(id: "mock_monthly", price: 4.99)
                        }
                        
                        MockPricingCard(
                            title: "Yearly Premium",
                            price: "$39.99",
                            period: "per year",
                            savings: "Save 33%",
                            isSelected: isSelectedProduct("mock_yearly")
                        ) {
                            selectedProduct = MockProduct(id: "mock_yearly", price: 39.99)
                        }
                    }
                }
                .padding()
                .background(DesignSystem.Colors.secondaryBackground.opacity(0.5))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    ForEach(subscriptionManager.subscriptionProducts, id: \.id) { product in
                        PricingCard(
                            product: product,
                            isSelected: isSelectedProduct(product.id)
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
                print("Subscribe button tapped - selectedProduct: \(getProductId() ?? "nil")")
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
            .opacity(selectedProduct == nil ? 0.6 : 1.0)
            
            // Mock Subscribe Button for Testing
            Button {
                print("Mock subscribe button tapped")
                subscriptionManager.mockSubscribe()
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                        .font(.title3)
                    
                    Text("Mock Subscribe (Testing)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            // Show message if no product is selected
            if selectedProduct == nil && !subscriptionManager.subscriptionProducts.isEmpty {
                Text("Please select a subscription plan above")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
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
        print("Subscribe function called - selectedProduct: \(getProductId() ?? "nil")")
        
        // Auto-select first product if none is selected
        if selectedProduct == nil && !subscriptionManager.subscriptionProducts.isEmpty {
            selectedProduct = subscriptionManager.subscriptionProducts.first
            print("Auto-selected product: \(getProductId() ?? "nil")")
        }
        
        guard let product = selectedProduct else { 
            print("No product selected, cannot subscribe")
            return 
        }
        
        print("Attempting to purchase product: \(getProductId() ?? "nil")")
        
        // Handle mock products differently
        if let mockProduct = product as? MockProduct {
            print("Mock product selected: \(mockProduct.id)")
            // Show a message that this is a demo
            subscriptionManager.errorMessage = "This is a demo. In a real app, this would initiate a StoreKit purchase for \(mockProduct.formattedPrice)."
            showingError = true
            return
        }
        
        // Handle real StoreKit products
        guard let storeKitProduct = product as? Product else {
            print("Invalid product type")
            subscriptionManager.errorMessage = "Invalid product type"
            showingError = true
            return
        }
        
        do {
            try await subscriptionManager.purchase(storeKitProduct)
            print("Purchase completed successfully")
            if subscriptionManager.isPremium {
                print("User is now premium, dismissing view")
                dismiss()
            }
        } catch {
            print("Purchase failed with error: \(error.localizedDescription)")
            subscriptionManager.errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func isSelectedProduct(_ id: String) -> Bool {
        if let product = selectedProduct as? Product {
            return product.id == id
        } else if let mockProduct = selectedProduct as? MockProduct {
            return mockProduct.id == id
        }
        return false
    }
    
    private func getProductId() -> String? {
        if let product = selectedProduct as? Product {
            return product.id
        } else if let mockProduct = selectedProduct as? MockProduct {
            return mockProduct.id
        }
        return nil
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

// MARK: - Mock Product for Testing

struct MockProduct {
    let id: String
    let price: Double
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
}

// MARK: - Mock Pricing Card

struct MockPricingCard: View {
    let title: String
    let price: String
    let period: String
    let savings: String?
    let isSelected: Bool
    let onTap: () -> Void
    
    init(title: String, price: String, period: String, savings: String? = nil, isSelected: Bool, onTap: @escaping () -> Void) {
        self.title = title
        self.price = price
        self.period = period
        self.savings = savings
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
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
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(price)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.accent1)
                        
                        Text(period)
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
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
