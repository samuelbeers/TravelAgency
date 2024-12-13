//
//  LocationView.swift
//  TravelAgency
//
//  Created by COMP401 on 11/20/24.
//

import SwiftUI
import CoreLocation

struct LocationView: View {
    @EnvironmentObject var BM: BusinessModel
    var location: Location
    @State private var showingWebsiteSheet = false
    
    var body: some View {
        VStack {
            Text(location.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            MapView()
                .frame(height: 300)
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.bottom, 5)
            List(BM.businesses) { business in
                Button(action: {
                    BM.selectBusiness(business)
                    showingWebsiteSheet.toggle()
                }) {
                    VStack(alignment: .leading) {
                        Text(business.name ?? "Unknown")
                            .font(.headline)
                            .padding(.bottom, 5)
                            .foregroundStyle(.black)
                        StarRatingView(rating: business.rating ?? 0.0)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .sheet(isPresented: $showingWebsiteSheet, content: {
            if let business = BM.selectedBusiness, let url = business.url {
                LocationWebView(urlString: url)
            } else {
                LocationWebView(urlString: "https://www.google.com")
            }
        })
        .onAppear {
            BM.getBusiness(
                category: "Food",
                coordinate: CLLocationCoordinate2D(latitude: location.coords.latitude, longitude: location.coords.longitude)
            )
        }
    }
}


struct StarRatingView: View {
    let rating: Double
    private let maxRating = 5
    
    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= Int(rating) ? "star.fill" : (rating > Double(index - 1) ? "star.lefthalf.fill" : "star"))
                    .foregroundColor(.yellow)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("\(rating) out of \(maxRating) stars")
    }
}

#Preview {
    LocationView(location: Location(name: "New York", coords: Coordinate(latitude: 40.730610, longitude: -73.935242)))
        .environmentObject(BusinessModel())
}

