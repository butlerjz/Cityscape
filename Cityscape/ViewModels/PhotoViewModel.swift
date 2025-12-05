//
//  PhotoViewModel.swift
//  SnacktacularUI
//
//  Created by Jackson Butler on 11/9/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftUI
import FirebaseFirestore

class PhotoViewModel {
    static func saveImage(event: Event, photo: Photo, data: Data) async {
        guard let id = event.id else {
            print("ERROR: Should not have been called without event.id")
            return
        }
        
        let storage = Storage.storage().reference()
        let metadata = StorageMetadata()
        if photo.id == nil {
            photo.id = UUID().uuidString
        }
        metadata.contentType = "image/jpeg" // will allow image to be viewed in browser
        let path = "\(id)\(photo.id ?? "n/a")" //id is the name of the Spot document (spot.id). All photos for a spot will be saved in a "folder" with its spot document name
        
        do {
            let storageRef = storage.child(path)
            let returnedMetaData = try await storageRef.putDataAsync(data, metadata: metadata)
            print("SAVED \(returnedMetaData)")
            //get URL to load image
            guard let url = try? await storageRef.downloadURL() else {
                print("ERROR: could not get download url")
                return
            }
            photo.imageURLString = url.absoluteString
            print("photo.imageURLString: \(photo.imageURLString)")
            
            //Now that photo file is saved to Storage, save a Photo document to the spot.id's photos collection
            let db = Firestore.firestore()
            do {
                try db.collection("events").document(id).collection("photos").document(photo.id ?? "n/a").setData(from: photo)
                    
            } catch {
                print("ERROR: Could not update data in events/\(id)/photos\(photo.id ?? "n/a"). \(error.localizedDescription)")
            }
        } catch {
            print("ERROR saving photo to storage \(error.localizedDescription)")
        }
    }
}
