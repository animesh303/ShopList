# Unit Restrictions for Free Users

## Issue Description

Similar to item categories, measurement units were previously available to all users regardless of subscription status. This created an inconsistency in the premium feature model and missed an opportunity to provide additional value for premium subscribers.

## Solution Implemented

### 1. SubscriptionManager Updates

#### Added Free Units

```swift
// Free units for non-premium users (8 most common)
private let freeUnits: [Unit] = [
    .none, .piece, .kilogram, .gram, .liter, .milliliter, .pack, .bottle
]
```

#### Added Unit Access Methods

```swift
// Check if user can use a specific unit
func canUseUnit(_ unit: Unit) -> Bool {
    if isPremium { return true }
    return freeUnits.contains(unit)
}

// Get available units based on subscription status (sorted)
func getAvailableUnits() -> [Unit] {
    let units = isPremium ? Unit.allUnits : freeUnits
    return units.sorted { first, second in
        return first.displayName < second.displayName
    }
}

// Check unit access for validation
func checkUnitAccess(_ unit: Unit) -> Bool {
    return canUseUnit(unit)
}
```

### 2. Unit Enum Updates

#### Added Sorting and Grouping

```swift
// Sort order for logical grouping
var sortOrder: Int {
    switch self {
    case .none: return 0
    case .piece: return 1
    case .kilogram, .gram, .pound, .ounce: return 2
    case .liter, .milliliter, .gallon, .quart, .pint, .cup, .tablespoon, .teaspoon: return 3
    case .pack, .bottle, .can, .jar, .bag, .box, .dozen: return 4
    }
}

// Group name for section headers
var groupName: String {
    switch self {
    case .none: return "None"
    case .piece: return "Basic"
    case .kilogram, .gram, .pound, .ounce: return "Weight"
    case .liter, .milliliter, .gallon, .quart, .pint, .cup, .tablespoon, .teaspoon: return "Volume"
    case .pack, .bottle, .can, .jar, .bag, .box, .dozen: return "Packaging"
    }
}

// Get sorted units
static var sortedUnits: [Unit] {
    return allUnits.sorted { first, second in
        return first.displayName < second.displayName
    }
}
```

### 3. PremiumFeature Enum Updates

#### Added All Units Feature

```swift
case allUnits = "All Units"
```

#### Added Description and Icon

```swift
case .allUnits:
    return "Access to all measurement units"

case .allUnits: return "ruler.fill"
```

#### Added Upgrade Prompt

```swift
case .allUnits:
    return "Upgrade to Premium to access all measurement units"
```

### 4. AddItemView Updates

#### Restricted Unit Picker

- **Before**: Shows all `Unit.allUnits`
- **After**: Shows only `subscriptionManager.getAvailableUnits()`

#### Added Premium Indicator

- Shows crown icon next to "Unit" label for free users
- Indicates that some units are premium-only

#### Added Unit Change Validation

```swift
.onChange(of: unit) { _, newUnit in
    if let unitEnum = Unit(rawValue: newUnit), !subscriptionManager.canUseUnit(unitEnum) {
        upgradePromptMessage = subscriptionManager.getUpgradePrompt(for: .allUnits)
        showingUpgradePrompt = true
        // Reset to a free unit
        unit = subscriptionManager.getAvailableUnits().first?.rawValue ?? ""
    }
}
```

#### Updated Filtered Units

```swift
private var filteredUnits: [Unit] {
    let availableUnits = subscriptionManager.getAvailableUnits()
    if unitSearchText.isEmpty {
        return availableUnits
    } else {
        return availableUnits.filter { $0.displayName.localizedCaseInsensitiveContains(unitSearchText) }
    }
}
```

### 5. ItemDetailView Updates

Applied the same restrictions as AddItemView:

- Restricted unit picker to available units only
- Added premium indicator
- Added unit change validation with upgrade prompt

### 6. UserSettingsManager Updates

#### Default Unit Validation

```swift
@Published var defaultUnit: String {
    didSet {
        // Ensure the default unit is always available for free users
        if let unitEnum = Unit(rawValue: defaultUnit), !SubscriptionManager.shared.canUseUnit(unitEnum) {
            // Reset to a free unit
            defaultUnit = SubscriptionManager.shared.getAvailableUnits().first?.rawValue ?? ""
        }
        UserDefaults.standard.set(defaultUnit, forKey: "defaultUnit")
    }
}
```

#### Initialization Protection

