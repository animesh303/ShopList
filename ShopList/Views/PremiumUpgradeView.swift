import SwiftUI
import StoreKit

struct PremiumUpgradeView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedProduct: Any?
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                    .padding(.bottom, 100) // Extra padding for FAB
                }
                .background(enhancedBackgroundGradient)
                .navigationTitle("Upgrade to Premium")
                .navigationBarTitleDisplayMode(.large)
                
                // Floating Action Button (FAB) for Close
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.3, green: 0.3, blue: 0.4),
                                                    Color(red: 0.2, green: 0.2, blue: 0.3),
                                                    Color(red: 0.1, green: 0.1, blue: 0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
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
    
    // Enhanced background gradient with more contrast
    private var enhancedBackgroundGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.9, green: 0.95, blue: 1.0),
                    Color(red: 0.85, green: 0.92, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Enhanced premium icon with more vibrant gradient
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.0), // Bright gold
                            Color(red: 1.0, green: 0.6, blue: 0.0), // Orange
                            Color(red: 0.9, green: 0.4, blue: 0.1)  // Red-orange
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.6), radius: 15, x: 0, y: 8)
                .shadow(color: Color(red: 0.9, green: 0.4, blue: 0.1).opacity(0.4), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text("Unlock Premium Features")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primaryText,
                                DesignSystem.Colors.accent1
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Get unlimited lists, location reminders, widgets, item images, and much more!")
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
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.primaryText,
                            DesignSystem.Colors.accent1
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Custom grid layout to center the last item when alone
            let features = Array(PremiumFeature.allCases)
        
            
            VStack(spacing: 16) {
                ForEach(0..<(features.count + 1) / 2, id: \.self) { row in
                    let startIndex = row * 2
                    let endIndex = min(startIndex + 2, features.count)
                    let rowFeatures = Array(features[startIndex..<endIndex])
                    
                    if rowFeatures.count == 1 && row == (features.count + 1) / 2 - 1 {
                        // Last row with only one item - center it
                        HStack {
                            Spacer()
                            FeatureCard(feature: rowFeatures[0])
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                    } else {
                        // Normal row with two items
                        HStack(spacing: 16) {
                            ForEach(rowFeatures, id: \.self) { feature in
                                FeatureCard(feature: feature)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // Add empty space if only one item in this row
                            if rowFeatures.count == 1 {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.primaryText,
                            DesignSystem.Colors.accent1
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
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
                .background(enhancedCardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
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
    
    // Enhanced card background with more contrast
    private var enhancedCardBackground: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.2),
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.97, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Enhanced subscribe button with more vibrant gradient
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
                        colors: [
                            Color(red: 1.0, green: 0.7, blue: 0.0), // Bright gold
                            Color(red: 1.0, green: 0.5, blue: 0.0), // Orange
                            Color(red: 0.9, green: 0.3, blue: 0.1)  // Red-orange
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.5), radius: 12, x: 0, y: 6)
                .shadow(color: Color(red: 0.9, green: 0.3, blue: 0.1).opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .disabled(selectedProduct == nil || subscriptionManager.isLoading)
            .opacity(selectedProduct == nil ? 0.6 : 1.0)
            
            // Enhanced mock subscribe button
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
                        colors: [
                            Color(red: 0.8, green: 0.3, blue: 0.9), // Bright purple
                            Color(red: 0.6, green: 0.2, blue: 0.8), // Dark purple
                            Color(red: 0.4, green: 0.1, blue: 0.7)  // Deep purple
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.5), radius: 10, x: 0, y: 5)
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.accent1,
                                    DesignSystem.Colors.accent1.opacity(0.8),
                                    DesignSystem.Colors.accent1.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: DesignSystem.Colors.accent1.opacity(0.4), radius: 6, x: 0, y: 3)
            
            VStack(spacing: 4) {
                Text(feature.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minWidth: 140, maxWidth: 180, minHeight: 120)
        .padding(16)
        .background(enhancedFeatureCardBackground)
        .cornerRadius(12)
        .shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.15),
            radius: 12,
            x: 0,
            y: 6
        )
        .shadow(
            color: DesignSystem.Colors.accent1.opacity(0.2),
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    // Enhanced feature card background with more contrast
    private var enhancedFeatureCardBackground: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.2, blue: 0.25),
                    Color(red: 0.15, green: 0.15, blue: 0.2),
                    Color(red: 0.1, green: 0.1, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.92, green: 0.95, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct PricingCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
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
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.9, blue: 0.4),
                                            Color(red: 0.1, green: 0.8, blue: 0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(8)
                                .shadow(color: Color(red: 0.2, green: 0.9, blue: 0.4).opacity(0.4), radius: 3, x: 0, y: 2)
                        }
                    }
                    
                    Text(product.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.accent1,
                                    DesignSystem.Colors.accent1.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? DesignSystem.Colors.accent1 : DesignSystem.Colors.tertiaryText)
                    .shadow(color: isSelected ? DesignSystem.Colors.accent1.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(enhancedPricingCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? 
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.accent1,
                                        DesignSystem.Colors.accent1.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    colors: [Color.clear, Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(
                color: isSelected ? 
                DesignSystem.Colors.accent1.opacity(0.3) : 
                (colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1)),
                radius: isSelected ? 12 : 8,
                x: 0,
                y: isSelected ? 6 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Enhanced pricing card background with more contrast
    private var enhancedPricingCardBackground: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.18, blue: 0.23),
                    Color(red: 0.12, green: 0.12, blue: 0.17),
                    Color(red: 0.08, green: 0.08, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.99, green: 0.99, blue: 1.0),
                    Color(red: 0.97, green: 0.98, blue: 1.0),
                    Color(red: 0.94, green: 0.96, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
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
    @Environment(\.colorScheme) private var colorScheme
    
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
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.9, blue: 0.4),
                                            Color(red: 0.1, green: 0.8, blue: 0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(8)
                                .shadow(color: Color(red: 0.2, green: 0.9, blue: 0.4).opacity(0.4), radius: 3, x: 0, y: 2)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(price)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.accent1,
                                        DesignSystem.Colors.accent1.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(period)
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? DesignSystem.Colors.accent1 : DesignSystem.Colors.tertiaryText)
                    .shadow(color: isSelected ? DesignSystem.Colors.accent1.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(enhancedMockCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? 
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.accent1,
                                        DesignSystem.Colors.accent1.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    colors: [Color.clear, Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(
                color: isSelected ? 
                DesignSystem.Colors.accent1.opacity(0.3) : 
                (colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1)),
                radius: isSelected ? 12 : 8,
                x: 0,
                y: isSelected ? 6 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Enhanced mock card background with more contrast
    private var enhancedMockCardBackground: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.18, blue: 0.23),
                    Color(red: 0.12, green: 0.12, blue: 0.17),
                    Color(red: 0.08, green: 0.08, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.99, green: 0.99, blue: 1.0),
                    Color(red: 0.97, green: 0.98, blue: 1.0),
                    Color(red: 0.94, green: 0.96, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
} 
