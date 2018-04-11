//
//  BusStationTests.swift
//  PublicTransportTests
//
//  Created by Ioana Surdu-Bob on 19/02/2018.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import XCTest

class BusStopTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testIswithin10Meters() {
        let busStop1 = LocationScenarios().InitBusStop(distance: 20, number: 1)
        XCTAssertFalse(busStop1.isWithin10Meters(), "Bus station is in more than 10 meters and it should return false.")
        let busStop2 = LocationScenarios().InitBusStop(distance: 5, number: 1)
        XCTAssertTrue(busStop2.isWithin10Meters(), "Bus station is in less than 10 meters and it should return true.")
    }
    
    func testEndpoint() {
        let result = BusStops.endpointForBusStops(lat: 2, long: 2)
        let expected = "https://transportapi.com/v3/uk/bus/stops/near.json?lat=2.0&lon=2.0&app_id=c12137e2&app_key=703b3fc0bc730dacf75e46ce7b9e9402"
        XCTAssertEqual(result, expected)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
