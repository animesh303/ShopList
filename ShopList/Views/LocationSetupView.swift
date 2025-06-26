import SwiftUI
import CoreLocation
import MapKit

struct LocationSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    let list: ShoppingList
    
    @State private var storeName = ""
    @State private var searchText = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var radius: Double = 100 // meters
    @State private var reminderMessage = ""
    @State private var showingLocationPermissionAlert = false
    @State private var showingMap = false
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var showingLocationError = false
    @State private var locationHandler: LocationHandler?
    @State private var tempLocationManager: CLLocationManager?
    @State private var permissionRequested = false
    
    private let radiusOptions = [50.0, 100.0, 200.0, 500.0, 1000.0]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Store Name", text: $storeName)
                        .textContentType(.organizationName)
                    
                    TextField("Search for store location", text: $searchText)
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
                    
                    // Show location permission status
                    let status = CLLocationManager().authorizationStatus
                    if status == .denied || status == .restricted {
                        HStack {
                            Image(systemName: "location.slash")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Location Access Required")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("Enable location access for local search results")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Enable") {
                                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(settingsUrl)
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    } else if status == .notDetermined {
                        HStack {
                            Image(systemName: "location.questionmark")
                                .foregroundColor(.blue)
                            Text("Location permission not determined")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            if permissionRequested {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding(.vertical, 4)
                    } else if userLocation != nil {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.green)
                            Text("Using your current location for local search")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
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
                                    if let userLocation = userLocation {
                                        let distance = calculateDistance(from: userLocation, to: item.placemark.coordinate)
                                        Text("\(String(format: "%.1f", distance)) km away")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } header: {
                    Text("Store Information")
                } footer: {
                    Text("Search for a store to set up location-based reminders")
                }
                
                if let coordinate = selectedCoordinate {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Selected Location", systemImage: "location")
                                Spacer()
                                Button("View on Map") {
                                    showingMap = true
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            Text("Latitude: \(coordinate.latitude, specifier: "%.6f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Longitude: \(coordinate.longitude, specifier: "%.6f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Picker("Reminder Radius", selection: $radius) {
                            ForEach(radiusOptions, id: \.self) { radius in
                                Text("\(Int(radius)) meters").tag(radius)
                            }
                        }
                        
                        TextField("Reminder Message", text: $reminderMessage, axis: .vertical)
                            .lineLimit(3...6)
                            .textFieldStyle(.roundedBorder)
                    } header: {
                        Text("Location Settings")
                    } footer: {
                        Text("You'll receive a notification when you're within \(Int(radius)) meters of this location")
                    }
                }
                
                if selectedCoordinate != nil {
                    Section {
                        Button("Set Up Location Reminder") {
                            setupLocationReminder()
                        }
                        .disabled(storeName.isEmpty || reminderMessage.isEmpty)
                    } header: {
                        Text("Actions")
                    }
                }
            }
            .enhancedNavigation(
                title: "Location Reminder",
                subtitle: "Set up location-based notifications",
                icon: "location.circle",
                style: .info,
                showBanner: true
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
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
                Text("Location-based reminders require 'Always' location access to work in the background. Please enable this in Settings.")
            }
            .alert("Location Error", isPresented: $showingLocationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Unable to get your current location. Search will use global results.")
            }
            .sheet(isPresented: $showingMap) {
                if let coordinate = selectedCoordinate {
                    LocationMapView(coordinate: coordinate, radius: radius, storeName: storeName)
                }
            }
            .onAppear {
                checkLocationPermission()
                // Request location permission if not determined
                let status = CLLocationManager().authorizationStatus
                if status == .notDetermined {
                    permissionRequested = true
                    let tempManager = CLLocationManager()
                    tempManager.requestWhenInUseAuthorization()
                    
                    // Check for permission change after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let newStatus = CLLocationManager().authorizationStatus
                        if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                            getCurrentLocation()
                        }
                        permissionRequested = false
                    }
                } else if status == .authorizedWhenInUse || status == .authorizedAlways {
                    getCurrentLocation()
                }
            }
        }
    }
    
    private func checkLocationPermission() {
        let status = CLLocationManager().authorizationStatus
        if status == .denied || status == .restricted {
            showingLocationPermissionAlert = true
        }
        
        // Update the location manager's authorization status
        locationManager.checkAuthorizationStatus()
    }
    
    private func getCurrentLocation() {
        let status = CLLocationManager().authorizationStatus
        
        // Only request location if we have permission
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            print("Location permission not granted. Status: \(status.rawValue)")
            return
        }
        
        tempLocationManager = CLLocationManager()
        tempLocationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        // Create and store the location handler
        locationHandler = LocationHandler { location in
            self.userLocation = location.coordinate
        } errorHandler: { error in
            print("Location error: \(error)")
            DispatchQueue.main.async {
                if let clError = error as? CLError {
                    switch clError.code {
                    case .denied:
                        self.showingLocationError = true
                    case .locationUnknown:
                        print("Location temporarily unavailable")
                    case .network:
                        print("Network error")
                    default:
                        self.showingLocationError = true
                    }
                } else {
                    self.showingLocationError = true
                }
            }
        }
        
        // Set the delegate and request location
        if let manager = tempLocationManager, let handler = locationHandler {
            handler.setLocationManager(manager)
            manager.delegate = handler
            manager.requestLocation()
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
        
        // Add region if we have user location and location restrictions are enabled
        if let searchRegion = locationManager.getSearchRegion() {
            request.region = searchRegion
        } else if let userLocation = userLocation {
            let region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // ~10km radius
            )
            request.region = region
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                if let error = error {
                    print("Search error: \(error)")
                    return
                }
                
                var results = response?.mapItems ?? []
                
                // Filter results by location if restrictions are enabled
                if self.locationManager.settingsManager.restrictSearchToLocality {
                    results = results.filter { item in
                        self.locationManager.isLocationWithinSearchRadius(item.placemark.coordinate)
                    }
                }
                
                searchResults = results
            }
        }
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000 // Convert to kilometers
    }
    
    private func selectLocation(_ item: MKMapItem) {
        storeName = item.name ?? "Unknown Store"
        selectedCoordinate = item.placemark.coordinate
        searchText = ""
        searchResults = []
        
        if reminderMessage.isEmpty {
            reminderMessage = "Don't forget to shop for: \(list.name)"
        }
    }
    
    private func setupLocationReminder() {
        guard let coordinate = selectedCoordinate else { return }
        
        // Check if we have 'Always' authorization for background monitoring
        let status = CLLocationManager().authorizationStatus
        if status != .authorizedAlways {
            // Show alert explaining the requirement
            showingLocationPermissionAlert = true
            return
        }
        
        // Update the shopping list with location
        list.location = Location(
            name: storeName,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: radius
        )
        
        // Add location reminder
        locationManager.addLocationReminder(
            for: list,
            at: coordinate,
            radius: radius,
            message: reminderMessage
        )
        
        dismiss()
    }
}

