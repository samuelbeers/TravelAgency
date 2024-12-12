//
//  TravelAgencyApp.swift
//  TravelAgency
//
//  Created by Sam Beers on 11/18/24.
//

import SwiftUI

@main
struct TravelAgencyApp: App {
    @StateObject private var databaseManager = DatabaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BusinessModel())
                .environmentObject(TripManager(databaseManager: databaseManager))
                .environmentObject(databaseManager)
        }
    }
}
