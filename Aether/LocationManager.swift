//
//  LocationManager.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var isLoading = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var permissionError = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        isLoading = false
    }

    func requestLocation() {
        isLoading = true
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            permissionError = true
            isLoading = false
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
                self.permissionError = true
                self.isLoading = false
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            if let location = locations.first {
                self.location = location
                self.isLoading = false
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("Location Manager Error: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
    // MARK: - Geocoding (Reverse)
    
    func getCityName(from location: CLLocation) async -> String? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality
        } catch {
            print("Reverse geocoding failed: \(error.localizedDescription)")
            return nil
        }
    }
}
