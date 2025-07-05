# Shopping List Sharing Feature

## Overview

The ShopList app now includes a comprehensive sharing feature that allows users to share their shopping lists via standard iOS sharing mechanisms such as WhatsApp, Mail, Messages, and other compatible apps.

## Features

### 1. Individual List Sharing

- **Share Button in List Detail View**: Accessible via the floating action button (FAB) menu
- **Swipe Actions**: Swipe left on any list in the main view to reveal the share option
- **Rich Content**: Shares formatted text with emojis, categories, prices, and completion status

### 2. Combined Lists Sharing

- **Share All Lists**: Available in the main view's FAB menu
- **Summary View**: Provides an overview of all shopping lists with key statistics

### 3. Multiple Formats

- **Text Format**: Richly formatted text with emojis and organization
- **CSV Format**: Structured data file for spreadsheet applications
- **Native iOS Sharing**: Integrates with all iOS sharing options

## Implementation Details

### Files Modified/Created

1. **ShoppingListViewModel.swift**

   - Added `generateShareableContent(for:)` method
   - Added `generateCSVContent(for:)` method
   - Added `createCSVFile(for:)` method
   - Added `shareList(_:)` method
   - Added `getShareableItems(for:)` method

2. **ShareSheet.swift** (New)

   - Wrapper for UIKit's UIActivityViewController
   - Handles native iOS sharing interface

3. **ListDetailView.swift**

   - Added share button to FAB menu
   - Integrated ShareSheet presentation

4. **ShoppingListView.swift**

   - Added swipe actions for sharing
   - Integrated ShareSheet presentation

5. **ContentView.swift**

   - Added "Share All Lists" button to FAB menu
   - Added combined sharing functionality

6. **SharingTests.swift** (New)
   - Comprehensive test suite for sharing functionality

### Sharing Content Format

#### Text Format Example:

```
🛒 Grocery List
📅 Created: Dec 15, 2024 at 2:30 PM
📊 Category: Groceries

💰 Budget: $50.00
💳 Estimated Total: $10.47
✅ Spent: $2.49

📋 Items (2 total):

Dairy:
⭕ Milk (2) gallon - $3.99 (Organic)

Bakery:
✅ Bread (1) loaf - $2.49

---
Shared from ShopList App
```

#### CSV Format:

```csv
Name,Quantity,Unit,Category,Price,Notes,Completed
Milk,2,gallon,Dairy,3.99,Organic,No
Bread,1,loaf,Bakery,2.49,,Yes
```

## Usage

### Sharing Individual Lists

1. **From List Detail View**:

   - Open any shopping list
   - Tap the ellipsis button (⋯) in the bottom right
   - Tap the share button (📤)
   - Choose your preferred sharing method

2. **From Main List View**:
   - Swipe left on any list
   - Tap the "Share" button
   - Choose your preferred sharing method

### Sharing All Lists

1. **From Main View**:
   - Tap the ellipsis button (⋯) in the bottom right
   - Tap the share button (📤)
   - Choose your preferred sharing method

## Supported Sharing Methods

The sharing feature integrates with all iOS sharing options including:

- **Messaging Apps**: WhatsApp, Telegram, Signal, etc.
- **Email**: Mail app, Gmail, Outlook, etc.
- **Social Media**: Facebook, Twitter, Instagram, etc.
- **Cloud Storage**: iCloud Drive, Google Drive, Dropbox, etc.
- **Notes**: Apple Notes, Notion, etc.
- **Print**: AirPrint compatible printers
- **Copy to Clipboard**: For pasting elsewhere

## Technical Implementation

### Architecture

- Uses SwiftUI's `UIViewControllerRepresentable` to wrap UIKit's `UIActivityViewController`
- Maintains separation of concerns with dedicated sharing methods in ViewModel
- Supports both text and file sharing formats

### Error Handling

- Graceful handling of file creation failures
- Fallback to text-only sharing if CSV creation fails
- Proper memory management for temporary files

### Performance

- Lazy generation of shareable content
- Efficient CSV file creation
- Minimal memory footprint

## Testing

The sharing functionality includes comprehensive tests covering:

- Text content generation
- CSV content generation
- Share state management
- Multiple item formats
- Edge cases (empty lists, special characters, etc.)

Run tests with:

```bash
xcodebuild test -scheme ShopList -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Future Enhancements

Potential improvements for future versions:

1. **Custom Sharing Templates**: User-defined sharing formats
2. **QR Code Generation**: For quick list sharing
3. **Collaborative Lists**: Real-time sharing with other users
4. **Export Formats**: PDF, JSON, XML support
5. **Scheduled Sharing**: Automatic sharing at specific times
6. **Integration APIs**: Direct integration with grocery delivery services

## Privacy & Security

- No data is transmitted to external servers
- All sharing is handled through iOS native mechanisms
- User maintains full control over what and how to share
- Temporary files are cleaned up automatically
- No tracking or analytics on sharing behavior
