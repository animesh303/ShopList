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
            .navigationTitle("Location Reminder")
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $showingMap) {
                if let coordinate = selectedCoordinate {
                    LocationMapView(coordinate: coordinate, radius: radius, storeName: storeName)
                }
            }
            .onAppear {
                checkLocationPermission()
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
            .navigationTitle("Location Preview")
            .navigationBarTitleDisplayMode(.inline)
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