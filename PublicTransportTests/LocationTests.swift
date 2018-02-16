//
//  LocationTests.swift
//  PublicTransportTests
//
//  Created by Ioana on 2/16/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import XCTest

class LocationTests: XCTestCase {
    let locs = Locations()
    
    override func setUp() {
        super.setUp()
        locs.locations.append(Location.init(lat: 0, long: 0, currentSpeed: 1))
        locs.locations.append(Location.init(lat: 0.05, long: 0, currentSpeed: 1))
        locs.locations.append(Location.init(lat: 0.1, long: 0, currentSpeed: 1.15))
        locs.locations.append(Location.init(lat: 0.2, long: 0, currentSpeed: 4.20))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWasInVehicle() {
        let result = locs.isInVehicle(index: 3, since: 0)
        XCTAssertTrue(result)
    }
    
    func testWasNotInVehicle() {
        let result = locs.isInVehicle(index: 2, since: 0)
        XCTAssertFalse(result)
    }
    
    func testDrivingSpeed() {
        XCTAssertTrue(locs.locations[3].isInVehicle())
        XCTAssertFalse(locs.locations[2].isInVehicle())
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
