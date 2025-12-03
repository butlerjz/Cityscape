//
//  DetailView.swift
//  Cityscape
//
//  Created by Jackson Butler on 11/30/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DetailView: View {
    
    @State var event: Event
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            
            Text("\(event.name)")
                .frame(width: 200, height: 30)
                .font(Font.largeTitle.bold())
                .foregroundStyle(.blue)
                .padding(.vertical)
            
            Text("\(event.eventType)")
                .frame(width: 200, height: 10)
                .font(.title)
                .foregroundStyle(.cyan)
            
            Image(systemName: "plus") //TODO: change this to an image from firebase
                .resizable()
                .scaledToFit()
                .padding()
            
            Spacer()
            
            Text("Start Date:")
                .font(.title2)
                .bold()
            Text("\(event.startDate)")
            
            Spacer()
            
            if event.startTime != nil {
                Text("Start Time: \(event.startTime ?? Date())")
            }
            
            Spacer()
            
            Text("End Date:")
                .font(.title2)
                .bold()
            Text("\(event.endDate)")
            
            Spacer()
            
            if event.endTime != nil {
                Text("End Time: \(event.endTime ?? Date())")
            }
            
            Text("Event Description:")
                .font(.title2)
                .bold()
            
            Text(event.description ?? "No description available for this event.")
                .multilineTextAlignment(.leading)
            
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
    }
}

#Preview {
    NavigationStack {
        DetailView(event: Event.preview)
    }
}
