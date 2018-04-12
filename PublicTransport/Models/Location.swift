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
let walkingSpeedTreshold:Float = 14000/3600
let defaults = UserDefaults.standard

struct Location: Codable, Equatable {
    let lat: Float
    let long: Float
    let time: Date
    let currentSpeed: Float
    // information from Transport API
    var nearestBusStop: BusStop?
    var note:busNotes = .none
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.lat == rhs.lat && lhs.long == rhs.long
    }
    
    init(lat: Float, long: Float, currentSpeed: Float) {
        self.lat = lat
        self.long = long
        self.nearestBusStop = nil
        self.time = NSDate() as Date
        self.currentSpeed = currentSpeed
        self.note = .none
    }
    
    init(lat: Float, long: Float, nearestBusStop: BusStop, note: busNotes, currentSpeed: Float) {
        self.lat = lat
        self.long = long
        self.nearestBusStop = nearestBusStop
        self.time = NSDate() as Date
        self.currentSpeed = currentSpeed
        self.note = note
    }
    
    enum busNotes: String, Codable {
        case leftStation, arrivedStation, none
    }
    
    func existentBusStop() -> Bool {
        return nearestBusStop != nil
    }
    
    func isWaitingInStation() -> Bool {
        guard existentBusStop() else {return false}
        // walking speed and within 10 meters of bus station
        return currentSpeed <= walkingSpeedTreshold && nearestBusStop!.distance <= 10
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
        if conditionsApply(loc) {
            Variables.requestingNearestBusStops = true
            let lat = Float(loc.lat)
            let long =  Float(loc.long)
            // calls function using completion handler in order to add new location
            BusStops.allBusStops(lat: lat, long: long) { (busStops, error) in
                if let error = error {
                    // got an error in getting the data
                    print(error)
                    return
                }
                guard let busStops = busStops else {
                    print("error getting all: result is nil")
                    return
                }
                if !busStops.stops.isEmpty || self.locations.isEmpty {
                    var mutatedLoc = loc
                    mutatedLoc.nearestBusStop = busStops.stops.first ?? nil
                    self.locations.append(mutatedLoc)
                    print(self.locations)
                    self.saveToDefaults(self.locations)
                }
            }
            Variables.requestingNearestBusStops = false
        }
    }
    
    // checks if any of the locations after the previous bus stop had driving speed
    func isInVehicle (index: Int, since firstIndex: Int) -> Bool {
        if firstIndex == index {
            return false
        }
        let subArray = Array(locations[(firstIndex + 1)...index])
        let maxSpeed = (subArray.max {$0.currentSpeed < $1.currentSpeed})!.currentSpeed
        return maxSpeed > walkingSpeedTreshold
    }
    
    func addBusStopsToDefaults() {
        let helper = LocationsHelper()
        // TODO: Use maxspeed from all locations after the last stop
        //let updatedLocations = addBusDelays(locs)
        var busStopTimes = helper.loadObjectArray(forKey: "busStopTimes")
        let newBusStopTimes = findBusStopTimes()
        busStopTimes.append(contentsOf: newBusStopTimes)
        // encoding complex objects so it can be saved in phone storage
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(busStopTimes){
            UserDefaults.standard.set(encoded, forKey: "busStopTimes")
        }
        // emptying locations because we don't need them anymore
        emptyLocations()
    }
    
    func addToDB() {
        let newLocations = findBusStopTimes()
        for stop in newLocations {
            if stop.note != .none {
                let params:[String:Any] = [
                    "atcocode": stop.nearestBusStop!.atcocode,
                    "mode": stop.nearestBusStop!.mode,
                    "name": stop.nearestBusStop!.name,
                    "stop_name": stop.nearestBusStop!.stop_name,
                    "smscode": stop.nearestBusStop!.smscode,
                    "bearing": stop.nearestBusStop!.bearing,
                    "locality": stop.nearestBusStop!.locality,
                    "indicator": stop.nearestBusStop!.indicator,
                    "longitude": stop.nearestBusStop!.longitude,
                    "latitude": stop.nearestBusStop!.latitude,
                    "distance": stop.nearestBusStop!.distance,
                    ]
                
                HttpClientApi.instance().postElement(url: "/bus_stop", params: params, success: { (data, response, error) in
                    print("POST bus stop succesful!")
                    
                    let url = "/location/" + String(describing: data!.id)
                    
                    let locationParams:[String:Any] = [
                        "note": stop.note.hashValue,
                        "latitude": stop.lat,
                        "longitude": stop.long,
                        "time": Helper().formatDate(stop.time),
                        "current_speed": stop.currentSpeed,
                        ]
                    
                    HttpClientApi.instance().postElement(url: url, params: locationParams, success: { (data, response, error) in
                        print("POST location succesful!")
                    }, failure: { (data, response, error) in
                        print("POST location failure")
                        print(error as Any)
                    })
                }, failure: { (data, response, error) in
                    print("POST bus stop failure")
                    print(error as Any)
                }) // end api call
            }
        } // end loop
        
        // emptying locations because we don't need them anymore
        emptyLocations()
    }
    
    func findBusStopTimes() -> [Location] {
        var busStopTimes:[Location] = []
        let locs = self.hasLeftBusAt()
        for location in locs {
            // add to persistent memory
            switch location.note {
            case .leftStation:
                // take current location
                busStopTimes.append(location)
            case .arrivedStation:
                guard let nextLocation = locs.item(after: location) else { return busStopTimes }
                if nextLocation.note == .leftStation {
                    // do nothing
                    break
                }
                else {
                    // take current location
                    busStopTimes.append(location)
                }
            case .none: break // do nothing
            }
        }
        return busStopTimes
    }
    
    func hasLeftBusAt() -> [Location] {
        var inStationAtLocations:[Location] = []
        var lastStationIndex:Int = 0
        for var loc in locations {
            print("index = " + String(locations.index(of: loc)!) )
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
    
    func emptyLocations() {
        if self.locations.isEmpty {
            self.locations = [self.locations.last!]
        }
    }
    
    private func saveToDefaults(_ objects: [Location]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(objects){
            print("appending locations")
            UserDefaults.standard.set(encoded, forKey: "allLocations")
        }
    }
    
    func conditionsApply(_ loc: Location) -> Bool {
        // thread lock
        guard Variables.requestingNearestBusStops == false else {return false}
        // we always want to add the first location for future reference
        guard !locations.isEmpty else { return true }
        // the new location has the same coordinates as the one last recorded
        if locations.last! == loc { return false }
        // conditions based on walking/driving distance
        if (loc.nearestBusStop?.distance ?? -1) > 200 {
            if (timeFromLastLocation(loc) > 60 && loc.currentSpeed <= walkingSpeedTreshold) || (timeFromLastLocation(loc) > 30 && loc.currentSpeed > walkingSpeedTreshold) {
                return true
            }
        }
        else {
            if (timeFromLastLocation(loc) > 30 && loc.currentSpeed <= walkingSpeedTreshold) || (timeFromLastLocation(loc) > 15 && loc.currentSpeed > walkingSpeedTreshold) {
                return true
            }
        }
        return false
    }
    
    private func timeFromLastLocation(_ loc: Location) -> Double {
        guard (locations.last != nil) else { return -1 }
        let lastTime = locations.last!.time as CFDate
        let currentTime = loc.time as CFDate
        let seconds = CFDateGetTimeIntervalSinceDate(currentTime, lastTime)
        return seconds
    }
}
