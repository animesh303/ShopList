# Location-Based Search Feature

## Overview

The ShopList app now includes a comprehensive location-based search restriction feature that allows users to limit search results to their local area. This feature is particularly useful for finding nearby stores, restaurants, and other points of interest when setting up location reminders.

## Features

### 1. Search Restriction Toggle

- Enable/disable location-based search restrictions
- When enabled, all location searches are limited to a specified radius
- When disabled, searches return results from anywhere

### 2. Configurable Search Radius

- Choose from predefined radius options: 1km, 2km, 5km, 10km, 20km, 50km
- Default radius is 5km
- Radius is applied to both current location and custom location searches

### 3. Location Options

- **Current Location**: Use your device's GPS location for search center
- **Custom Location**: Set a specific location as the search center
- Automatic fallback to current location if custom location is not available

### 4. Visual Indicators

- Search interfaces show when location restrictions are active
- Settings page displays current search configuration
- Map preview shows the exact search area

## How to Use

### Enabling Location-Based Search

1. Open the **Settings** app
2. Navigate to **Location Search** section
3. Toggle **"Restrict Search to Locality"** to enable
4. Configure your preferred settings:
   - Choose search radius
   - Select location type (current or custom)
   - Set custom location if needed

### Setting Up Custom Location

1. In Location Search settings, disable **"Use Current Location"**
2. Enter a location name in the search field
3. Select from the search results
4. The selected location becomes your search center

### Viewing Search Area

1. In Location Search settings, tap **"View Search Area on Map"**
2. A map will show your search center and radius
3. This helps visualize what area is included in searches

## Technical Implementation

### Core Components

#### LocationManager.swift

- `getSearchRegion()`: Returns MKCoordinateRegion for search requests
- `isLocationWithinSearchRadius()`: Checks if a location is within the search radius
- Enhanced location tracking for current location updates

#### UserSettingsManager.swift

- `restrictSearchToLocality`: Boolean flag for enabling/disabling restrictions
- `searchRadius`: Configurable search radius in meters
- `useCurrentLocationForSearch`: Toggle between current and custom location
- `savedSearchLocation`: Stores custom location coordinates

#### LocationSearchSettingsView.swift

- Complete UI for configuring location search settings
- Location search functionality with MapKit integration
- Map preview with search area visualization

### Integration Points

#### LocationSetupView.swift

- Enhanced to use location restrictions when searching for stores
- Filters search results based on configured radius
- Shows distance information for search results

#### Search Interfaces

- ListDetailView, ShoppingListView, and ContentView show location restriction indicators
- Visual feedback when search is restricted to local area

## Privacy and Permissions

### Required Permissions

- **Location Services**: Required for current location functionality
- **Always Allow**: Recommended for background location updates

### Data Storage

- Search settings are stored locally in UserDefaults
- Custom location coordinates are saved locally
- No location data is transmitted to external servers

### Privacy Features

- Location data is only used for search restrictions
- No location history is stored beyond the current session
- Users can disable location restrictions at any time

## Testing

The feature includes comprehensive unit tests in `LocationSearchTests.swift`:

- Location restriction enable/disable functionality
- Distance calculation accuracy
- Search region generation
- Custom location handling

## Future Enhancements

### Potential Additions

1. **Multiple Search Centers**: Save multiple custom locations
2. **Dynamic Radius**: Adjust radius based on location type
3. **Search History**: Remember recent search locations
4. **Offline Support**: Cache search results for offline use
5. **Integration with External APIs**: Apply restrictions to external search services

### External API Integration

The current implementation is designed to work with any external search APIs you might add in the future. Simply:

1. Use `locationManager.getSearchRegion()` to get the search region
2. Apply the region to your API requests
3. Use `locationManager.isLocationWithinSearchRadius()` to filter results

## Troubleshooting

### Common Issues

**Location not updating**

- Ensure location permissions are granted
- Check if location services are enabled in device settings
- Restart the app to refresh location services

**Search results not appearing**

- Verify location restrictions are properly configured
- Check if the search radius is appropriate for your area
- Ensure the custom location is set correctly

**Map preview not showing**

- Confirm location permissions are granted
- Check if a valid location is set as search center
- Restart the app if the issue persists

### Debug Information

- Location status is displayed in Settings > Location Search
- Search radius and location type are shown in the settings
- Visual indicators appear in search interfaces when restrictions are active
