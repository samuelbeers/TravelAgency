//
//  MapView.swift
//  TravelAgency
//
//  Created by COMP401 on 11/19/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var BM : BusinessModel
    @State var selectedMarkerId : String? = nil
    
    var body: some View {
        Map(selection: $selectedMarkerId){
            ForEach(BM.businesses){ b in
                Marker(b.name ?? "unknown", coordinate: CLLocationCoordinate2D(
                    latitude: b.coordinates?.latitude ?? 0, longitude: b.coordinates?.longitude ?? 0
                ))
                .tag(b.id ?? "None")
            }
        }.onChange(of: selectedMarkerId) { oldValue, newValue in
            let business = BM.businesses.first{ business in
                business.id == selectedMarkerId
            }
            if business != nil{
                BM.selectedBusiness = business
            }
        }
    }
}

#Preview {
    MapView()
        .environmentObject(BusinessModel())
}
