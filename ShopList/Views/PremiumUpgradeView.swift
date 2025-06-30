import SwiftUI
import StoreKit

struct PremiumUpgradeView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Any?
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced premium background with animated gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.2, green: 0.1, blue: 0.4),
                        Color(red: 0.1, green: 0.2, blue: 0.5),
                        Color(red: 0.0, green: 0.1, blue: 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated floating particles effect
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...8))
                                .repeatForever(autoreverses: true),
                            value: index
                        )
                }
                
                ScrollView {
                    VStack(spacing: 32) {
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
                    .padding(.top, 40) // Added top padding for icon card
                    .padding(.bottom, 100) // Extra padding for FAB
                }
                
                // Close FAB at bottom
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
                                    LinearGradient(
                                        colors: [
                                            Color.red.opacity(0.8),
                                            Color.red.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(
                                    color: Color.red.opacity(0.4),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
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
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Enhanced premium icon with animated gradient
            ZStack {
                // Glowing background circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.3),
                                Color.yellow.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(1.2)
                
                // Crown icon with enhanced gradient
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.8, blue: 0.0), // Bright gold
                                Color(red: 1.0, green: 0.6, blue: 0.0), // Orange gold
                                Color(red: 0.8, green: 0.4, blue: 0.0)  // Dark gold
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 15, x: 0, y: 8)
                    .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 20)
            
            VStack(spacing: 12) {
                Text("Unlock Premium Features")
                    .font(.custom("Bradley Hand", size: 32, relativeTo: .title))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 1.0, green: 0.9, blue: 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text("Get unlimited lists, location reminders, widgets, item images, and much more!")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Color.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 8)
    }
    
    private var featuresSection: some View {
        VStack(spacing: 20) {
            Text("Premium Features")
                .font(.custom("Bradley Hand", size: 28, relativeTo: .title2))
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 1.0, green: 0.9, blue: 0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
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
        VStack(spacing: 20) {
            Text("Choose Your Plan")
                .font(.custom("Bradley Hand", size: 28, relativeTo: .title2))
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 1.0, green: 0.9, blue: 0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            if subscriptionManager.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
            } else if subscriptionManager.subscriptionProducts.isEmpty {
                // Show message when no products are available
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title)
                        .foregroundColor(Color.orange)
                    
                    Text("Subscription Products Not Available")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("To test subscriptions, you need to configure products in App Store Connect and set up StoreKit testing.")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
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
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
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
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            
            HStack(spacing: 16) {
                Button("Terms of Service") {
                    // Open terms of service
                }
                .font(.caption)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.0),
                            Color(red: 1.0, green: 0.6, blue: 0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                
                Button("Privacy Policy") {
                    // Open privacy policy
                }
                .font(.caption)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.0),
                            Color(red: 1.0, green: 0.6, blue: 0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
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
            // Enhanced icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.3),
                                Color.yellow.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.8, blue: 0.0),
                                Color(red: 1.0, green: 0.6, blue: 0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 4) {
                Text(feature.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minWidth: 140, maxWidth: 180, minHeight: 120)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: Color.orange.opacity(0.2),
            radius: 8,
            x: 0,
            y: 4
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
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                    }
                    
                    Text(product.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.8, blue: 0.0),
                                    Color(red: 1.0, green: 0.6, blue: 0.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.8, blue: 0.0) : Color.white.opacity(0.6))
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isSelected ? 0.2 : 0.1),
                                Color.white.opacity(isSelected ? 0.15 : 0.05),
                                Color.white.opacity(isSelected ? 0.1 : 0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? 
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.8, blue: 0.0),
                                        Color(red: 1.0, green: 0.6, blue: 0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.orange.opacity(0.4) : Color.black.opacity(0.2),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 6 : 3
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
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(price)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.8, blue: 0.0),
                                        Color(red: 1.0, green: 0.6, blue: 0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                        
                        Text(period)
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.8, blue: 0.0) : Color.white.opacity(0.6))
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isSelected ? 0.2 : 0.1),
                                Color.white.opacity(isSelected ? 0.15 : 0.05),
                                Color.white.opacity(isSelected ? 0.1 : 0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? 
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.8, blue: 0.0),
                                        Color(red: 1.0, green: 0.6, blue: 0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.orange.opacity(0.4) : Color.black.opacity(0.2),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 6 : 3
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 
