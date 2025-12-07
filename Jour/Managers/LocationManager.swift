//
//  LocationManager.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation
import CoreLocation
import Combine

/// Manages location services for auto-tagging entries
/// Provides current location and reverse geocoding
class LocationManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    /// Current location data
    @Published var currentLocation: LocationData?
    
    /// Whether location services are authorized
    @Published var isAuthorized = false
    
    // MARK: - Private Properties
    
    /// Core Location manager
    private let locationManager = CLLocationManager()
    
    /// Geocoder for reverse geocoding (coordinates → place names)
    private let geocoder = CLGeocoder()
    
    /// Last location update time (to avoid excessive updates)
    private var lastUpdateTime: Date?
    
    /// Minimum time between location updates (seconds)
    private let updateInterval: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100 // Update every 100 meters
        
        checkAuthorizationStatus()
    }
    
    // MARK: - Public Methods
    
    /// Requests location permission from user
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Starts monitoring location updates
    func startMonitoring() {
        guard isAuthorized else {
            requestPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// Stops monitoring location updates
    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Gets current location (cached or requests new)
    func getCurrentLocation() -> LocationData? {
        // Return cached location if recent (within 5 minutes)
        if let lastUpdate = lastUpdateTime,
           Date().timeIntervalSince(lastUpdate) < updateInterval,
           let current = currentLocation {
            return current
        }
        
        // Request new location
        if isAuthorized {
            locationManager.requestLocation()
        }
        
        return currentLocation
    }
    
    // MARK: - Private Methods
    
    /// Checks current authorization status
    private func checkAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            startMonitoring()
        case .notDetermined:
            isAuthorized = false
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    /// Performs reverse geocoding to get place name from coordinates
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  error == nil,
                  let placemark = placemarks?.first else {
                // If geocoding fails, store coordinates only
                DispatchQueue.main.async {
                    self?.currentLocation = LocationData(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        placeName: nil,
                        address: nil
                    )
                    self?.lastUpdateTime = Date()
                }
                return
            }
            
            // Extract place name and address
            let placeName = placemark.name ?? placemark.locality
            let address = self.formatAddress(from: placemark)
            
            DispatchQueue.main.async {
                self.currentLocation = LocationData(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    placeName: placeName,
                    address: address
                )
                self.lastUpdateTime = Date()
            }
        }
    }
    
    /// Formats a human-readable address from placemark
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let street = placemark.thoroughfare {
            components.append(street)
        }
        if let city = placemark.locality {
            components.append(city)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        
        return components.joined(separator: ", ")
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    /// Called when authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
    
    /// Called when location updates are received
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Perform reverse geocoding
        reverseGeocode(location: location)
    }
    
    /// Called when location update fails
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

