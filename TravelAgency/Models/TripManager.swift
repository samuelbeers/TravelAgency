//
//  TripManager.swift
//  TravelAgency
//
//  Created by Sam Beers on 12/9/24.
//


import Foundation

class TripManager: ObservableObject {
    @Published var trips: [TripData] = []
}

