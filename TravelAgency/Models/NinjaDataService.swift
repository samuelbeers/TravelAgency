//
//  NinjaDataService.swift
//  TravelAgency
//
//  Created by COMP401 on 12/12/24.
//

import Foundation

struct City: Decodable {
    var name: String
    var latitude: Double
    var longitude: Double
    var country: String
    var population: Int
    var region: String
    var is_capital: Bool
}

class NinjaDataService {
    func getCities(minPopulation: Int = 1000000, limit: Int = 30) async -> Result<[City], Error> {
        let urlString = "https://api.api-ninjas.com/v1/city?min_population=\(minPopulation)&limit=\(limit)"
        guard let url = URL(string: urlString) else {
            return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        var request = URLRequest(url: url)
        request.setValue("YOUR_NINJA_API_KEY", forHTTPHeaderField: "X-Api-Key")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let cities = try JSONDecoder().decode([City].self, from: data)
                    return .success(cities)
                } else {
                    let errorMessage = "Received status code \(httpResponse.statusCode)"
                    return .failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            } else {
                return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
        } catch {
            return .failure(error)
        }
    }
}
