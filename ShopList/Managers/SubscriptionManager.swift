import Foundation
import StoreKit
import SwiftUI
import SwiftData

enum SubscriptionError: Error, LocalizedError {
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

@MainActor
class SubscriptionManager: NSObject, ObservableObject {
    private static var _shared: SubscriptionManager?
    
    static var shared: SubscriptionManager {
        if _shared == nil {
            print("SubscriptionManager: Creating new shared instance")
            _shared = SubscriptionManager()
        } else {
            print("SubscriptionManager: Returning existing shared instance")
        }
        return _shared!
    }
    
    @Published var currentTier: SubscriptionTier = .free {
        didSet {
            UserDefaults.standard.set(currentTier.rawValue, forKey: "subscriptionTier")
        }
    }
    @Published var isPremium: Bool = false {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }
    @Published var subscriptionProducts: [Product] = []
    @Published var purchasedProducts: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Free tier limits
    private let maxFreeLists = 3
    private let maxFreeNotifications = 5
    private let freeCategories: [ListCategory] = [.groceries, .household, .personal]
    private let freeItemCategories: [ItemCategory] = [.groceries, .dairy, .bakery, .produce, .meat, .frozenFoods, .beverages, .snacks, .household, .cleaning, .laundry, .kitchen, .bathroom, .personalCare, .beauty, .health, .other]
    
    private var updateListenerTask: Task<Void, Error>?
    private var modelContext: ModelContext?
    
    private override init() {
        super.init()
        
        print("SubscriptionManager: Initializing singleton instance")
        
        // Load persisted subscription status
        loadPersistedSubscriptionStatus()
        
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Persistence
    
    private func loadPersistedSubscriptionStatus() {
        // Load subscription tier
        if let savedTierString = UserDefaults.standard.string(forKey: "subscriptionTier"),
           let savedTier = SubscriptionTier(rawValue: savedTierString) {
            self.currentTier = savedTier
        }
        
        // Load premium status
        let savedIsPremium = UserDefaults.standard.bool(forKey: "isPremium")
        self.isPremium = savedIsPremium
        
        print("SubscriptionManager: Loaded persisted status - Tier: \(currentTier), Premium: \(isPremium)")
    }
    
    // MARK: - Product Management
    
    func loadProducts() async {
        print("SubscriptionManager: Starting to load products")
        isLoading = true
        defer { 
            isLoading = false
            print("SubscriptionManager: Finished loading products. Count: \(subscriptionProducts.count)")
        }
        
        do {
            let productIdentifiers = Set([
                "com.shoplist.premium.monthly",
                "com.shoplist.premium.yearly"
            ])
            
            print("SubscriptionManager: Requesting products for identifiers: \(productIdentifiers)")
            let products = try await Product.products(for: productIdentifiers)
            print("SubscriptionManager: Received \(products.count) products from StoreKit")
            
            subscriptionProducts = products.sorted { $0.price < $1.price }
            
            // If no products were loaded, create mock products for testing
            if subscriptionProducts.isEmpty {
                print("SubscriptionManager: No products loaded, creating mock products for testing")
                subscriptionProducts = createMockProducts()
            }
            
        } catch {
            print("SubscriptionManager: Failed to load products: \(error.localizedDescription)")
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            
            // Create mock products for testing when real products fail
            print("SubscriptionManager: Creating mock products for testing")
            subscriptionProducts = createMockProducts()
        }
    }
    
    private func createMockProducts() -> [Product] {
        // Create mock products for testing
        // In a real app, these would be replaced with actual StoreKit products
        let mockProducts: [Product] = []
        
        // Note: We can't create actual Product instances without StoreKit configuration
        // Instead, we'll show a message that products are not available
        print("SubscriptionManager: Mock products created (empty for now)")
        
        return mockProducts
    }
    
    func purchase(_ product: Product) async throws {
        print("SubscriptionManager: Starting purchase for product: \(product.id)")
        isLoading = true
        defer { 
            isLoading = false
            print("SubscriptionManager: Purchase process completed")
        }
        
        do {
            print("SubscriptionManager: Attempting to purchase product")
            let result = try await product.purchase()
            print("SubscriptionManager: Purchase result received: \(result)")
            
            switch result {
            case .success(_):
                print("SubscriptionManager: Purchase successful")
                await updateSubscriptionStatus()
            case .userCancelled:
                print("SubscriptionManager: Purchase cancelled by user")
                throw SubscriptionError.userCancelled
            case .pending:
                print("SubscriptionManager: Purchase is pending")
                errorMessage = "Purchase is pending"
                throw SubscriptionError.pending
            @unknown default:
                print("SubscriptionManager: Unknown purchase result")
                errorMessage = "Unknown purchase result"
                throw SubscriptionError.unknown
            }
        } catch {
            print("SubscriptionManager: Purchase failed with error: \(error.localizedDescription)")
            errorMessage = "Failed to purchase: \(error.localizedDescription)"
            throw error
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }
    
    /// Force refresh subscription status from StoreKit (ignoring persisted status)
    func forceRefreshSubscriptionStatus() async {
        print("SubscriptionManager: Force refreshing subscription status from StoreKit")
        await updateSubscriptionStatus()
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                await self.handleTransactionResult(result)
            }
        }
    }
    