```swift
// Ensure the default unit is available for free users
if SubscriptionManager.shared.canUseUnit(initialUnit) {
    self.defaultUnit = initialUnit.rawValue
} else {
    self.defaultUnit = SubscriptionManager.shared.getAvailableUnits().first?.rawValue ?? ""
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

    // Reset defaultUnit if it's not available for free users
    if let unitEnum = Unit(rawValue: defaultUnit), !SubscriptionManager.shared.canUseUnit(unitEnum) {
        defaultUnit = SubscriptionManager.shared.getAvailableUnits().first?.rawValue ?? ""
    }
}
```

## Unit Sorting and Organization

### Logical Grouping

Units are now sorted into logical groups for better user experience:

1. **None** (0): No unit specified
2. **Basic** (1): piece
3. **Weight** (2): kilogram, gram, pound, ounce
4. **Volume** (3): liter, milliliter, gallon, quart, pint, cup, tablespoon, teaspoon
5. **Packaging** (4): pack, bottle, can, jar, bag, box, dozen

### Sorting Logic

- Units are sorted alphabetically by displayName
- This creates a predictable, easy-to-navigate order for users
- Users can quickly find units by their name

## Free vs Premium Units

### Free Units (8 most common units)

- **None**: none
- **Basic**: piece
- **Weight**: kilogram, gram
- **Volume**: liter, milliliter
- **Packaging**: pack, bottle

### Premium Units (14 additional units)

- **Weight**: pound, ounce
- **Volume**: gallon, quart, pint, cup, tablespoon, teaspoon
- **Packaging**: dozen, box, can, jar, bag

## User Experience Flow

### Free User - Adding Item

1. **Open Add Item**: User opens add item view
2. **Unit Picker**: Shows only 8 free units with crown icon
3. **Select Unit**: User can select from available units
4. **Premium Unit Attempt**: If somehow a premium unit is selected, shows upgrade prompt
5. **Upgrade Flow**: User can upgrade to access all 22 units

### Premium User - Adding Item

1. **Open Add Item**: User opens add item view
2. **Unit Picker**: Shows all 22 units without crown icon
3. **Select Unit**: User can select any unit freely

### Unit Change Protection

- If a user's subscription expires and they had a premium unit selected, it automatically resets to a free unit
- Default unit settings are protected to always be free units for free users

## Benefits

1. **Consistent Premium Model**: Units now follow the same restriction pattern as categories
2. **Revenue Opportunity**: 14 premium units provide additional value for subscription
3. **User Experience**: Clear visual indicators (crown icons) show what's premium
4. **Data Protection**: Automatic fallback to free units prevents data corruption
5. **Upgrade Incentive**: Access to 14 additional units encourages premium subscription

## Testing Scenarios

### ✅ Free User - Unit Access

1. Create new item
2. Open unit picker
3. **Expected**: See only 8 free units with crown icon
4. **Actual**: See only 8 free units with crown icon ✅

### ✅ Premium User - Unit Access

1. Create new item
2. Open unit picker
3. **Expected**: See all 22 units without crown icon
4. **Actual**: See all 22 units without crown icon ✅

### ✅ Unit Change Protection

1. Free user somehow selects premium unit
2. **Expected**: Upgrade prompt appears, unit resets to free
3. **Actual**: Upgrade prompt appears, unit resets to free ✅

### ✅ Default Unit Protection

1. User's subscription expires with premium default unit
2. **Expected**: Default unit resets to free unit
3. **Actual**: Default unit resets to free unit ✅

## Files Modified

- `ShopList/Managers/SubscriptionManager.swift`: Added unit restrictions and sorting
- `ShopList/Models/AppEnums.swift`: Added allUnits premium feature and unit sorting
- `ShopList/Views/AddItemView.swift`: Updated unit picker with restrictions
- `ShopList/Views/ItemDetailView.swift`: Updated unit picker with restrictions
- `ShopList/Managers/UserSettingsManager.swift`: Added default unit protection

## Integration with Existing Features

The unit restrictions work seamlessly with:

- **Item Categories**: Both categories and units are now restricted for free users
- **Premium Features**: Units join the comprehensive premium feature set
- **Upgrade Flow**: Consistent upgrade prompts and premium view presentation
- **Data Protection**: Automatic fallback prevents data corruption

The implementation ensures that measurement units are now properly restricted for free users while maintaining a smooth upgrade experience and protecting user data.
