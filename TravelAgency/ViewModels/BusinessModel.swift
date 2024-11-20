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
    @Published var currentLocation : CLLocationCoordinate2D? = nil
    @Published var selectedBusiness : Business? = nil
    @Published var testLocations: [Location] = [Location(name: "New York", coords: Coordinate(latitude: 40.730610, longitude: -73.935242)), Location(name: "Los Angeles", coords: Coordinate(latitude: 34.052235, longitude: -118.243683)), Location(name: "Chicago", coords: Coordinate(latitude: 41.881832, longitude: -87.623177)), Location(name: "San Francisco", coords: Coordinate(latitude: 37.773972, longitude: -122.431297)), Location(name: "Miami", coords: Coordinate(latitude: 25.793449, longitude: -80.139198))]
    var yelpService = YelpDataService()
    var locationManager  = CLLocationManager()
    
    override init(){
        super.init()
        locationManager.delegate = self
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
}
