//
//  Location.swift
//  PublicTransport
//
//  Created by Ioana Surdu-Bob on 06/02/2018.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import Foundation

class Location {
    let latitude: Float
    let longitude: Float
    // meters to the next bus station
    let nearestBusStationDistance: Float
    let time: NSDate
    
    init(lat: Float, long:Float) {
        self.latitude = lat
        self.longitude = long
        self.nearestBusStationDistance = 0
        self.time = NSDate()
//        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay, fromDate: date)
//        let hour = components.hour
//        let minutes = components.minute
//        let month = components.month
//        let year = components.year
//        let day = components.day
    }
}
