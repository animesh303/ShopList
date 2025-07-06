# Item Image Upgrade Flow Fix

## Issue Description

When a free user clicked on the item image button while creating or editing an item, they would see an upgrade prompt message, but clicking "Upgrade" would not present the subscription view. The upgrade flow was broken.

## Root Cause

The issue was in both `AddItemView.swift` and `ItemDetailView.swift` where:

1. **Missing State Variable**: The views were missing the `@State private var showingPremiumUpgrade = false` variable
2. **Missing Sheet**: No sheet was configured to present the `PremiumUpgradeView`
3. **Incomplete Alert Action**: The upgrade alert had a placeholder comment instead of the actual action to show the premium upgrade view

## Files Affected

- `ShopList/Views/AddItemView.swift`
- `ShopList/Views/ItemDetailView.swift`

## Solution Implemented

### 1. AddItemView.swift Fixes

#### Added Missing State Variable

```swift
// Before: Missing state variable
@State private var showingUpgradePrompt = false
@State private var upgradePromptMessage = ""

// After: Added missing state variable
@State private var showingUpgradePrompt = false
@State private var upgradePromptMessage = ""
@State private var showingPremiumUpgrade = false
```

#### Fixed Alert Action

```swift
// Before: Placeholder comment
.alert("Upgrade to Premium", isPresented: $showingUpgradePrompt) {
    Button("Upgrade") {
        // Show premium upgrade view
    }
    Button("Cancel", role: .cancel) { }
} message: {
    Text(upgradePromptMessage)
}

// After: Proper action implementation
.alert("Upgrade to Premium", isPresented: $showingUpgradePrompt) {
    Button("Upgrade") {
        showingPremiumUpgrade = true
    }
    Button("Cancel", role: .cancel) { }
} message: {
    Text(upgradePromptMessage)
}
```

#### Added Premium Upgrade Sheet

```swift
// Added sheet to present PremiumUpgradeView
.sheet(isPresented: $showingPremiumUpgrade) {
    PremiumUpgradeView()
}
```

### 2. ItemDetailView.swift Fixes

Applied the same three fixes as AddItemView:

- Added `@State private var showingPremiumUpgrade = false`
- Fixed alert action to set `showingPremiumUpgrade = true`
- Added sheet to present `PremiumUpgradeView`

## How the Fix Works

1. **User Clicks Image Button**: Free user clicks on item image button
2. **Premium Check**: `subscriptionManager.canUseItemImages()` returns `false`
3. **Upgrade Prompt**: Sets `upgradePromptMessage` and shows `showingUpgradePrompt = true`
4. **Alert Displayed**: User sees upgrade prompt with "Upgrade" and "Cancel" buttons
5. **User Clicks Upgrade**: Alert action sets `showingPremiumUpgrade = true`
6. **Sheet Presented**: `PremiumUpgradeView` is presented as a sheet
7. **Subscription Flow**: User can now complete the subscription process

## Testing Scenarios

### ✅ Free User - Item Image Access

1. Create new item or edit existing item
2. Click on item image button
3. See upgrade prompt message
4. Click "Upgrade" button
5. **Expected**: PremiumUpgradeView sheet appears
6. **Actual**: PremiumUpgradeView sheet appears ✅

### ✅ Premium User - Item Image Access

1. Create new item or edit existing item
2. Click on item image button
3. **Expected**: Image picker options appear (Camera/Photo Library)
4. **Actual**: Image picker options appear ✅

## Benefits

1. **Complete Upgrade Flow**: Free users can now properly access the subscription view
2. **Consistent UX**: Matches the behavior of other premium features in the app
3. **Revenue Opportunity**: Users can now complete the upgrade process
4. **User Satisfaction**: Clear path from feature discovery to subscription

## Related Features

This fix ensures consistency with other premium features that have proper upgrade flows:

- Shopping list creation limits
- Location reminders
- Data sharing
- Budget tracking
- Unlimited notifications

The item image feature now follows the same pattern as these other premium features.
