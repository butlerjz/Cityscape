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
    @State private var mapRadius: CLLocationDistance = 200 // meters
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var photo = Photo()
    @State private var data = Data()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Name
                GroupBox("Event Name") {
                    TextField("Event Name", text: $event.name)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Location selection
                GroupBox("Location") {
                    VStack(alignment: .leading, spacing: 12) {
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
                        
                        if event.longitude != 0.0 && event.latitude != 0.0 {
                            Map(position: $mapCameraPosition) {
                                Marker(event.name,
                                       coordinate: CLLocationCoordinate2D(latitude: event.latitude,
                                                                          longitude: event.longitude))
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
                // Start-End
                GroupBox("Event Time") {
                    VStack(alignment: .leading, spacing: 8) {
                        DatePicker("Start", selection: $event.startDate)
                        DatePicker("End", selection: $event.endDate)
                    }
                }
                
                // Photo picker
                GroupBox("Photo") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            PhotosPicker(selection: $selectedPhoto,
                                         matching: .images,
                                         preferredItemEncoding: .automatic) {
                                Label("Select Photo", systemImage: "photo")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        if let selectedImage {
                            selectedImage
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .clipped()
                        }
                    }
                    .onChange(of: selectedPhoto) {
                        Task {
                            do {
                                if let image = try await selectedPhoto?.loadTransferable(type: Image.self) {
                                    selectedImage = image
                                }
                                // Get raw data from image so we can save it to Firebase Storage
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
                
                // Event type picker
                GroupBox("Event Type") {
                    Picker("Type", selection: $event.eventType) {
                        ForEach(EventType.allCases) { type in
                            Text(type.rawValue).tag(Optional(type))
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Description
                GroupBox("Description") {
                    TextEditor(text: $event.description)
                        .frame(minHeight: 120)
                }
            }
            .padding()
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
    }
}

#Preview {
    NavigationStack {
        CustomEventView(event: Event.preview)
    }
}
