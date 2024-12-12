//
//  PopularView.swift
//  TravelAgency
//
//  Created by Sam Beers on 11/18/24.
//

import SwiftUI

struct PopularView: View {
    @EnvironmentObject var BM: BusinessModel
    
    var body: some View {
        NavigationView {
            List(BM.cities, id: \.name) { city in
                NavigationLink(destination: LocationView(location: Location(name: city.name, coords: Coordinate(latitude: city.latitude, longitude: city.longitude)))) {
                    VStack(alignment: .leading) {
                        Text(city.name)
                            .font(.largeTitle)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Popular Locations")
        }
    }
}

#Preview {
    PopularView()
        .environmentObject(BusinessModel())
}
