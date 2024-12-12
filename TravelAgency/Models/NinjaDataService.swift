//
//  NinjaDataService.swift
//  TravelAgency
//
//  Created by COMP401 on 12/12/24.
//

import Foundation

struct City: Decodable, Identifiable {
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

struct NinjaResponse: Decodable {
    var cities: [City]
}

class NinjaDataService {
    func getCities(minPopulation: Int = 1000000, limit: Int = 30) async -> [City] {
        let url = URL(string: "https://api.api-ninjas.com/v1/city?min_population=\(minPopulation)&limit=\(limit)")!
        var request = URLRequest(url: url)
        request.setValue("YOUR_NINJA_API_KEY", forHTTPHeaderField: "X-Api-Key")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let cities = try JSONDecoder().decode([City].self, from: data)
                print("Successfully retrieved \(cities.count) cities")
                return cities
            } else {
                print("Error: Received status code \(response)")
            }
        } catch {
            print("Request failed with error: \(error)")
        }
        
        return []
    }
}
