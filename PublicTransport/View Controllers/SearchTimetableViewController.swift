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
    
    var nearbyStops:[String]?
    var latitude:Float?
    var longitude:Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.busStopPicker.delegate = self
        self.busStopPicker.dataSource = self
        
        nearbyStops = getNearbyStops().stops.map { $0.name }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nearbyStops?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nearbyStops![row]
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
        let busStops:[BusStation] = [BusStation.init(atcocode: "HAHA", mode: "bus", name: "Ioana's Stop", stop_name: "Ioana's Stop", smscode: "scz", bearing: "SE", locality: "Roath", indicator: "bla", longitude: -1, latitude: 50, distance: 100), BusStation.init(atcocode: "HAHA", mode: "bus", name: "Ioana's Stop 2", stop_name: "Ioana's Stop 2", smscode: "scz", bearing: "SE", locality: "Roath", indicator: "bla", longitude: -1.1, latitude: 50.1, distance: 200)]
        let defaultStops = BusStations.init(stops: busStops)
        
        return stops ?? defaultStops
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
