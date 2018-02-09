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

struct Location {
    let coordinates: CLLocation
    // information from Transport API
    var nearestBusStation: BusStation? = nil
    let time: NSDate
    let currentSpeed: Double
}

class Locations {
    var locations: [Location] = []
    
    func getLocations() -> [Location] {
        return locations
    }
    
    func addLocationIfSignificant(loc: Location) {
        if locations.isEmpty {
            locations.append(loc)
            print(locations)
            return
        }
        if (timeFromLastLocation(loc) > 60 && loc.currentSpeed <= walkingSpeedTreshold) || (timeFromLastLocation(loc) > 30 && loc.currentSpeed > walkingSpeedTreshold) {
            let lat = Float(loc.coordinates.coordinate.latitude)
            let long =  Float(loc.coordinates.coordinate.longitude)
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
                if !busStations.stops.isEmpty {
                    var mutatedLoc = loc
                    print(busStations.stops)
                    mutatedLoc.nearestBusStation = busStations.stops.first!
                    self.locations.append(mutatedLoc)
                }
            }
        }
    }
    
    private func timeFromLastLocation(_ loc: Location) -> Double {
        guard (locations.last != nil) else { return -1 }
        let lastTime = locations.last!.time as CFDate
        let currentTime = loc.time as CFDate
        return CFDateGetTimeIntervalSinceDate(lastTime, currentTime)
    }
}
