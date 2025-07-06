# Item Category Restrictions for Free Users

## Issue Description

Previously, only shopping list categories were restricted for free users, while item categories were available to all users regardless of subscription status. This created an inconsistency in the premium feature model.

## Solution Implemented

### 1. SubscriptionManager Updates

#### Added Free Item Categories

```swift
// Free item categories for non-premium users
private let freeItemCategories: [ItemCategory] = [
    .groceries, .dairy, .bakery, .produce, .meat, .frozenFoods,
    .beverages, .snacks, .household, .cleaning, .laundry,
    .kitchen, .bathroom, .personalCare, .beauty, .health, .other
]
```

#### Added Item Category Access Methods

```swift
// Check if user can use a specific item category
func canUseItemCategory(_ category: ItemCategory) -> Bool {
    if isPremium { return true }
    return freeItemCategories.contains(category)
}

// Get available item categories based on subscription status
func getAvailableItemCategories() -> [ItemCategory] {
    return isPremium ? ItemCategory.allCases : freeItemCategories
}

// Check item category access for validation
func checkItemCategoryAccess(_ category: ItemCategory) -> Bool {
    return canUseItemCategory(category)
}
```

### 2. AddItemView Updates

#### Restricted Category Picker

- **Before**: Shows all `ItemCategory.allCases`
- **After**: Shows only `subscriptionManager.getAvailableItemCategories()`

#### Added Premium Indicator

- Shows crown icon next to "Category" label for free users
- Indicates that some categories are premium-only

#### Added Category Change Validation

```swift
.onChange(of: category) { _, newCategory in
    if !subscriptionManager.canUseItemCategory(newCategory) {
        upgradePromptMessage = subscriptionManager.getUpgradePrompt(for: .allCategories)
        showingUpgradePrompt = true
        // Reset to a free category
        category = subscriptionManager.getAvailableItemCategories().first ?? .other
    }
}
```

### 3. ItemDetailView Updates

Applied the same restrictions as AddItemView:

- Restricted category picker to available categories only
- Added premium indicator
- Added category change validation with upgrade prompt

### 4. UserSettingsManager Updates

#### Default Category Validation

```swift
@Published var defaultItemCategory: ItemCategory {
    didSet {
        // Ensure the default category is always available for free users
        if !SubscriptionManager.shared.canUseItemCategory(defaultItemCategory) {
            // Reset to a free category
            defaultItemCategory = SubscriptionManager.shared.getAvailableItemCategories().first ?? .other
        }
        UserDefaults.standard.set(defaultItemCategory.rawValue, forKey: "defaultItemCategory")
    }
}
```

#### Initialization Protection

```swift
// Ensure the default category is available for free users
if SubscriptionManager.shared.canUseItemCategory(initialCategory) {
    self.defaultItemCategory = initialCategory
} else {
    self.defaultItemCategory = SubscriptionManager.shared.getAvailableItemCategories().first ?? .other
}
```

#### Premium Settings Reset

```swift
func resetPremiumOnlySettings() {
    // Reset showItemImagesByDefault if user doesn't have premium access
    if !SubscriptionManager.shared.canUseItemImages() && showItemImagesByDefault {
        showItemImagesByDefault = false
    }

    // Reset defaultItemCategory if it's not available for free users
    if !SubscriptionManager.shared.canUseItemCategory(defaultItemCategory) {
        defaultItemCategory = SubscriptionManager.shared.getAvailableItemCategories().first ?? .other
    }
}
```

## Free vs Premium Item Categories

### Free Categories (17 categories)

- **Food & Beverages**: groceries, dairy, bakery, produce, meat, frozenFoods, beverages, snacks
- **Household**: household, cleaning, laundry, kitchen, bathroom
- **Personal Care**: personalCare, beauty, health
- **Other**: other

### Premium Categories (8 additional categories)

- **Electronics**: electronics
- **Clothing**: clothing
- **Automotive**: automotive
- **Garden**: garden
- **Baby Care**: babyCare
- **Pet Care**: petCare
- **Office**: office
- **Spices**: spices

## User Experience Flow

### Free User - Adding Item

1. **Open Add Item**: User opens add item view
2. **Category Picker**: Shows only 17 free categories with crown icon
3. **Select Category**: User can select from available categories
4. **Premium Category Attempt**: If somehow a premium category is selected, shows upgrade prompt
5. **Upgrade Flow**: User can upgrade to access all 25 categories

### Premium User - Adding Item

1. **Open Add Item**: User opens add item view
2. **Category Picker**: Shows all 25 categories without crown icon
3. **Select Category**: User can select any category freely

### Category Change Protection

- If a user's subscription expires and they had a premium category selected, it automatically resets to a free category
- Default category settings are protected to always be free categories for free users

## Benefits

1. **Consistent Premium Model**: Item categories now follow the same restriction pattern as list categories
2. **Revenue Opportunity**: Premium categories provide additional value for subscription
3. **User Experience**: Clear visual indicators (crown icons) show what's premium
4. **Data Protection**: Automatic fallback to free categories prevents data corruption
5. **Upgrade Incentive**: Access to 8 additional categories encourages premium subscription

## Testing Scenarios

### ✅ Free User - Item Category Access

1. Create new item
2. Open category picker
3. **Expected**: See only 17 free categories with crown icon
4. **Actual**: See only 17 free categories with crown icon ✅

### ✅ Premium User - Item Category Access

1. Create new item
2. Open category picker
3. **Expected**: See all 25 categories without crown icon
4. **Actual**: See all 25 categories without crown icon ✅

### ✅ Category Change Protection

1. Free user somehow selects premium category
2. **Expected**: Upgrade prompt appears, category resets to free
3. **Actual**: Upgrade prompt appears, category resets to free ✅

### ✅ Default Category Protection

1. User's subscription expires with premium default category
2. **Expected**: Default category resets to free category
3. **Actual**: Default category resets to free category ✅

## Files Modified

- `ShopList/Managers/SubscriptionManager.swift`: Added item category restrictions
- `ShopList/Views/AddItemView.swift`: Updated category picker with restrictions
- `ShopList/Views/ItemDetailView.swift`: Updated category picker with restrictions
- `ShopList/Managers/UserSettingsManager.swift`: Added default category protection

The implementation ensures that item categories are now properly restricted for free users while maintaining a smooth upgrade experience and protecting user data.
