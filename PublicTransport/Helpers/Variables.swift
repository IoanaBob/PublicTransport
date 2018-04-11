//
//  Variables.swift
//  PublicTransport
//
//  Created by Ioana on 2/16/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import Foundation

struct Variables {
    static var requestingNearestBusStops = false
}

struct Helper {
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT:0)
        
        return dateFormatter.string(from: date)
    }
}
