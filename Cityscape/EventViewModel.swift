//
//  EventViewModel.swift
//  Cityscape
//
//  Created by Jackson Butler on 12/1/25.
//

import Foundation
import FirebaseFirestore

@Observable
class EventViewModel {
    
    static func saveEvent(event: Event) async -> String? {
        let db = Firestore.firestore()
        
        if let id = event.id { //if true, the place exists
            do {
                try db.collection("events").document(id).setData(from: event)
                print("Data updated successfully")
                return id
            } catch {
                print("ERROR: Could not update data in events. \(error.localizedDescription)")
                return id
            }
            
        } else { //This must be a new event with no id
            do {
                let docref = try db.collection("events").addDocument(from: event)
                print("Data added successfully")
                return docref.documentID
            } catch {
                print("ERROR: Could not create a new event in events. \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    static func deleteEvent(event: Event) {
        let db = Firestore.firestore()
        
        guard let id = event.id else {
            print("ERROR: Tried to delete event with no ID")
            return
        }
        
        Task {
            do {
                try await db.collection("events").document(id).delete()
                print("Successfully deleted!")
            } catch {
                print("ERROR: Could not delete document id. \(error.localizedDescription)")
            }
        }
    }
}
