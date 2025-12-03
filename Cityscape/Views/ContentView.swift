//
//  MapView.swift
//  Cityscape
//
//  Created by Jackson Butler on 10/8/25.
//

import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore

struct MapView: View {
    
    @FirestoreQuery(collectionPath: "events") var events: [Event]
    @State private var defaultEnable = true
    @State private var showBottomSheet = true
    @State var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                //TODO: incorporate Google Search Button
                
                Map(position: $cameraPosition) {
                    ForEach(events) { event in
                        Marker(coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)) {
                            Text(event.name)
                        }
                    }
                    
                    UserAnnotation()
                }
                .mapControls({
                    MapUserLocationButton()
                    MapCompass()
                })
                .mapStyle(.standard(pointsOfInterest: .including([.aquarium,.amusementPark,.beach,.bowling,.brewery,.museum,.zoo,.castle,.distillery,.landmark,.musicVenue,.publicTransport,.stadium,.winery])))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Sign Out") {
                            do {
                                try Auth.auth().signOut()
                                print("Sign out successful")
                                dismiss()
                            } catch {
                                print("ERROR: Could not sign out")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showBottomSheet) {
                BottomSheetView()
                // Heights: tweak these to match the feel you want
                    .presentationDetents([
                        .fraction(0.18),   // almost just a header
                        .fraction(0.35),   // mid
                        .large             // almost full-screen
                    ])
                // Show the little drag indicator at the top
                    .presentationDragIndicator(.visible)
                // Don't allow swiping down to fully dismiss
                    .interactiveDismissDisabled()
                // Allow interacting with the content behind the sheet
                    .presentationBackgroundInteraction(.enabled)
            }
            .onAppear {
                showBottomSheet = true
                if let region = locationManager.getRegionAroundCurrentLocation() {
                    cameraPosition = .region(region)
                }
            }
        }
    }
}


struct BottomSheetView: View {
    
    @FirestoreQuery(collectionPath: "events") var events: [Event]
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Optional: custom grabber if you want more control
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search for Event or Location", text: $searchText)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
            )
            .padding(.horizontal)
            
            // Main content of your sheet
            List {
                Section(header: Text("Nearby Events")) {
                    ForEach(events) { event in
                        HStack {
                            Image(systemName: "mappin.circle")
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.headline)
                                Text("\(event.endDate)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    MapView()
}
