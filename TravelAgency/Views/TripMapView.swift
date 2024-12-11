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
        center: CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00), // placeholder
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    )
    @State private var annotations: [MapAnnotationItem] = []
    @State private var routePolyline: MKPolyline?

    var body: some View {
        CustomMapView(region: $region, annotations: annotations, routePolyline: routePolyline)
            .safeAreaInset(edge: .bottom) {
                Text("Route between \(startingLocation) and \(destination)")
                    .padding()
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
                        var region = MKCoordinateRegion(route.polyline.boundingMapRect)
                        
                        let zoomAdjustment: CLLocationDegrees = 1.4
                        region.span.latitudeDelta += zoomAdjustment
                        region.span.longitudeDelta += zoomAdjustment

                        self.region = region

                        self.annotations = [
                            MapAnnotationItem(coordinate: startPlacemark.location!.coordinate, title: "Start", imageName: "airplane"),
                            MapAnnotationItem(coordinate: endPlacemark.location!.coordinate, title: "End", imageName: "house.fill")
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
    let imageName: String
}

struct CustomMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotations: [MapAnnotationItem]
    var routePolyline: MKPolyline?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        let region = MKCoordinateRegion(
            center: region.center,
            span: region.span
        )
        uiView.setRegion(region, animated: true)

        for annotation in annotations {
            let mapAnnotation = CustomMapAnnotation(coordinate: annotation.coordinate, title: annotation.title, imageName: annotation.imageName)
            uiView.addAnnotation(mapAnnotation)
        }

        if let routePolyline {
            uiView.addOverlay(routePolyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let customAnnotation = annotation as? CustomMapAnnotation else { return nil }
            
            let identifier = "customAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            // Set the image based on the imageName
            annotationView?.image = UIImage(systemName: customAnnotation.imageName)
            
            return annotationView
        }
    }
}

class CustomMapAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let imageName: String

    init(coordinate: CLLocationCoordinate2D, title: String?, imageName: String) {
        self.coordinate = coordinate
        self.title = title
        self.imageName = imageName
        super.init()
    }
}

#if DEBUG
struct TripMapView_Previews: PreviewProvider {
    static var previews: some View {
        TripMapView(startingLocation: "New York, NY", destination: "Miami")
    }
}
#endif
