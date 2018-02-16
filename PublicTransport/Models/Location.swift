//
//  Location.swift
//  PublicTransport
//
//  Created by Ioana Surdu-Bob on 06/02/2018.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//
import Foundation
import CoreLocation

// in meters/second; equivalent to 14km/h
let walkingSpeedTreshold:Double = 14000/3600
let defaults = UserDefaults.standard



struct Location: Codable, Equatable {
    let lat: Double
    let long: Double
    let time: Date
    let currentSpeed: Double
    // information from Transport API
    var nearestBusStation: BusStation?
    var note:busNotes = .none
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.lat == rhs.lat && lhs.long == rhs.long
    }
    
    init(lat: Double, long: Double, currentSpeed: Double) {
        self.lat = lat
        self.long = long
        self.nearestBusStation = nil
        self.time = NSDate() as Date
        self.currentSpeed = currentSpeed
        self.note = .none
    }
    
    init(lat: Double, long: Double, nearestBusStation: BusStation, note: busNotes, currentSpeed: Double) {
        self.lat = lat
        self.long = long
        self.nearestBusStation = nearestBusStation
        self.time = NSDate() as Date
        self.currentSpeed = currentSpeed
        self.note = note
    }
    
    enum busNotes: String, Codable {
        case leftStation, arrivedStation, none
    }
    
    func existentBusStation() -> Bool {
        return nearestBusStation != nil
    }
    
    func isWaitingInStation() -> Bool {
        guard existentBusStation() else {return false}
        // walking speed and within 10 meters of bus station
        return currentSpeed <= walkingSpeedTreshold && nearestBusStation!.distance <= 10
    }
    
    func isInVehicle() -> Bool {
        return currentSpeed > walkingSpeedTreshold
    }
}

class Locations {
    var locations: [Location] = []
    
    func getLocations() -> [Location] {
        return locations
    }
    
    func addLocationIfSignificant(loc: Location) {
        if locations.isEmpty || (timeFromLastLocation(loc) > 60 && loc.currentSpeed <= walkingSpeedTreshold) || (timeFromLastLocation(loc) > 30 && loc.currentSpeed > walkingSpeedTreshold) {
            let lat = Float(loc.lat)
            let long =  Float(loc.long)
            // calls function using completion handler in order to add new location
            BusStations.allBusStations(lat: lat, long: long) { (busStations, error) in
                if let error = error {
                    // got an error in getting the data
                    print(error)
                    return
                }
                guard let busStations = busStations else {
                    print("error getting all: result is nil")
                    return
                }
                //print(busStations.stops)
                if !busStations.stops.isEmpty || self.locations.isEmpty {
                    var mutatedLoc = loc
                    mutatedLoc.nearestBusStation = !self.locations.isEmpty ? busStations.stops.first! : nil
                    self.locations.append(mutatedLoc)
                    print(self.locations)
                    self.saveToDefaults(self.locations)
                }
            }
        }
    }
    
    func hasLeftBusAt() -> [Location] {
        var inStationAtLocations:[Location] = []
        var lastStationIndex:Int = 0
        for var loc in locations {
            guard var nextLoc = locations.item(after: loc) else {return inStationAtLocations}
            let inVehicle = isInVehicle(index: locations.index(of: loc)!, since: lastStationIndex)
            // after leaving the station, busses usually sprint therefore checking if the next location has driving speed
            if loc.isWaitingInStation() && nextLoc.isInVehicle() {
                loc.note = .leftStation
                lastStationIndex = locations.index(of: loc)!
                inStationAtLocations.append(loc)
            }
            // when arriving in station checks against all previous locations
            if inVehicle && nextLoc.isWaitingInStation() {
                nextLoc.note = .arrivedStation
                lastStationIndex = locations.index(of: loc)!
                inStationAtLocations.append(nextLoc)
            }
        }
        return inStationAtLocations
    }
    
    // checks if any of the locations after the previous bus stop had driving speed
    func isInVehicle (index: Int, since firstIndex: Int) -> Bool {
        let subArray = locations[(firstIndex + 1)...index]
        let maxSpeed = (subArray.max {$0.currentSpeed < $1.currentSpeed})!.currentSpeed
        return maxSpeed > walkingSpeedTreshold
    }
    
    private func saveToDefaults(_ objects: [Location]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(objects){
            print("appending locations")
            UserDefaults.standard.set(encoded, forKey: "allLocations")
        }
    }
    
    private func timeFromLastLocation(_ loc: Location) -> Double {
        guard (locations.last != nil) else { return -1 }
        let lastTime = locations.last!.time as CFDate
        let currentTime = loc.time as CFDate
        let seconds = CFDateGetTimeIntervalSinceDate(currentTime, lastTime)
        return seconds
    }
}
