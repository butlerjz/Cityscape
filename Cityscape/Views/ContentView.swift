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
    @State private var showCreateEventSheet = false
    @State var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedEvent: Event?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                Map(position: $cameraPosition, selection: $selectedEvent) {
                    ForEach(events) { event in
                        
                        let coordinate = CLLocationCoordinate2D(latitude: event.latitude,
                                                                longitude: event.longitude)
                        
                        Marker(event.name, coordinate: coordinate)
                            .tag(event)
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
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showBottomSheet.toggle()
                            showCreateEventSheet.toggle()
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedEvent) { event in
                DetailView(event: event)
            }
            .sheet(isPresented: $showBottomSheet) {
                BottomSheetView { event in
                    let coord = CLLocationCoordinate2D(latitude: event.latitude,
                                                       longitude: event.longitude)
                    
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: coord,
                                latitudinalMeters: 1000,    // adjust zoom as desired
                                longitudinalMeters: 1000
                            )
                        )
                    }
                }
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
            .sheet(isPresented: $showCreateEventSheet, onDismiss: {
                showCreateEventSheet.toggle()
                showBottomSheet.toggle()
            }) {
                NavigationStack {
                    CustomEventView(event: Event())
                }
            }
            .onChange(of: selectedEvent) { _, newValue in
                if newValue != nil {
                    // Navigated to DetailView, hide bottom sheet
                    showBottomSheet = false
                } else {
                    // Returned from DetailView, show bottom sheet again
                    showBottomSheet = true
                }
            }
            .onAppear {
                showBottomSheet = true
                }
            }
        }
    }



struct BottomSheetView: View {
    
    @FirestoreQuery(collectionPath: "events") var events: [Event]
    @State private var searchText = ""
    /// Called when the user taps an event in the list
    var onEventSelected: (Event) -> Void
    
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
                        .contentShape(Rectangle()) // make whole row tappable
                        .onTapGesture {
                            onEventSelected(event)
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
