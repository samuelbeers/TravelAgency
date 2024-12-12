import SwiftUI

struct TripBuilderView: View {
    @State var startingLocation: String = ""
    @State var destination: String = ""
    @State var showWeb: Bool = false
    @State var urlString: String = ""
    @State var savedTrip: TripData? = nil
    @State var navigateToYourTrips: Bool = false
    @EnvironmentObject var tripManager: TripManager
    var cities: [City]
    var locations: [String] {
        cities.map { $0.name }
    }
    
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
                
                Text("To")
                    .font(.largeTitle)
                    .padding(.vertical, 0)

                Picker("Destination", selection: $destination) {
                    ForEach(locations, id: \.self) { location in
                        Text(location)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding(.bottom, 10)
                

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
                
                if let trip = savedTrip {
                    VStack(alignment: .leading) {
                        Text("Saved Trip:")
                            .font(.headline)
                        Text("From: \(trip.startingLocation)")
                        Text("To: \(trip.destination)")
                        Text("Price: \(trip.price)")
                        Text("Start Time: \(trip.startTime)")
                        Text("End Time: \(trip.endTime)")
                        Text("Total Duration: \(trip.totalTime)")
                        Text("Date: \(trip.date)")
                    }
                    .padding()
                    
                    HStack {
                        Button("No") {
                            showWeb = true
                            savedTrip = nil
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        
                        Button("Yes") {
                            if let trip = savedTrip {
                                tripManager.trips.append(trip)
                                savedTrip = nil
                                navigateToYourTrips = true
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .padding()
                }
                
                Spacer()
                NavigationLink(
                    destination: YourTripsView(),
                    isActive: $navigateToYourTrips
                ) { EmptyView() }
            }
            .navigationTitle("Trip Builder")
            .padding()
            .sheet(isPresented: $showWeb) {
                WebView(
                    urlString: $urlString,
                    startingLocation: startingLocation,
                    destination: destination
                ){ tripData in
                    savedTrip = tripData
                    showWeb = false
                }
                .environmentObject(DatabaseManager())
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
    TripBuilderView(cities: [City(name: "New York", latitude: 40.730610, longitude: -73.935242, country: "US", population: 3592294, region: "California", is_capital: false),
                             City(name: "Los Angeles", latitude: 34.052235, longitude: -118.243683, country: "US", population: 3980400, region: "California", is_capital: false),
                             City(name: "Chicago", latitude: 41.881832, longitude: -87.623177, country: "US", population: 2695598, region: "Illinois", is_capital: false),
                             City(name: "San Francisco", latitude: 37.773972, longitude: -122.431297, country: "US", population: 870887, region: "California", is_capital: false),
                             City(name: "Miami", latitude: 25.793449, longitude: -80.139198, country: "US", population: 470914, region: "Florida", is_capital: false)])
        .environmentObject(TripManager(databaseManager: DatabaseManager()))
}
