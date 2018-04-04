//
//  SearchTimetableViewController.swift
//  PublicTransport
//
//  Created by Ioana on 4/3/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import UIKit

class SearchTimetableViewController: UIViewController {
    
    @IBOutlet weak var busStopPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var latitude:Float?
    var longitude:Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getNearbyStops() -> BusStations {
        Variables.requestingNearestBusStations = true
        var stops:BusStations?
        BusStations.allBusStations(lat: self.latitude!, long: self.longitude!) { (busStations, error) in
            if let error = error {
                print(error)
                return
            }
            guard let busStations = busStations else {
                print("error getting all: result is nil")
                return
            }
            if !busStations.stops.isEmpty {
                stops = busStations
            }
            Variables.requestingNearestBusStations = false
        }
        return stops
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
