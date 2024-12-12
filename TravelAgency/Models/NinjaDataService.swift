//
//  NinjaDataService.swift
//  TravelAgency
//
//  Created by COMP401 on 12/12/24.
//

import Foundation

struct City : Decodable, Identifiable {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var country: String
    var population: Int
    var region: String
    var is_capital: Bool
    enum CodingKeys: CodingKey {
        case id
        case name
        case latitude
        case longitude
        case country
        case population
        case region
        case is_capital
    }
}

struct NinjaResponse : Decodable {
    var cities: [City]
}

class NinjaDataService {
    func getCities(minPopulation: Int = 1000000) async -> [City] {
        let url = URL(string: "https://api.api-ninjas.com/v1/city?min_population=\(minPopulation)&limit=30")!
        var request = URLRequest(url: url)
        request.setValue("\(Utility.NINJA_API_KEY)", forHTTPHeaderField: "X-Api-Key")
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let ninjaResponse = try JSONDecoder().decode(NinjaResponse.self, from: data)
                    print("succeed \(ninjaResponse.cities.count) received")
                    return ninjaResponse.cities
                } else {
                    print("return statusCode \(httpResponse.statusCode)")
                }
            }
        } catch {
            print(error)
        }
        return [City]()
    }
}
