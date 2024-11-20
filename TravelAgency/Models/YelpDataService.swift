//
//  YelpDataService.swift
//  TravelAgency
//
//  Created by COMP401 on 11/19/24.
//

import Foundation
import CoreLocation

struct Location : Decodable {
    var name: String
    var coords: Coordinate
}

struct Coordinate : Decodable {
    var latitude: Double
    var longitude: Double
}

struct Business : Decodable, Identifiable{
    var id: String?
    var name: String?
    var image_url : String?
    var is_closed: Bool?
    var url: String?
    var rating: Double?
    var coordinates: Coordinate?
    var phone: String?
    var distance : Double?
    enum CodingKeys: CodingKey {
        case id
        case name
        case image_url
        case is_closed
        case url
        case rating
        case coordinates
        case phone
        case distance
    }
}

struct YelpResponse : Decodable{
    var businesses : [Business]
    var total: Int = 0
    enum CodingKeys: CodingKey {
        case businesses
        case total
    }
}

class YelpDataService {
    func getBusiness(category: String, coordinate: CLLocationCoordinate2D? = nil) async -> [Business] {
        var lat = 0.0
        var long = 0.0
        if coordinate != nil {
            lat = coordinate!.latitude
            long = coordinate!.longitude
        }
        var urlComponent = URLComponents(string: "https://api.yelp.com/v3/businesses/search")
        urlComponent?.queryItems = [
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "categories", value: category),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "radius", value: "2000")
        ]
        if let url = urlComponent?.url{
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(Utility.YELP_API_KEY)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "accept")
            do{
                let (data, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse{
                    if httpResponse.statusCode == 200{
                        let yelpResponse = try JSONDecoder().decode(YelpResponse.self, from: data)
                        print("succeed \(yelpResponse.total) received" )
                        return yelpResponse.businesses
                    }else{
                        print("return statusCode \(httpResponse.statusCode)")
                    }
                }
            }catch{
                print(error)
            }
        }
        return [Business]()
    }
}
