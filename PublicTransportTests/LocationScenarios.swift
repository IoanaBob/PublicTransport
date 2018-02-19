//
//  LocartionFactory.swift
//  PublicTransportTests
//
//  Created by Ioana Surdu-Bob on 19/02/2018.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import Foundation

struct LocationScenarios {
    func addWalking(locs: Locations) {
        locs.locations.append(Location.init(lat: 0, long: 0, nearestBusStation: InitBusStation(distance: 100, number: 1), note: .none, currentSpeed: 1))
        locs.locations.append(Location.init(lat: 0.04, long: 0.04, nearestBusStation: InitBusStation(distance: 80, number: 1), note: .none, currentSpeed: 1))
        locs.locations.append(Location.init(lat: 0.08, long: 0.05, nearestBusStation: InitBusStation(distance: 60, number: 1), note: .none, currentSpeed: 1.5))
        locs.locations.append(Location.init(lat: 0.15, long: 0.1, nearestBusStation: InitBusStation(distance: 20, number: 1), note: .none, currentSpeed: 1.5))
    }
    
    // station 1
    func addEnteringBus(locs: Locations) {
        locs.locations.append(Location.init(lat: 0.15, long: 0.15, nearestBusStation: InitBusStation(distance: 10, number: 1), note: .none, currentSpeed: 1.5))
        locs.locations.append(Location.init(lat: 0.2, long: 0.2, nearestBusStation: InitBusStation(distance: 0, number: 1), note: .none, currentSpeed: 0.0))
        locs.locations.append(Location.init(lat: 0.24, long: 0.24, nearestBusStation: InitBusStation(distance: 20, number: 1), note: .none, currentSpeed: 4.0))
    }
    
    func addArrivingStation2(locs: Locations) {
        locs.locations.append(Location.init(lat: 0.35, long: 0.35, nearestBusStation: InitBusStation(distance: 20, number: 2), note: .none, currentSpeed: 6))
        locs.locations.append(Location.init(lat: 0.4, long: 0.4, nearestBusStation: InitBusStation(distance: 1, number: 2), note: .none, currentSpeed: 0.2))
    }
    
    func addLeavingStation2(locs: Locations) {
        locs.locations.append(Location.init(lat: 0.401, long: 0.4, nearestBusStation: InitBusStation(distance: 1, number: 2), note: .none, currentSpeed: 0.0))
        locs.locations.append(Location.init(lat: 0.43, long: 0.43, nearestBusStation: InitBusStation(distance: 25, number: 2), note: .none, currentSpeed: 4.2))
    }
    
    func addLeavingStation2Badly(locs: Locations) {
        locs.locations.append(Location.init(lat: 0.401, long: 0.4, nearestBusStation: InitBusStation(distance: 1, number: 2), note: .none, currentSpeed: 0.0))
        locs.locations.append(Location.init(lat: 0.43, long: 0.43, nearestBusStation: InitBusStation(distance: 25, number: 2), note: .none, currentSpeed: 2.2))
    }
    
    func addArrivingStation3(locs: Locations) {
        locs.locations.append(Location.init(lat: 0.55, long: 0.55, nearestBusStation: InitBusStation(distance: 30, number: 3), note: .none, currentSpeed: 6))
        locs.locations.append(Location.init(lat: 0.57, long: 0.58, nearestBusStation: InitBusStation(distance: 15, number: 3), note: .none, currentSpeed: 1))
        locs.locations.append(Location.init(lat: 0.6, long: 0.6, nearestBusStation: InitBusStation(distance: 2, number: 3), note: .none, currentSpeed: 0.2))
    }
    
    func addLeavingStation3(locs: Locations) {
        locs.locations.append(Location.init(lat: 0.6, long: 0.6, nearestBusStation: InitBusStation(distance: 1, number: 3), note: .none, currentSpeed: 0.0))
        locs.locations.append(Location.init(lat: 0.63, long: 0.63, nearestBusStation: InitBusStation(distance: 25, number: 3), note: .none, currentSpeed: 1.2))
        locs.locations.append(Location.init(lat: 0.7, long: 0.63, nearestBusStation: InitBusStation(distance: 50, number: 3), note: .none, currentSpeed: 2))
    }
    
    func InitBusStation(distance: Int, number: Int) -> BusStation {
        let numberStr = String(number)
        let atcocode = "mycode" + numberStr
        let mode = "bus"
        let name = "stop " + numberStr
        let smscode = "blabla" + numberStr
        let bearing = "NW" + numberStr
        let locality = "Roath"
        let indicator = "o/s"
        let longitude = 0.1 * Double(2 + number)
        let latitude = 0.1 * Double(2 + number)
        return BusStation.init(atcocode: atcocode, mode: mode, name: name, stop_name: name, smscode: smscode, bearing: bearing, locality: locality, indicator: indicator, longitude:Float(longitude), latitude:Float(latitude), distance: distance)
    }
}
