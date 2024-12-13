//
//  TripManager.swift
//  TravelAgency
//
//  Created by Sam Beers on 12/9/24.
//


import Foundation

class TripManager: ObservableObject {
    @Published var trips: [TripData] = []
    var databaseManager: DatabaseManager

    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        self.databaseManager.$trips
            .receive(on: DispatchQueue.main)
            .assign(to: &$trips)
    }
}

