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
            let tmp = await ninjaService.getCities()
            await MainActor.run {
                cities = tmp
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
}
