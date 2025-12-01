//
//  Event.swift
//  Cityscape
//
//  Created by Jackson Butler on 11/30/25.
//

import Foundation
import FirebaseFirestore

struct Event: Codable, Identifiable {
    @DocumentID var id: String?
    var name = ""
    var startDate: Date
    var endDate: Date
    var startTime: Date?
    var endTime: Date?
    var photo: Photo?
    var longitude = 0.0
    var latitude = 0.0
    var eventType = ""
}

extension Event {
    static var preview: Event {
        let newEvent = Event(
            id: "1",
            name: "Snowport",
            startDate: Date(),
            endDate: Date().addingTimeInterval(35000),
            startTime: nil,
            endTime: nil,
            photo: nil,
            longitude: -71.044154694033,
            latitude: 42.3518324925221,
            eventType: "PopUp"
        )
        return newEvent
    }
}
