//
//  Photo.swift
//  Cityscape
//
//  Created by Jackson Butler on 11/30/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = "" //this will hold the URL string
    var description = ""
    var reviewer: String = Auth.auth().currentUser?.email ?? ""
    var postedOn: Date = Date()
    
    init(id: String? = nil, imageURLString: String = "", description: String = "", reviewer: String, postedOn: Date) {
        self.id = id
        self.imageURLString = imageURLString
        self.description = description
        self.reviewer = reviewer
        self.postedOn = postedOn
    }
}
