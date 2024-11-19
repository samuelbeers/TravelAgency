import SwiftUI

struct TripBuilderView: View {
    @State var startingLocation: String = ""
    @State var destination: String = ""
    @State var showWeb: Bool = false
    @State var urlString: String = ""
    @State var savedtrip: String? = nil
    
    let locations = ["New York", "Los Angeles", "Chicago", "San Francisco", "Miami"]
    
    var body: some View {
        NavigationView {
            VStack {
                
                Picker("Starting Location", selection: $startingLocation) {
                    ForEach(locations, id: \.self) { location in
                        Text(location)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
                

                Picker("Destination", selection: $destination) {
                    ForEach(locations, id: \.self) { location in
                        Text(location)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
                

                if !startingLocation.isEmpty && !destination.isEmpty && startingLocation != destination {
                    Button("View Routes") {
                        urlString = rome2RioURL()
                        showWeb = true
                    }
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                } else {
                    Text("Select different locations to continue.")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Trip Builder")
            .padding()
            .sheet(isPresented: $showWeb) {
                WebView(urlString: $urlString) {
                    savedtrip = "Trip Selected"
                    showWeb = false
                }
            }
        }
    }
    
    func rome2RioURL() -> String {
        let baseURL = "https://www.rome2rio.com/map/"
        let formattedStartingLocation = startingLocation.replacingOccurrences(of: " ", with: "-")
        let formattedDestination = destination.replacingOccurrences(of: " ", with: "-")
        return "\(baseURL)\(formattedStartingLocation)/\(formattedDestination)"
    }
}

#Preview {
    TripBuilderView()
}
