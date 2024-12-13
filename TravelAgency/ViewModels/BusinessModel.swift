//
//  BusinessModel.swift
//  TravelAgency
//
//  Created by COMP401 on 11/19/24.
//

import Foundation
import CoreLocation

class BusinessModel : NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var businesses = [Business]()
    @Published var cities = [City]()
    @Published var currentLocation : CLLocationCoordinate2D? = nil
    @Published var selectedBusiness : Business? = nil
    @Published var testLocations: [Location] = [
        Location(name: "New York", coords: Coordinate(latitude: 40.730610, longitude: -73.935242)),
        Location(name: "Los Angeles", coords: Coordinate(latitude: 34.052235, longitude: -118.243683)),
        Location(name: "Chicago", coords: Coordinate(latitude: 41.881832, longitude: -87.623177)),
        Location(name: "San Francisco", coords: Coordinate(latitude: 37.773972, longitude: -122.431297)),
        Location(name: "Miami", coords: Coordinate(latitude: 25.793449, longitude: -80.139198)),
        Location(name: "London", coords: Coordinate(latitude: 51.507222, longitude: -0.127500)),
        Location(name: "Paris", coords: Coordinate(latitude: 48.856613, longitude: 2.352222)),
        Location(name: "Berlin", coords: Coordinate(latitude: 52.520008, longitude: 13.404954)),
        Location(name: "Rome", coords: Coordinate(latitude: 41.902782, longitude: 12.496366)),
        Location(name: "Madrid", coords: Coordinate(latitude: 40.416775, longitude: -3.703790)),
        Location(name: "Boston", coords: Coordinate(latitude: 42.360081, longitude: -71.058884)),
        Location(name: "Denver", coords: Coordinate(latitude: 39.739235, longitude: -104.990250)),
        Location(name: "Las Vegas", coords: Coordinate(latitude: 36.169941, longitude: -115.139832)),
        Location(name: "Houston", coords: Coordinate(latitude: 29.760427, longitude: -95.369804)),
        Location(name: "Phoenix", coords: Coordinate(latitude: 33.448376, longitude: -112.074036))
    ]

    var yelpService = YelpDataService()
    var ninjaService = NinjaDataService()
    var locationManager  = CLLocationManager()
    
    override init(){
        super.init()
        locationManager.delegate = self
        fetchCities()
    }
    
    func fetchCities() {
        Task {
            let result = await ninjaService.getCities()
            await MainActor.run {
                if let fetchedCities = try? result.get() {
                    cities = fetchedCities
                }
            }
        }
    }
    
    func getBusiness(category: String, coordinate: CLLocationCoordinate2D? = nil){
        Task{
            let tmp  = await yelpService.getBusiness(category: category, coordinate: coordinate)
            await MainActor.run{
                businesses = tmp
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
    
    func selectBusiness(_ business: Business) {
            selectedBusiness = business
        }
}
