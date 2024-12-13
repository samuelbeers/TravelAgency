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
            List(BM.testLocations, id: \.name) { location in
                NavigationLink(destination: LocationView(location: location)) {
                    VStack(alignment: .leading) {
                        Text(location.name)
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
