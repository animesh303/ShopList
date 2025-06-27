import Foundation
import StoreKit
import SwiftUI
import SwiftData

@MainActor
class SubscriptionManager: NSObject, ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var currentTier: SubscriptionTier = .free
    @Published var isPremium: Bool = false
    @Published var subscriptionProducts: [Product] = []
    @Published var purchasedProducts: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Free tier limits
    private let maxFreeLists = 3
    private let maxFreeNotifications = 5
    private let freeCategories: [ListCategory] = [.groceries, .household, .personal]
    
    private var updateListenerTask: Task<Void, Error>?
    private var modelContext: ModelContext?
    
    private override init() {
        super.init()
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
    
    // MARK: - Product Management
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIdentifiers = Set([
                "com.shoplist.premium.monthly",
                "com.shoplist.premium.yearly"
            ])
            
            let products = try await Product.products(for: productIdentifiers)
            subscriptionProducts = products.sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    func purchase(_ product: Product) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(_):
            await updateSubscriptionStatus()
        case .userCancelled:
            break
        case .pending:
            errorMessage = "Purchase is pending"
        @unknown default:
            errorMessage = "Unknown purchase result"
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
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID.contains("premium") {
                    await MainActor.run {
                        self.currentTier = .premium
                        self.isPremium = true
                    }
                    return
                }
            }
        }
        
        await MainActor.run {
            self.currentTier = .free
            self.isPremium = false
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
    
    func canUseLocationReminders() -> Bool {
        return isPremium
    }
    
    func canUseUnlimitedNotifications() -> Bool {
        return isPremium
    }
    
    func canUseWidgets() -> Bool {
        return isPremium
    }
    
    func canUseAppShortcuts() -> Bool {
        return isPremium
    }
    
    func canUseTemplates() -> Bool {
        return isPremium
    }
    
    func canUseBudgetTracking() -> Bool {
        return isPremium
    }
    
    func canUseItemImages() -> Bool {
        return isPremium
    }
    
    func canUseBarcodeScanning() -> Bool {
        return isPremium
    }
    
    func canUseExportImport() -> Bool {
        return isPremium
    }
    
    func canUsePrioritySupport() -> Bool {
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
        case .widgets:
            return "Upgrade to Premium to use home screen widgets"
        case .appShortcuts:
            return "Upgrade to Premium to use Siri shortcuts"
        case .templates:
            return "Upgrade to Premium to save list templates"
        case .budgetTracking:
            return "Upgrade to Premium to track budgets"
        case .itemImages:
            return "Upgrade to Premium to add photos to items"
        case .barcodeScanning:
            return "Upgrade to Premium to scan barcodes"
        case .exportImport:
            return "Upgrade to Premium to export/import data"
        case .prioritySupport:
            return "Upgrade to Premium for priority support"
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
    
    func checkBudgetAccess() -> Bool {
        return canUseBudgetTracking()
    }
    
    func checkTemplateAccess() -> Bool {
        return canUseTemplates()
    }
    
    func checkLocationAccess() -> Bool {
        return canUseLocationReminders()
    }
    
    func checkWidgetAccess() -> Bool {
        return canUseWidgets()
    }
    
    func checkShortcutAccess() -> Bool {
        return canUseAppShortcuts()
    }
    
    func checkImageAccess() -> Bool {
        return canUseItemImages()
    }
    
    func checkBarcodeAccess() -> Bool {
        return canUseBarcodeScanning()
    }
    
    func checkExportAccess() -> Bool {
        return canUseExportImport()
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