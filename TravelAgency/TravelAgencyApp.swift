//
//  TravelAgencyApp.swift
//  TravelAgency
//
//  Created by Sam Beers on 11/18/24.
//

import SwiftUI

@main
struct TravelAgencyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BusinessModel())
                .environmentObject(TripManager())
                .environmentObject(DatabaseManager())
        }
    }
}
