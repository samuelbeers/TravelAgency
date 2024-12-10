//
//  YourTripsView.swift
//  TravelAgency
//
//  Created by Sam Beers on 11/18/24.
//

import SwiftUI

struct YourTripsView: View {
    @EnvironmentObject var tripManager: TripManager
    
    var body: some View {
        NavigationView {
            List(tripManager.trips, id: \.price) { trip in
                NavigationLink(destination: TripMapView(startingLocation: trip.startingLocation, destination: trip.destination)) {
                    VStack(alignment: .leading) {
                        Text("From: \(trip.startingLocation)")
                            .font(.headline)
                        Text("To: \(trip.destination)")
                        Text("Price: \(trip.price)")
                        Text("Duration: \(trip.totalTime)")
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Trips")
        }
    }
}

#Preview {
    YourTripsView()
        .environmentObject(TripManager())
}


