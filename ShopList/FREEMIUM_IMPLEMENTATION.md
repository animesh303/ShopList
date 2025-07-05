# Freemium Implementation - Phase 1

This document outlines the freemium foundation implementation for the ShopList app.

## Overview

The app now implements a freemium model with the following tiers:

### Free Tier

- **Lists**: Maximum 3 shopping lists
- **Categories**: Only 3 basic categories (Groceries, Household, Personal)
- **Notifications**: 5 notifications per day
- **Features**: Basic shopping list functionality

### Premium Tier

- **Lists**: Unlimited shopping lists
- **Categories**: All 20+ categories
- **Notifications**: Unlimited notifications
- **Features**: All premium features including location reminders, widgets, templates, budget tracking, etc.

## Implementation Details

### 1. Subscription Management

**File**: `Managers/SubscriptionManager.swift`

- Handles subscription status and feature access control
- Integrates with StoreKit for in-app purchases
- Tracks usage limits for free users
- Provides methods to check feature availability

### 2. Premium Features

**File**: `Models/AppEnums.swift`

Defines premium features and their availability:

- Unlimited Lists
- All Categories
- Location Reminders
- Unlimited Notifications
- iOS Widgets

- List Templates
- Budget Tracking
- Item Images
- Export/Import
- Priority Support

### 3. UI Components

#### Premium Upgrade View

**File**: `Views/PremiumUpgradeView.swift`

- Beautiful upgrade interface showcasing premium features
- Subscription plan selection (monthly/yearly)
- Feature comparison grid
- Purchase and restore functionality

#### Usage Limit View

**File**: `Views/UsageLimitView.swift`

- Shows current usage for free users
- Progress indicators for lists and notifications
- Upgrade prompts and feature previews

#### Upgrade Prompt View

**File**: `Views/UpgradePromptView.swift`

- Quick upgrade prompts for specific features
- Feature-specific messaging
- Call-to-action buttons

### 4. Feature Restrictions

#### Content View

- Shows usage limit view for free users
- Prevents creating lists beyond the limit
- Shows upgrade prompts when limits are reached

#### Add List View

- Restricts categories to free tier only
- Disables budget tracking for free users
- Shows upgrade prompts for premium features

#### Settings View

- Subscription status and plan information
- Feature availability indicators
- Upgrade buttons throughout the interface

#### Notification Manager

- Tracks daily notification usage
- Prevents scheduling notifications beyond limits
- Respects location reminder restrictions

## Usage Examples

### Checking Feature Access

```swift
let subscriptionManager = SubscriptionManager.shared

// Check if user can create a new list
if subscriptionManager.canCreateList() {
    // Allow list creation
} else {
    // Show upgrade prompt
}

// Check if user can use a specific category
if subscriptionManager.canUseCategory(.electronics) {
    // Allow electronics category
} else {
    // Show upgrade prompt
}

// Check if user can use budget tracking
if subscriptionManager.canUseBudgetTracking() {
    // Enable budget features
} else {
    // Disable budget features
}
```

### Showing Upgrade Prompts

```swift
// Get upgrade message for specific feature
let message = subscriptionManager.getUpgradePrompt(for: .locationReminders)

// Show upgrade prompt
showingUpgradePrompt = true
upgradePromptMessage = message
```

### Usage Tracking

```swift
// Get current usage
let usage = subscriptionManager.getFreeTierUsage()
print("Lists: \(usage.lists)/\(usage.maxLists)")
print("Notifications: \(usage.notifications)/\(usage.maxNotifications)")
```

## StoreKit Integration

### Product Identifiers

- `com.shoplist.premium.monthly` - Monthly subscription
- `com.shoplist.premium.yearly` - Yearly subscription

### Purchase Flow

1. User taps upgrade button
2. Premium upgrade view is presented
3. User selects subscription plan
4. StoreKit purchase is initiated
5. On successful purchase, subscription status is updated
6. Premium features are unlocked

## Testing

### Free Tier Testing

1. Install app fresh
2. Create 3 lists (should work)
3. Try to create 4th list (should show upgrade prompt)
4. Try to use premium categories (should be restricted)
5. Try to set budget (should be disabled)
6. Try to use location reminders (should show upgrade prompt)

### Premium Tier Testing

1. Purchase premium subscription
2. Verify all features are unlocked
3. Create unlimited lists
4. Use all categories
5. Enable budget tracking
6. Set up location reminders

## Next Steps (Phase 2)

1. **Enhanced Premium Features**

   - Advanced analytics dashboard
   - Family sharing capabilities
   - Cloud sync across devices
   - Collaborative shopping lists

2. **Additional Revenue Streams**

   - Affiliate marketing integration
   - Premium content (shopping guides, meal plans)
   - White-label solutions

3. **Marketing Integration**
   - App Store optimization
   - In-app messaging
   - A/B testing for pricing
   - Referral programs

## Configuration

### Free Tier Limits

```swift
private let maxFreeLists = 3
private let maxFreeNotifications = 5
private let freeCategories: [ListCategory] = [.groceries, .household, .personal]
```

### Premium Features

All premium features are defined in the `PremiumFeature` enum and can be easily modified or extended.

## Notes

- The implementation is designed to be non-intrusive for free users
- Upgrade prompts are contextual and relevant
- Usage tracking is transparent and user-friendly
- The system gracefully handles subscription status changes
- All premium features are clearly marked with crown icons
