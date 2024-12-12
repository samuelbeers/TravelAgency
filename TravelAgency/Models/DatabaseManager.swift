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
    private var trip_table : SQLite.Table?
    
    @Published var trips = [TripData]()
    
    init(){
        createDatabase()
        reset()
    }
    
    func reset(){
        dropTables()
        createTables()
        trips.removeAll()
    }
    
    private func createDatabase(){
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
    
    func createTables(){
        do {
            let trip_id = SQLite.Expression<Int>("id")
            let starting_location = SQLite.Expression<String>("starting_location")
            let destination = SQLite.Expression<String>("destination")
            let price = SQLite.Expression<String>("price")
            let start_time = SQLite.Expression<String>("start_time")
            let end_time = SQLite.Expression<String>("end_time")
            let total_time = SQLite.Expression<String>("total_time")
            let date = SQLite.Expression<String>("date")
            
            trip_table = Table("trip")
            try db?.run(trip_table!.create(ifNotExists: true) { table in
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
    
    func dropTables(){
        do{
            if trip_table != nil{
                try db?.run(trip_table!.drop(ifExists: true))
            }
            print("Succeed to drop table")
        }catch{
            print("Failed to drop table : \(error)")
        }
    }
    
    func addTrip(
        in_startingLocation: String,
        in_destination: String,
        in_price: String,
        in_startTime: String,
        in_endTime: String,
        in_totalTime: String,
        in_date: String
    ) {
        do {
            if trip_table != nil{
                let starting_location = SQLite.Expression<String>("starting_location")
                let destination = SQLite.Expression<String>("destination")
                let price = SQLite.Expression<String>("price")
                let start_time = SQLite.Expression<String>("start_time")
                let end_time = SQLite.Expression<String>("end_time")
                let total_time = SQLite.Expression<String>("total_time")
                let date = SQLite.Expression<String>("date")

                try db?.run(trip_table!.insert(
                    starting_location <- in_startingLocation,
                    destination <- in_destination,
                    price <- in_price,
                    start_time <- in_startTime,
                    end_time <- in_endTime,
                    total_time <- in_totalTime,
                    date <- in_date
                ))

                print("Trip added")
            }
        } catch {
            print("Failed to add trip: \(error)")
        }
    }
    
    func fetchTrips() -> [TripData] {
        var trips: [TripData] = []
        do {
            guard let trip_table = trip_table else { return [] }
            let trip_id = SQLite.Expression<Int>("id")
            let starting_location = SQLite.Expression<String>("starting_location")
            let destination = SQLite.Expression<String>("destination")
            let price = SQLite.Expression<String>("price")
            let start_time = SQLite.Expression<String>("start_time")
            let end_time = SQLite.Expression<String>("end_time")
            let total_time = SQLite.Expression<String>("total_time")
            let date = SQLite.Expression<String>("date")
            for row in try db!.prepare(trip_table) {
                let trip = TripData(
                    id: row[trip_id],
                    startingLocation: row[starting_location],
                    destination: row[destination],
                    price: row[price],
                    startTime: row[start_time],
                    endTime: row[end_time],
                    totalTime: row[total_time],
                    date: row[date]
                )
                trips.append(trip)
            }
            self.trips = trips
            print("\(trips.count) trips fetched")
        } catch {
            print("Failed to fetch trips: \(error)")
        }
        return trips
    }
    
    func fetchLastInsertedTrip() -> TripData? {
        guard let trip_table = trip_table else { return nil }
        do {
            let trip_id = SQLite.Expression<Int>("id")
            let starting_location = SQLite.Expression<String>("starting_location")
            let destination = SQLite.Expression<String>("destination")
            let price = SQLite.Expression<String>("price")
            let start_time = SQLite.Expression<String>("start_time")
            let end_time = SQLite.Expression<String>("end_time")
            let total_time = SQLite.Expression<String>("total_time")
            let date = SQLite.Expression<String>("date")
            if let lastRow = try db!.pluck(trip_table.filter(trip_id == Int(db!.lastInsertRowid))) {
                return TripData(
                    id: lastRow[trip_id],
                    startingLocation: lastRow[starting_location],
                    destination: lastRow[destination],
                    price: lastRow[price],
                    startTime: lastRow[start_time],
                    endTime: lastRow[end_time],
                    totalTime: lastRow[total_time],
                    date: lastRow[date]
                )
            }
        } catch {
            print("Error fetching the last trip: \(error)")
        }
        
        return nil
    }

    func deleteTrip(id: Int) {
        do {
            guard let tripTable = trip_table else { return }
            let tripId = SQLite.Expression<Int>("id")
            let tripToDelete = tripTable.filter(tripId == id)
            try db?.run(tripToDelete.delete())
            print("Trip deleted")
        } catch {
            print("Failed to delete trip: \(error)")
        }
    }
}
