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



class Location: NSCoding, Equatable {
    let theLocation: CLLocation
    //lat and long instead of CLLocation? how to?
    
    // information from Transport API
    var nearestBusStation: BusStation? = nil
    let time: NSDate
    let currentSpeed: Double
    var note:busNotes = .none
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.theLocation == rhs.theLocation
    }
    
    init(theLocation: CLLocation, currentSpeed: Double) {
        self.theLocation = theLocation
        self.nearestBusStation = nil
        self.time = NSDate()
        self.currentSpeed = currentSpeed
        self.note = .none
    }
    
    init(theLocation: CLLocation, nearestBusStation: BusStation, note: busNotes, currentSpeed: Double) {
        self.theLocation = theLocation
        self.nearestBusStation = nearestBusStation
        self.time = NSDate()
        self.currentSpeed = currentSpeed
        self.note = note
    }
    
    func encode(with aCoder: NSCoder) {
        <#code#>
    }
    
    required init?(coder aDecoder: NSCoder) {
        <#code#>
    }
    
    enum busNotes {
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
            let lat = Float(loc.theLocation.coordinate.latitude)
            let long =  Float(loc.theLocation.coordinate.longitude)
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
                    let locationsData = NSKeyedArchiver.archivedData(withRootObject: self.locations)
                    defaults.set(locationsData, forKey: "allLocations")
                }
            }
        }
    }
    
    func hasLeftBusAt() -> [Location] {
        var inStationAtLocations:[Location] = []
        for var loc in locations {
            guard var nextLoc = locations.item(after: loc) else {return inStationAtLocations}
            if loc.isWaitingInStation() && nextLoc.isInVehicle() {
                loc.note = .leftStation
                inStationAtLocations.append(loc)
            }
            if loc.isInVehicle() && nextLoc.isWaitingInStation() {
                nextLoc.note = .arrivedStation
                inStationAtLocations.append(nextLoc)
            }
        }
        return inStationAtLocations
    }
    
    private func timeFromLastLocation(_ loc: Location) -> Double {
        guard (locations.last != nil) else { return -1 }
        let lastTime = locations.last!.time as CFDate
        let currentTime = loc.time as CFDate
        return CFDateGetTimeIntervalSinceDate(lastTime, currentTime)
    }
}
