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

enum ActiveSheet: Identifiable {
    case bottom
    case create
    
    var id: Int {
        switch self {
        case .bottom: return 0
        case .create: return 1
        }
    }
}

struct MapView: View {
    
    @FirestoreQuery(collectionPath: "events") var events: [Event]
    @State private var defaultEnable = true
    @State private var activeSheet: ActiveSheet? = .bottom
    @State private var lastPresentedSheet: ActiveSheet? = .bottom
    @State private var bottomSheetDetent: PresentationDetent = .fraction(0.35)
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
                        Marker(event.name,
                               systemImage: event.eventType?.iconName ?? "mappin.circle",
                               coordinate: coordinate)
                            .tag(event)
                    }
                    .tint(Color("cityscapePrimary"))
                    
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
                            // Open the create-event sheet
                            activeSheet = .create
                            lastPresentedSheet = .create
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedEvent) { event in
                DetailView(event: event)
            }
            .sheet(item: $activeSheet, onDismiss: {
                // When a sheet is dismissed, if it was the create sheet,
                // restore the bottom sheet; if it was the bottom sheet,
                // do nothing.
                if lastPresentedSheet == .create {
                    activeSheet = .bottom
                    lastPresentedSheet = .bottom
                }
            }) { sheet in
                switch sheet {
                case .bottom:
                    BottomSheetView(userLocation: locationManager.location?.coordinate) { event in
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
                    .presentationDetents(
                        [.fraction(0.18), .fraction(0.35), .large],
                        selection: $bottomSheetDetent
                    )
                    // Show the little drag indicator at the top
                    .presentationDragIndicator(.visible)
                    // Don't allow swiping down to fully dismiss
                    .interactiveDismissDisabled()
                    // Allow interacting with the content behind the sheet
                    .presentationBackgroundInteraction(.enabled)
                    
                case .create:
                    NavigationStack {
                        CustomEventView(event: Event())
                    }
                }
            }
            .onChange(of: selectedEvent) { _, newValue in
                if newValue != nil {
                    activeSheet = nil
                } else {
                    activeSheet = .bottom
                    lastPresentedSheet = .bottom
                }
            }
            .onAppear {
                // Ensure the bottom sheet is visible on first load
                activeSheet = .bottom
                lastPresentedSheet = .bottom
                }
            }
        }
    }



struct BottomSheetView: View {
    
    @FirestoreQuery(collectionPath: "events") var events: [Event]
    @State private var searchText = ""
    var userLocation: CLLocationCoordinate2D?
    
    private var sortedEvents: [Event] {
        guard let userLocation else { return events }

        let userLoc = CLLocation(latitude: userLocation.latitude,
                                 longitude: userLocation.longitude)

        return events.sorted { e1, e2 in
            let loc1 = CLLocation(latitude: e1.latitude, longitude: e1.longitude)
            let loc2 = CLLocation(latitude: e2.latitude, longitude: e2.longitude)
            return userLoc.distance(from: loc1) < userLoc.distance(from: loc2)
        }
    }

    private var visibleEvents: [Event] {
        let base = sortedEvents
        guard !searchText.isEmpty else { return base }
        return base.filter { event in
            event.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
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
                TextField("Search for Event", text: $searchText)
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
                    ForEach(visibleEvents) { event in
                        HStack {
                            Image(systemName: event.eventType?.iconName ?? "mappin.circle")
                                .foregroundStyle(Color("cityscapePrimary"))
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.headline)
                                    .foregroundStyle(Color("cityscapeSecondary"))
                                Text("Until \(event.endDate.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
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
