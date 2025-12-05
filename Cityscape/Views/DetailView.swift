//
//  DetailView.swift
//  Cityscape
//
//  Created by Jackson Butler on 11/30/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct DetailView: View {
    
    @FirestoreQuery(collectionPath: "events") var photos: [Photo]
    @State var event: Event
    @Environment(\.dismiss) private var dismiss
    
    private var startDateTimeText: String {
        let date = event.startTime ?? event.startDate
        return date.formatted(date: .abbreviated, time: .shortened)
    }
    
    private var endDateTimeText: String {
        let date = event.endTime ?? event.endDate
        return date.formatted(date: .abbreviated, time: .shortened)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Hero image / photo section
                Group {
                    if !photos.isEmpty {
                        TabView {
                            ForEach(photos) { photo in
                                if let url = URL(string: photo.imageURLString) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ZStack {
                                            Rectangle()
                                                .fill(.thinMaterial)
                                            ProgressView()
                                        }
                                    }
                                } else {
                                    ZStack {
                                        Rectangle()
                                            .fill(.thinMaterial)
                                        Image(systemName: "photo")
                                            .font(.largeTitle)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .tabViewStyle(.page)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.thinMaterial)
                                .frame(height: 220)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40, weight: .regular))
                                    .foregroundStyle(.secondary)
                                Text("No photo available")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                // Title + type chip
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.name)
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let type = event.eventType {
                        Text(type.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.12))
                            )
                            .foregroundStyle(.blue)
                    }
                }
                
                // When section
                GroupBox("When") {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "calendar")
                            Text(startDateTimeText)
                        }
                        .font(.subheadline)
                        
                        Image(systemName: "arrow.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 2)
                        
                        HStack {
                            Image(systemName: "flag.checkered")
                            Text(endDateTimeText)
                        }
                        .font(.subheadline)
                    }
                }
                
                // Description section
                GroupBox("About this event") {
                    if event.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("No description provided.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(event.description)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            $photos.path = "events/\(event.id ?? "")/photos"
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(event: Event.preview)
    }
}
