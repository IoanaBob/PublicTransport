//
//  BusStation.swift
//  PublicTransport
//
//  Created by Ioana on 2/7/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import Foundation

struct TimetableItem: Codable {
    let line: String
    let line_name: String
    let direction: String
    let date:String
    let aimed_departure_time: String
    let expected_departure_time: String
    let expected_departure_date: String
    let best_departure_estimate: String
    let dir: String
    let id: String
    let source: String
    let delay: Int
}

struct Timetable: Codable {
    let all: [TimetableItem]
}
