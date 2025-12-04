//
//  CustomEventView.swift
//  Cityscape
//
//  Created by Jackson Butler on 12/2/25.
//

import SwiftUI
import MapKit
import PhotosUI

struct CustomEventView: View {
    
    @State var event: Event
    @State private var mapRadius: CLLocationDistance = 700 // meters
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var photo = Photo()
    @State private var data = Data()
    @Environment(\.dismiss) private var dismiss
    
    let eventTypes = ["Popup", "Concert", "Theatre", "Sports", "Activity", "Other"]
    
    var body: some View {
        
        
        VStack(alignment: .leading) {
            //Name
            HStack {
                Text("Enter Event Name:")
                    .bold()
                    .font(.title3)
                TextField("Event Name", text: $event.name)
                    .textFieldStyle(.plain)
            }
            
            Divider()
            
            //Location selection
            HStack {
                Text("Choose Event \nLocation:")
                    .bold()
                    .font(.title3)
                PlaceSearchButton("Select Event Location") { result in
                    event.latitude = result.latitude
                    event.longitude = result.longitude
                    let coordinate = CLLocationCoordinate2D(latitude: result.latitude,
                                                           longitude: result.longitude)
                    let region = MKCoordinateRegion(
                        center: coordinate,
                        latitudinalMeters: mapRadius,
                        longitudinalMeters: mapRadius
                    )
                    mapCameraPosition = .region(region)
                }
                .buttonStyle(.glassProminent)
            }
            
            if event.longitude != 0.0 && event.latitude != 0.0 {
                Map(position: $mapCameraPosition) {
                    Marker(event.name,
                           coordinate: CLLocationCoordinate2D(latitude: event.latitude,
                                                              longitude: event.longitude))
                }
                .frame(height: 200)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Divider()
            
            //Start-End
            Text("Event Start and End:")
                .bold()
                .font(.title3)
            DatePicker("Start Date", selection: $event.startDate)
            DatePicker("End Date", selection: $event.endDate)
            
            Divider()
            
            //Photo picker
            HStack {
                Text("Select a Photo:")
                    .bold()
                    .font(.title3)
                
                Spacer()
                
                PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                        Image(systemName: "photo")
                        Text("Photo")
                }
                .buttonStyle(.glassProminent)
                .onChange(of: selectedPhoto) {
                    Task {
                        do {
                            if let image = try await selectedPhoto?.loadTransferable(type: Image.self) {
                                selectedImage = image
                            }
                            // Get raw data from image so we can save it to Firabase Storage
                            guard let transferredData = try await selectedPhoto?.loadTransferable(type: Data.self) else {
                                print("ERROR: Could not convert data from selectedPhoto")
                                return
                            }
                            data = transferredData
                        } catch {
                            print("ERROR: could not create image from selectedPhoto. \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            Divider()
            
            //Event type picker
            
            HStack {
                Text("Select Event Type:")
                    .bold()
                    .font(.title3)
                Picker("Select Type", selection: $event.eventType) {
                    ForEach(eventTypes, id: \.self) { type in
                        Text(type).tag(Optional(type))
                    }
                }
                .pickerStyle(.menu)
            }
            
            Divider()
            
            //Description
            Text("Write Event Description:")
                .bold()
                .font(.title3)
            TextField("Description", text: $event.description, axis: .vertical)
                .padding(.horizontal)
            
            Spacer()
            
            
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    Task {
                        await PhotoViewModel.saveImage(event: event, photo: photo, data: data)
                    }
                    Task {
                       let id = await EventViewModel.saveEvent(event: event)
                        if id == nil {
                            print("ERROR: Save on DetailView did not work")
                        } else {
                            dismiss()
                        }
                    }
                    dismiss()
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        CustomEventView(event: Event.preview)
    }
}
