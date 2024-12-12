//
//  YourTripsView.swift
//  TravelAgency
//
//  Created by Sam Beers on 11/18/24.
//

import SwiftUI

struct YourTripsView: View {
    @EnvironmentObject var tripManager: TripManager
    
    var body: some View {
        NavigationView {
            List(tripManager.trips) { trip in
                NavigationLink(destination: TripMapView(startingLocation: trip.startingLocation, destination: trip.destination)) {
                    VStack(alignment: .leading) {
                        Text("From: \(trip.startingLocation)")
                            .font(.headline)
                        Text("To: \(trip.destination)")
                        Text("Price: \(trip.price)")
                        Text("Duration: \(trip.totalTime)")
                        
                        TripCountdownView(date: trip.date, time: trip.startTime)
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Trips")
        }
    }
}

struct TripCountdownView: View {
    let date: String
    let time: String
    
    @State private var countdown: String = "Calculating..."
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("Time until trip: \(countdown)")
            .onAppear(perform: updateCountdown)
            .onReceive(timer) { _ in
                updateCountdown()
            }
            .font(.title)
            .bold()
            .frame(alignment: .center)
    }
    
    func updateCountdown() {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        var dateWithYear = "\(date) \(currentYear)"
        guard let datePart = dateFormatter.date(from: dateWithYear) else {
            countdown = "Invalid date"
            return
        }
        
        let currentDate = Date()
        if datePart < currentDate {
            // if date is in the past, user selected trip next year
            dateWithYear = "\(date) \(currentYear + 1)"
        }
        
        guard let finalDatePart = dateFormatter.date(from: dateWithYear) else {
            countdown = "Invalid date"
            return
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        guard let timePart = timeFormatter.date(from: time) else {
            countdown = "Invalid time"
            return
        }
        
        // combine date and time
        var combinedComponents = Calendar.current.dateComponents([.year, .month, .day], from: finalDatePart)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: timePart)
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        
        guard let tripDate = Calendar.current.date(from: combinedComponents) else {
            countdown = "Failed to combine date and time"
            return
        }
        
        if tripDate > currentDate {
            let interval = tripDate.timeIntervalSince(currentDate)
            countdown = formatTimeInterval(interval)
        } else {
            countdown = "Trip started"
        }
    }

    
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


#Preview {
    YourTripsView()
        .environmentObject(TripManager())
}