    private func handleTransactionResult(_ result: VerificationResult<StoreKit.Transaction>) async {
        await updateSubscriptionStatus()
    }
    
    private func updateSubscriptionStatus() async {
        // Check for valid StoreKit transactions
        var foundValidTransaction = false
        
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID.contains("premium") {
                    await MainActor.run {
                        self.currentTier = .premium
                        self.isPremium = true
                        print("SubscriptionManager: Valid premium transaction found - Status updated")
                    }
                    foundValidTransaction = true
                    return
                }
            }
        }
        
        // If no valid StoreKit transactions found, check if we have persisted premium status
        if !foundValidTransaction {
            let persistedIsPremium = UserDefaults.standard.bool(forKey: "isPremium")
            let persistedTierString = UserDefaults.standard.string(forKey: "subscriptionTier")
            
            await MainActor.run {
                if persistedIsPremium && persistedTierString == "Premium" {
                    // Keep the persisted premium status
                    self.currentTier = .premium
                    self.isPremium = true
                    print("SubscriptionManager: No StoreKit transactions found, but keeping persisted premium status")
                } else {
                    // Reset to free only if no persisted premium status
                    self.currentTier = .free
                    self.isPremium = false
                    // Reset premium-only settings when subscription is lost
                    UserSettingsManager.shared.resetPremiumOnlySettings()
                    print("SubscriptionManager: No valid premium transactions found and no persisted premium status - Status reset to free")
                }
            }
        }
    }
    
    // MARK: - Feature Access Control
    
    func canCreateList() -> Bool {
        if isPremium { return true }
        
        // Check if user has reached the free limit
        let currentListsCount = getCurrentListsCount()
        return currentListsCount < maxFreeLists
    }
    
    func canUseCategory(_ category: ListCategory) -> Bool {
        if isPremium { return true }
        return freeCategories.contains(category)
    }
    
    func canUseItemCategory(_ category: ItemCategory) -> Bool {
        if isPremium { return true }
        return freeItemCategories.contains(category)
    }
    
    func canUseLocationReminders() -> Bool {
        return isPremium
    }
    
    func canUseUnlimitedNotifications() -> Bool {
        return isPremium
    }
    

    

    

    
    func canUseBudgetTracking() -> Bool {
        return isPremium
    }
    
    func canUseItemImages() -> Bool {
        return isPremium
    }
    
    func canUseDataSharing() -> Bool {
        return isPremium
    }
    

    
    func getNotificationLimit() -> Int {
        return isPremium ? Int.max : maxFreeNotifications
    }
    
    func getListsLimit() -> Int {
        return isPremium ? Int.max : maxFreeLists
    }
    
    func getAvailableCategories() -> [ListCategory] {
        return isPremium ? ListCategory.allCases : freeCategories
    }
    
    func getAvailableItemCategories() -> [ItemCategory] {
        return isPremium ? ItemCategory.allCases : freeItemCategories
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentListsCount() -> Int {
        guard let modelContext = modelContext else { return 0 }
        
        do {
            let descriptor = FetchDescriptor<ShoppingList>()
            let lists = try modelContext.fetch(descriptor)
            return lists.count
        } catch {
            print("Error fetching lists count: \(error)")
            return 0
        }
    }
    
    func getUpgradePrompt(for feature: PremiumFeature) -> String {
        switch feature {
        case .unlimitedLists:
            return "Upgrade to Premium to create unlimited shopping lists"
        case .allCategories:
            return "Upgrade to Premium to access all 20+ categories"
        case .locationReminders:
            return "Upgrade to Premium to get location-based reminders"
        case .unlimitedNotifications:
            return "Upgrade to Premium for unlimited notifications"
        case .budgetTracking:
            return "Upgrade to Premium to track budgets"
        case .itemImages:
            return "Upgrade to Premium to add photos to items"
        case .dataSharing:
            return "Upgrade to Premium to share and export shopping lists"
        }
    }
    
    func shouldShowUpgradePrompt() -> Bool {
        return !isPremium
    }
    
    func getFreeTierUsage() -> (lists: Int, maxLists: Int, notifications: Int, maxNotifications: Int) {
        let currentLists = getCurrentListsCount()
        let currentNotifications = getCurrentNotificationCount()
        
        return (
            lists: currentLists,
            maxLists: maxFreeLists,
            notifications: currentNotifications,
            maxNotifications: maxFreeNotifications
        )
    }
    
    private func getCurrentNotificationCount() -> Int {
        // Get today's notification count from UserDefaults
        let today = Calendar.current.startOfDay(for: Date())
        let key = "notification_count_\(today.timeIntervalSince1970)"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func incrementNotificationCount() {
        guard !isPremium else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let key = "notification_count_\(today.timeIntervalSince1970)"
        let currentCount = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(currentCount + 1, forKey: key)
    }
    
    func canSendNotification() -> Bool {
        if isPremium { return true }
        
        let currentCount = getCurrentNotificationCount()
        return currentCount < maxFreeNotifications
    }
    
    // MARK: - Premium Feature Checks
    
    func checkListLimit() -> Bool {
        return canCreateList()
    }
    
    func checkCategoryAccess(_ category: ListCategory) -> Bool {
        return canUseCategory(category)
    }
    
    func checkItemCategoryAccess(_ category: ItemCategory) -> Bool {
        return canUseItemCategory(category)
    }
    
    func checkBudgetAccess() -> Bool {
        return canUseBudgetTracking()
    }
    

    
    func checkLocationAccess() -> Bool {
        return canUseLocationReminders()
    }
    

    

    
    func checkImageAccess() -> Bool {
        return canUseItemImages()
    }
    
    func checkDataSharingAccess() -> Bool {
        return canUseDataSharing()
    }
    
    // MARK: - Mock Subscription for Testing
    
    func mockSubscribe() {
        print("SubscriptionManager: Mock subscription activated")
        currentTier = .premium
        isPremium = true
        // Ensure persistence
        UserDefaults.standard.set(currentTier.rawValue, forKey: "subscriptionTier")
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
        print("SubscriptionManager: User is now premium (mock) - Status persisted")
    }
    
    func mockUnsubscribe() {
        print("SubscriptionManager: Mock subscription deactivated")
        currentTier = .free
        isPremium = false
        // Ensure persistence
        UserDefaults.standard.set(currentTier.rawValue, forKey: "subscriptionTier")
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
        // Reset premium-only settings when mock subscription is lost
        UserSettingsManager.shared.resetPremiumOnlySettings()
        print("SubscriptionManager: User is now free (mock) - Status persisted")
    }
    
    func isMockSubscribed() -> Bool {
        return isPremium
    }
    
    /// Clears all persisted subscription data (for testing purposes)
    func clearPersistedSubscriptionData() {
        UserDefaults.standard.removeObject(forKey: "subscriptionTier")
        UserDefaults.standard.removeObject(forKey: "isPremium")
        print("SubscriptionManager: Cleared all persisted subscription data")
    }
    
    /// Debug method to check current persisted status
    func debugPersistedStatus() {
        let persistedIsPremium = UserDefaults.standard.bool(forKey: "isPremium")
        let persistedTierString = UserDefaults.standard.string(forKey: "subscriptionTier")
        print("SubscriptionManager: Debug - Persisted isPremium: \(persistedIsPremium), Tier: \(persistedTierString ?? "nil")")
        print("SubscriptionManager: Debug - Current isPremium: \(isPremium), Tier: \(currentTier)")
    }
}

// MARK: - Product Extensions

extension Product {
    var subscriptionPeriod: SubscriptionPeriod? {
        if subscription?.subscriptionPeriod.unit == .month {
            return .monthly
        } else if subscription?.subscriptionPeriod.unit == .year {
            return .yearly
        }
        return nil
    }
    
    var formattedPrice: String {
        return displayPrice
    }
    
    var isYearly: Bool {
        return subscription?.subscriptionPeriod.unit == .year
    }
    
    var savingsPercentage: Int? {
        guard isYearly else { return nil }
        // Calculate savings compared to monthly
        return 33 // Placeholder - should calculate actual savings
    }
} 