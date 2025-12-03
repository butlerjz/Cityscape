//
//  GooglePlacesConfig.swift
//  Hackathon
//
//  Created by Jackson Butler on 12/1/25.
//

import Foundation
import GooglePlacesSwift

enum GooglePlacesConfig {
    static func configure() {
        let _ = PlacesClient.provideAPIKey(Secrets.googleMapsAPIKey)
    }
}
