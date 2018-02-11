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



struct Location: Equatable {
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.theLocation == rhs.theLocation
    }
    
    enum busNotes {
        case leftStation, arrivedStation, none
    }
    
    let theLocation: CLLocation
    // information from Transport API
    var nearestBusStation: BusStation? = nil
    let time: NSDate
    let currentSpeed: Double
    var note:busNotes = .none
    
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
                print(busStations.stops)
                if !busStations.stops.isEmpty || self.locations.isEmpty {
                    var mutatedLoc = loc
                    mutatedLoc.nearestBusStation = !self.locations.isEmpty ? busStations.stops.first! : nil
                    self.locations.append(mutatedLoc)
                    print(self.locations)
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

extension Collection where Iterator.Element: Equatable {
    typealias Element = Self.Iterator.Element
    
    func safeIndex(after index: Index) -> Index? {
        let nextIndex = self.index(after: index)
        return (nextIndex < self.endIndex) ? nextIndex : nil
    }
    
    func index(afterWithWrapAround index: Index) -> Index {
        return self.safeIndex(after: index) ?? self.startIndex
    }
    
    func item(after item: Element) -> Element? {
        return self.index(of: item)
            .flatMap(self.safeIndex(after:))
            .map{ self[$0] }
    }
    
    func item(afterWithWrapAround item: Element) -> Element? {
        return self.index(of: item)
            .map(self.index(afterWithWrapAround:))
            .map{ self[$0] }
    }
}
