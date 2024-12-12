//
//  DatabaseManager.swift
//  TravelAgency
//
//  Created by COMP401 on 12/11/24.
//

import SwiftUI
import SQLite

struct TripData: Codable, Identifiable {
    var id: UUID
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
    private var tripTable : SQLite.Table?
    
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
    
    func dropTables(){
        do{
            if tripTable != nil{
                try db?.run(tripTable!.drop(ifExists: true))
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
            if tripTable != nil{
                let starting_location = SQLite.Expression<String>("starting_location")
                let destination = SQLite.Expression<String>("destination")
                let price = SQLite.Expression<String>("price")
                let start_time = SQLite.Expression<String>("start_time")
                let end_time = SQLite.Expression<String>("end_time")
                let total_time = SQLite.Expression<String>("total_time")
                let date = SQLite.Expression<String>("date")

                try db?.run(tripTable!.insert(
                    starting_location <- in_startingLocation,
                    destination <- in_destination,
                    price <- in_price,
                    start_time <- in_startTime,
                    end_time <- in_endTime,
                    total_time <- in_totalTime,
                    date <- in_date
                ))

                print("Employee added")
            }
        } catch {
            print("Failed to add employee: \(error)")
        }
    }
}
