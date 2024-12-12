//
//  DatabaseManager.swift
//  TravelAgency
//
//  Created by COMP401 on 12/11/24.
//

import SwiftUI
import SQLite

struct TripData: Codable, Identifiable {
    var id: Int
    var startingLocation: String
    var destination: String
    var price: String
    var startTime: String
    var endTime: String
    var totalTime: String
    var date: String
}

class DatabaseManager: ObservableObject {
    private var db: Connection?
    private var tripTable: SQLite.Table?

    @Published var trips = [TripData]()

    init() {
        createDatabase()
        createTables()
        fetchTrips()
    }

    private func createDatabase() {
        do {
            let documentsDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let dbPath = documentsDirectory.appendingPathComponent("tripDB.sqlite").path
            db = try Connection(dbPath)
        } catch {
            print("Failed to create database: \(error)")
        }
    }

    private func createTables() {
        do {
            let trip_id = SQLite.Expression<Int>("id")
            let starting_location = SQLite.Expression<String>("starting_location")
            let destination = SQLite.Expression<String>("destination")
            let price = SQLite.Expression<String>("price")
            let start_time = SQLite.Expression<String>("start_time")
            let end_time = SQLite.Expression<String>("end_time")
            let total_time = SQLite.Expression<String>("total_time")
            let date = SQLite.Expression<String>("date")

            tripTable = Table("trip")
            try db?.run(tripTable!.create(ifNotExists: true) { table in
                table.column(trip_id, primaryKey: .autoincrement)
                table.column(starting_location)
                table.column(destination)
                table.column(price)
                table.column(start_time)
                table.column(end_time)
                table.column(total_time)
                table.column(date)
            })

            print("Trip table created")
        } catch {
            print("Failed to create table: \(error)")
        }
    }

    func addTrip(
        inStartingLocation: String,
        inDestination: String,
        inPrice: String,
        inStartTime: String,
        inEndTime: String,
        inTotalTime: String,
        inDate: String
    ) {
        do {
            if let tripTable = tripTable {
                let starting_location = SQLite.Expression<String>("starting_location")
                let destination = SQLite.Expression<String>("destination")
                let price = SQLite.Expression<String>("price")
                let start_time = SQLite.Expression<String>("start_time")
                let end_time = SQLite.Expression<String>("end_time")
                let total_time = SQLite.Expression<String>("total_time")
                let date = SQLite.Expression<String>("date")

                try db?.run(tripTable.insert(
                    starting_location <- inStartingLocation,
                    destination <- inDestination,
                    price <- inPrice,
                    start_time <- inStartTime,
                    end_time <- inEndTime,
                    total_time <- inTotalTime,
                    date <- inDate
                ))
                print("Trip added")
            }
        } catch {
            print("Failed to add trip: \(error)")
        }
    }

    func fetchTrips() {
        do {
            guard let tripTable = tripTable else { return }
            let trip_id = SQLite.Expression<Int>("id")
            let starting_location = SQLite.Expression<String>("starting_location")
            let destination = SQLite.Expression<String>("destination")
            let price = SQLite.Expression<String>("price")
            let start_time = SQLite.Expression<String>("start_time")
            let end_time = SQLite.Expression<String>("end_time")
            let total_time = SQLite.Expression<String>("total_time")
            let date = SQLite.Expression<String>("date")

            let trips = try db!.prepare(tripTable).map { row in
                TripData(
                    id: row[trip_id],
                    startingLocation: row[starting_location],
                    destination: row[destination],
                    price: row[price],
                    startTime: row[start_time],
                    endTime: row[end_time],
                    totalTime: row[total_time],
                    date: row[date]
                )
            }
            self.trips = trips
            print("\(trips.count) trips fetched")
        } catch {
            print("Failed to fetch trips: \(error)")
        }
    }

    func fetchLastInsertedTrip() -> TripData? {
        do {
            guard let tripTable = tripTable else { return nil }
            let trip_id = SQLite.Expression<Int>("id")
            if let lastRow = try db!.pluck(tripTable.order(trip_id.desc)) {
                return TripData(
                    id: lastRow[trip_id],
                    startingLocation: lastRow[SQLite.Expression<String>("starting_location")],
                    destination: lastRow[SQLite.Expression<String>("destination")],
                    price: lastRow[SQLite.Expression<String>("price")],
                    startTime: lastRow[SQLite.Expression<String>("start_time")],
                    endTime: lastRow[SQLite.Expression<String>("end_time")],
                    totalTime: lastRow[SQLite.Expression<String>("total_time")],
                    date: lastRow[SQLite.Expression<String>("date")]
                )
            }
        } catch {
            print("Error fetching the last trip: \(error)")
        }
        return nil
    }

    func deleteTrip(id: Int) {
        do {
            guard let tripTable = tripTable else { return }
            let tripId = SQLite.Expression<Int>("id")
            let tripToDelete = tripTable.filter(tripId == id)
            try db?.run(tripToDelete.delete())
            print("Trip deleted")
        } catch {
            print("Failed to delete trip: \(error)")
        }
    }
}
