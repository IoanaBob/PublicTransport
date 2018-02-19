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
    let scenarios = LocationScenarios()
    
    override func setUp() {
        super.setUp()
        scenarios.addWalking(locs: locs)
        scenarios.addEnteringBus(locs: locs)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWasInVehicle() {
        var result = locs.isInVehicle(index: 6, since: 0)
        XCTAssertTrue(result)
        result = locs.isInVehicle(index: 6, since: 6)
        XCTAssertFalse(result)
    }
    
    func testWasNotInVehicle() {
        let result = locs.isInVehicle(index: 2, since: 0)
        XCTAssertFalse(result)
    }
    
    func testDrivingSpeed() {
        XCTAssertTrue(locs.locations[6].isInVehicle())
        XCTAssertFalse(locs.locations[5].isInVehicle())
    }
    
    func testLeftBus() {
        let result = locs.hasLeftBusAt()
        XCTAssertTrue(result[0].note == .leftStation)
        XCTAssertEqual(result, [locs.locations[5]])
    }
    
    func testArrivedBusStation2() {
        scenarios.addArrivingStation2(locs: locs)
        let result = locs.hasLeftBusAt()
        XCTAssertTrue(result[1].note == .arrivedStation)
        XCTAssertEqual(result[1], locs.locations[8])
    }
    
    func testLeftBusStation2() {
        scenarios.addArrivingStation2(locs: locs)
        scenarios.addLeavingStation2(locs: locs)
        let result = locs.hasLeftBusAt()
        XCTAssertTrue(result[2].note == .leftStation)
        XCTAssertEqual(result[2], locs.locations[9])
    }
    
    func testLeftBusStation2Badly() {
        scenarios.addArrivingStation2(locs: locs)
        scenarios.addLeavingStation2Badly(locs: locs)
        let result = locs.hasLeftBusAt()
        XCTAssertFalse(result.last?.note == .leftStation)
        XCTAssertNotEqual(result.last, locs.locations[9])
    }
    
    func testArrivedBusStation3() {
        scenarios.addArrivingStation3(locs: locs)
        let result = locs.hasLeftBusAt()
        XCTAssertTrue(result[1].note == .arrivedStation)
        XCTAssertEqual(result[1], locs.locations[9])
    }
    
    func testLeavingBusStation3() {
        scenarios.addArrivingStation3(locs: locs)
        scenarios.addLeavingStation3(locs: locs)
        let result = locs.hasLeftBusAt()
        XCTAssertFalse(result.last?.note == .leftStation)
    }
    
    func testConditionsApply() {
        let result = locs.conditionsApply(locs.locations[2])
        XCTAssertFalse(result, "Conditions should not apply in this case.")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
