//
//  ContentView.swift
//  TravelAgency
//
//  Created by Sam Beers on 11/18/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            TripBuilderView()
                .tabItem {
                    Image(systemName: "airplane")
                    Text("Trip Builder")
                }
            
            PopularView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Popular Locations")
                }
            
            YourTripsView()
                .tabItem {
                    Image(systemName: "case.fill")
                    Text("Your Trips")
                }
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BusinessModel())
        .environmentObject(TripManager())
        .environmentObject(DatabaseManager())
}
