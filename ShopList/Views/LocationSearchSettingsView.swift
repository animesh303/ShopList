import SwiftUI
import CoreLocation
import MapKit

struct LocationSearchSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var locationManager = LocationManager.shared
    
    @State private var showingLocationPermissionAlert = false
    @State private var showingMap = false
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var locationName = ""
    
    private let radiusOptions = [
        (1000.0, "1 km"),
        (2000.0, "2 km"),
        (5000.0, "5 km"),
        (10000.0, "10 km"),
        (20000.0, "20 km"),
        (50000.0, "50 km")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Restrict Search to Locality", isOn: $settingsManager.restrictSearchToLocality)
                        .onChange(of: settingsManager.restrictSearchToLocality) { _, newValue in
                            if newValue && !locationManager.isAuthorized {
                                showingLocationPermissionAlert = true
                                settingsManager.restrictSearchToLocality = false
                            }
                        }
                    
                    if settingsManager.restrictSearchToLocality {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Search Radius")
                                .font(.headline)
                            
                            Picker("Radius", selection: $settingsManager.searchRadius) {
                                ForEach(radiusOptions, id: \.0) { radius, label in
                                    Text(label).tag(radius)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Text("Search will be limited to locations within \(Int(settingsManager.searchRadius / 1000)) km of your selected location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Search Restrictions")
                } footer: {
                    Text("When enabled, search results will be limited to your local area")
                }
                
                if settingsManager.restrictSearchToLocality {
                    Section {
                        Toggle("Use Current Location", isOn: $settingsManager.useCurrentLocationForSearch)
                            .onChange(of: settingsManager.useCurrentLocationForSearch) { _, newValue in
                                if newValue && !locationManager.isLocationAvailable {
                                    showingLocationPermissionAlert = true
                                    settingsManager.useCurrentLocationForSearch = false
                                }
                            }
                        
                        if !settingsManager.useCurrentLocationForSearch {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Custom Location")
                                    .font(.headline)
                                
                                TextField("Search for location", text: $searchText)
                                    .textContentType(.fullStreetAddress)
                                    .onChange(of: searchText) { _, newValue in
                                        searchForLocations(query: newValue)
                                    }
                                
                                if isSearching {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Searching...")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if !searchResults.isEmpty {
                                    ForEach(searchResults, id: \.self) { item in
                                        Button(action: {
                                            selectLocation(item)
                                        }) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.name ?? "Unknown Location")
                                                    .font(.headline)
                                                if let address = item.placemark.thoroughfare {
                                                    Text(address)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                
                                if selectedLocation != nil {
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(.green)
                                        Text(locationName.isEmpty ? "Custom Location Selected" : locationName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Button("Clear") {
                                            self.selectedLocation = nil
                                            self.locationName = ""
                                            settingsManager.savedSearchLocation = nil
                                        }
                                        .buttonStyle(.bordered)
                                        .font(.caption)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(.vertical, 4)
                        } else {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.green)
                                Text("Using current location for search")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                if locationManager.isLocationAvailable {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        Text("Search Location")
                    } footer: {
                        Text("Choose whether to use your current location or a custom location for search restrictions")
                    }
                }
                
                if settingsManager.restrictSearchToLocality {
                    Section {
                        Button(action: { showingMap = true }) {
                            HStack {
                                Image(systemName: "map")
                                Text("View Search Area on Map")
                            }
                        }
                    } header: {
                        Text("Map Preview")
                    } footer: {
                        Text("See the area that will be included in your search results")
                    }
                }
            }
            .enhancedNavigation(
                title: "Location Search",
                subtitle: "Configure location-based search",
                icon: "magnifyingglass.circle",
                style: .info,
                showBanner: true
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Location Permission Required", isPresented: $showingLocationPermissionAlert) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Location access is required to restrict search to your locality. Please enable location access in Settings.")
            }
            .sheet(isPresented: $showingMap) {
                LocationSearchMapView(
                    centerLocation: getCenterLocation(),
                    radius: settingsManager.searchRadius
                )
            }
        }
    }
    
    private func searchForLocations(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                if let error = error {
                    print("Search error: \(error)")
                    return
                }
                
                searchResults = response?.mapItems ?? []
            }
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        selectedLocation = item.placemark.coordinate
        locationName = item.name ?? "Custom Location"
        settingsManager.savedSearchLocation = item.placemark.coordinate
        searchText = ""
        searchResults = []
    }
    
    private func getCenterLocation() -> CLLocationCoordinate2D? {
        if settingsManager.useCurrentLocationForSearch {
            return locationManager.currentLocation
        } else {
            return settingsManager.savedSearchLocation
        }
    }
}

struct LocationSearchMapView: View {
    @Environment(\.dismiss) private var dismiss
    let centerLocation: CLLocationCoordinate2D?
    let radius: Double
    
    @State private var region: MKCoordinateRegion?
    
    var body: some View {
        NavigationView {
            Group {
                if let region = region {
                    Map(position: .constant(.region(region))) {
                        // Empty map content - just showing the region
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 200, height: 200)
                    )
                } else {
                    VStack {
                        Image(systemName: "location.slash")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Location not available")
                            .font(.headline)
                        Text("Please set a custom location or enable current location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .enhancedNavigation(
                title: "Search Area",
                subtitle: "View your search radius",
                icon: "map",
                style: .info,
                showBanner: true
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let centerLocation = centerLocation {
                    let radiusInDegrees = radius / 111000
                    let span = MKCoordinateSpan(latitudeDelta: radiusInDegrees, longitudeDelta: radiusInDegrees)
                    region = MKCoordinateRegion(center: centerLocation, span: span)
                }
            }
        }
    }
} 