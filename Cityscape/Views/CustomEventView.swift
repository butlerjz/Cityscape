//
//  CustomEventView.swift
//  Cityscape
//
//  Created by Jackson Butler on 12/2/25.
//

import SwiftUI
import MapKit

struct CustomEventView: View {
    
    @State var event: Event
    @State private var mapRadius: CLLocationDistance = 700 // meters
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @Environment(\.dismiss) private var dismiss
    
    let eventTypes = ["Popup", "Concert", "Theatre", "Sports", "Activity", "Other"]
    
    var body: some View {
        
        
        VStack {
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
                    .font(.title2)
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
                    Marker("Event Location",
                           coordinate: CLLocationCoordinate2D(latitude: event.latitude,
                                                              longitude: event.longitude))
                }
                .frame(height: 200)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Divider()
            
            //Start Date
            Text("Enter Event Start Date:")
                .bold()
                .font(.title2)
            DatePicker("Start Date", selection: $event.startDate)
            
            //End Date
            Text("Enter Event End Date:")
                .bold()
                .font(.title2)
            DatePicker("End Date", selection: $event.endDate)
            
            Divider()
            
            //Photo picker
            Text("Select a Photo For This Event:")
                .bold()
                .font(.title2)
            
            Divider()
            
            //Event type picker
            
            HStack {
                Text("Select Event Type:")
                    .bold()
                    .font(.title2)
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
                .font(.title2)
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