// Helper class for one-time location requests
class LocationHandler: NSObject, CLLocationManagerDelegate {
    let locationHandler: (CLLocation) -> Void
    let errorHandler: (Error) -> Void
    weak var locationManager: CLLocationManager?
    
    init(locationHandler: @escaping (CLLocation) -> Void, errorHandler: @escaping (Error) -> Void) {
        self.locationHandler = locationHandler
        self.errorHandler = errorHandler
    }
    
    func setLocationManager(_ manager: CLLocationManager) {
        self.locationManager = manager
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationHandler(location)
        }
        cleanup()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorHandler(error)
        cleanup()
    }
    
    private func cleanup() {
        locationManager?.delegate = nil
        locationManager = nil
    }
}

struct LocationMapView: View {
    let coordinate: CLLocationCoordinate2D
    let radius: Double
    let storeName: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var position: MapCameraPosition
    
    init(coordinate: CLLocationCoordinate2D, radius: Double, storeName: String) {
        self.coordinate = coordinate
        self.radius = radius
        self.storeName = storeName
        
        // Calculate appropriate span based on radius
        let radiusInDegrees = radius / 111000 // Approximate conversion from meters to degrees
        let span = max(radiusInDegrees * 4, 0.01) // Show 4x radius or minimum 0.01
        
        self._position = State(initialValue: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        )))
    }
    
    var body: some View {
        NavigationView {
            Map(position: $position) {
                Annotation(storeName, coordinate: coordinate) {
                    VStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                        
                        Text(storeName)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
            }
            .enhancedNavigation(
                title: "Location Preview",
                subtitle: "Preview your reminder area",
                icon: "map",
                style: .info,
                showBanner: true
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Reminder Radius")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(radius))m")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            )
        }
    }
} 