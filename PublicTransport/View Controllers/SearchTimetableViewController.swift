//
//  SearchTimetableViewController.swift
//  PublicTransport
//
//  Created by Ioana on 4/3/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import UIKit

class SearchTimetableViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var busStopPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var nearbyStops:[[String]]?
    var latitude:Float?
    var longitude:Float?
    var timetable:Timetable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.busStopPicker.delegate = self
        self.busStopPicker.dataSource = self
        
        nearbyStops = getNearbyStops().stops.map { [$0.name, String(describing: $0.distance)] }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nearbyStops?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nearbyStops![row][0] + ", " + nearbyStops![row][1] + " meters"
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
        
        // should give a notification before but this is for testing purposes
        let busStops:[BusStation] = [BusStation.init(atcocode: "5710AWA10617", mode: "bus", name: "Treharris Street", stop_name: "Treharris Street", smscode: "cdipaga", bearing: "SE", locality: "Roath", indicator: "o/s", longitude: -3.16913, latitude: 51.48983, distance: 61), BusStation.init(atcocode: "5710AWA10616", mode: "bus", name: "Northcote Lane", stop_name: "Northcote Lane", smscode: "cdimwmj", bearing: "NW", locality: "Roath", indicator: "o/s", longitude: -3.16972, latitude: 51.49001, distance: 99)]
        let defaultStops = BusStations.init(stops: busStops)
        
        return stops ?? defaultStops
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TimetableViewController
        destination.timetable = self.timetable
    }
}
