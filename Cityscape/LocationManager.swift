//
//  LocationManager.swift
//  LocationAndPlaceLookup
//
//  Created by Jackson Butler on 11/9/25.
//

import Foundation
import MapKit

@Observable

class LocationManager: NSObject, CLLocationManagerDelegate {
    // *** CRITICALLY IMPORTANT ** Always add info.plist message for Privacy - Location when in use usage description
    
    var location: CLLocation?
    private let locationManager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?
    var locationUpdated: ((CLLocation) -> Void)? //this is a function that can be called
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //Get a region around the current location
    func getRegionAroundCurrentLocation(radiusInMeters: CLLocationDistance = 10000) -> MKCoordinateRegion? {
        guard let location = location else { return nil }
        
        return MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
    }
}

// Delegate methods that Apple has created & will call, but that we filled out
extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {return} //use last location as location
        location = newLocation
        //Call the callback function
        locationUpdated?(newLocation)
        
        // You can uncomment this when you only want to get the location once
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("LocationManager authorization granted.")
            manager.startUpdatingLocation()
            
        case .denied, .restricted:
            print("Location manager authorization denied.")
            errorMessage = "ERROR: LocationManager access denied."
            manager.stopUpdatingLocation()
            
        case .notDetermined:
            print("LocationManager authorization not determiend.")
            manager.requestWhenInUseAuthorization()
            
        @unknown default:
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: any Error) {
        errorMessage = error.localizedDescription
        print("ERROR: LocationManager: \(errorMessage ?? "n/a")")
    }
}
