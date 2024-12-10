//
//  TripMapView.swift
//  TravelAgency
//
//  Created by Sam Beers on 12/10/24.
//

import SwiftUI
import MapKit

struct TripMapView: View {
    var startingLocation: String
    var destination: String

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // placeholder, defaulted to san francisco
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    )
    @State private var annotations: [MapAnnotationItem] = []
    @State private var routePolyline: MKPolyline?

    var body: some View {
        Map {
            ForEach(annotations) { annotation in
                Marker(annotation.title, coordinate: annotation.coordinate)
            }

            if let routePolyline {
                MapPolyline(routePolyline)
                    .stroke(.blue, lineWidth: 3)
            }
        }
        .mapStyle(.standard)
        .safeAreaInset(edge: .bottom) {
            Text("Route between \(startingLocation) and \(destination)")
                .padding()
                .background(.ultraThinMaterial)
        }
        .onAppear {
            calculateRoute()
        }
        .navigationTitle("Route to \(destination)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func calculateRoute() {
        let geocoder = CLGeocoder()

        // geocode starting location
        geocoder.geocodeAddressString(startingLocation) { (startPlacemarks, error) in
            guard let startPlacemark = startPlacemarks?.first else { return }

            // geocode destination
            geocoder.geocodeAddressString(destination) { (endPlacemarks, error) in
                guard let endPlacemark = endPlacemarks?.first else { return }

                let startMapItem = MKMapItem(placemark: MKPlacemark(placemark: startPlacemark))
                let endMapItem = MKMapItem(placemark: MKPlacemark(placemark: endPlacemark))

                let request = MKDirections.Request()
                request.source = startMapItem
                request.destination = endMapItem
                request.transportType = .automobile

                let directions = MKDirections(request: request)
                directions.calculate { response, error in
                    if let route = response?.routes.first {
                        self.routePolyline = route.polyline
                        self.region = MKCoordinateRegion(route.polyline.boundingMapRect)

                        self.annotations = [
                            MapAnnotationItem(coordinate: startPlacemark.location!.coordinate, title: "Start"),
                            MapAnnotationItem(coordinate: endPlacemark.location!.coordinate, title: "End")
                        ]
                    }
                }
            }
        }
    }
}

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}
