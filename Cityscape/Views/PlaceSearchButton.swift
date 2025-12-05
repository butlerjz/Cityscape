//
//  PlaceSearchButton.swift
//  Hackathon
//
//  Created by Jackson Butler on 12/1/25.
//

import SwiftUI
import GooglePlacesSwift
import CoreLocation

/// A button that presents a full-screen Google Places autocomplete interface
/// and returns the selected place via a callback
struct PlaceSearchButton: View {
    
    //Properties
    
    /// Text displayed on the button
    let buttonText: String
    
    /// Callback when a place is successfully selected
    let onPlaceSelected: (PlaceResult) -> Void
    
    //State
    
    @State private var showAutocomplete = false
    
    /// Indicates when we're fetching place details
    @State private var isLoading = false
    
    /// Stores any error message to display
    @State private var errorMessage: String?
    
    //Initialization
    
    /// Creates a new PlaceSearchButton
    /// - Parameters:
    ///   - buttonText: The text to display on the button (default: "Search for a Place")
    ///   - onPlaceSelected: Callback that receives the selected PlaceResult
    init(
        _ buttonText: String = "Search for a Place",
        onPlaceSelected: @escaping (PlaceResult) -> Void
    ) {
        self.buttonText = buttonText
        self.onPlaceSelected = onPlaceSelected
    }
    
    //Body
    
    var body: some View {
        Button {
            errorMessage = nil
            showAutocomplete = true
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Label(buttonText, systemImage: "magnifyingglass")
            }
        }
        .disabled(isLoading)
        // Attach the Google Places autocomplete modifier
        .placeAutocomplete(
            show: $showAutocomplete,
            onSelection: { suggestion, sessionToken in
                handlePlaceSelection(suggestion: suggestion, token: sessionToken)
            },
            onError: { error in
                errorMessage = error.localizedDescription
                print("Places Autocomplete Error: \(error)")
            }
        )
        // Show error alert if something goes wrong
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    //Private Methods
    
    private func handlePlaceSelection(
        suggestion: AutocompletePlaceSuggestion,
        token: AutocompleteSessionToken
    ) {
        isLoading = true
        
        Task {
            await fetchPlaceDetails(placeID: suggestion.placeID, token: token)
        }
    }
    
    /// Fetches full place details from the Places API
    /// - Parameters:
    ///   - placeID: The unique identifier of the place
    ///   - token: Session token to associate with the request
    private func fetchPlaceDetails(
        placeID: String,
        token: AutocompleteSessionToken
    ) async {
        let request = FetchPlaceRequest(
            placeID: placeID,
            placeProperties: [
                .displayName,       // The place's name
                .formattedAddress,  // Full formatted address
                .coordinate
            ],
            sessionToken: token
        )
        
        let placesClient = PlacesClient.shared
        let result = await placesClient.fetchPlace(with: request)
        
        await MainActor.run {
            isLoading = false
            
            switch result {
            case .success(let place):
                let placeResult = PlaceResult(
                    id: placeID,
                    name: place.displayName ?? "Unknown Place",
                    address: place.formattedAddress ?? "No address available",
                    latitude: place.location.latitude,
                    longitude: place.location.longitude
                )
                onPlaceSelected(placeResult)
                
            case .failure(let error):
                errorMessage = "Failed to fetch place details: \(error.localizedDescription)"
            }
        }
    }
    
}

// MARK: - Preview

#Preview {
    PlaceSearchButton { place in
        print("Selected: \(place.name)")
        print("Address: \(place.address)")
        print("Coordinates: \(place.latitude), \(place.longitude)")
    }
    .buttonStyle(.borderedProminent)
}
