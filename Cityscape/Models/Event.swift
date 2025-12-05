//
//  Event.swift
//  Cityscape
//
//  Created by Jackson Butler on 11/30/25.
//

import Foundation
import FirebaseFirestore

struct Event: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name = ""
    var startDate: Date = Date()
    var endDate: Date = Date().addingTimeInterval(86400)
    var startTime: Date?
    var endTime: Date?
    var photo: Photo?
    var longitude = 0.0
    var latitude = 0.0
    var eventType: EventType?
    var description: String = ""
}

enum EventType: String, Codable, CaseIterable, Identifiable {
    case market = "Market"
    case exhibit = "Exhibit"
    case tour = "Tour"
    case popup = "Popup"
    case concert = "Concert"
    case theatre = "Theatre"
    case comedy = "Comedy"
    case sports = "Sports"
    case athletics = "Athletics"
    case food = "Food"
    case cultural = "Cultural"
    case parade = "Parade"
    case networking = "Networking"
    case other = "Other"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .market: return "cart"
        case .popup: return "sparkles"
        case .concert: return "music.mic"
        case .theatre: return "theatermasks"
        case .sports: return "sportscourt"
        case .athletics: return "figure.run"
        case .other: return "mappin.circle"
        case .parade: return "flag.fill"
        case .networking: return "person.3.sequence.fill"
        case .tour: return "map"
        case .comedy: return "face.smiling"
        case .exhibit: return "building.columns"
        case .cultural: return "globe.europe.africa"
        case .food: return "fork.knife"
        }
    }
}

extension Event {
    static var preview: Event {
        let newEvent = Event(
            id: "1",
            name: "Snowport",
            startDate: Date(),
            endDate: Date().addingTimeInterval(1000000),
            startTime: nil,
            endTime: nil,
            photo: nil,
            longitude: -71.044154694033,
            latitude: 42.3518324925221,
            eventType: .popup,
            description: "A winter market in the heart of Boston's Seaport District"
        )
        return newEvent
    }
}
