//
//  PlaceResult.swift
//  Hackathon
//
//  Created by Jackson Butler on 12/1/25.
//

import Foundation
import CoreLocation

struct PlaceResult: Identifiable, Hashable {
    let id: String
    
    let name: String
    
    let address: String
    
    let latitude: CLLocationDegrees
    
    let longitude: CLLocationDegrees
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
