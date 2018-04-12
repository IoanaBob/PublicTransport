//
//  SearchBusStopViewController.swift
//  PublicTransport
//
//  Created by Ioana on 4/3/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import UIKit

class SearchBusStopViewController: UIViewController {
    
    @IBOutlet weak var addressInputLabel: UITextField!
    @IBOutlet weak var currentLocationSwitch: UISwitch!
    @IBOutlet weak var findButton: UIButton!
    
    var latitude:Float?
    var longitude:Float?
    var allLocations:[Location] = []
    var busStops:BusStops?
    let helper = LocationsHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        // custom color to navifation (upper side)
        self.navigationController?.navigationBar.tintColor = UIColor(rgb: 0x16a085)
        //UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.orange]
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        if currentLocationSwitch.isOn {
            self.allLocations = helper.loadObjectArray(forKey: "allLocations")
            self.latitude = allLocations.last?.lat
            self.longitude = allLocations.last?.long
            performSegue(withIdentifier: "searchBusStop", sender: findButton)
        }
        else {
            if isCorrectAddress() {
                performSegue(withIdentifier: "searchBusStop", sender: findButton)
            }
            else {
                self.alert(message: "Postcode could not be found. Please try again.", title: "Invalid postcode")
                addressInputLabel.text = ""
            }
        }
    }
    
    @IBAction func switchIsChanged(_ sender: UISwitch) {
        if currentLocationSwitch.isOn {
            addressInputLabel.text = ""
            addressInputLabel.isUserInteractionEnabled = false
        } else {
            addressInputLabel.isUserInteractionEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SearchTimetableViewController
        destination.busStops = getNearbyStops()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    func isCorrectAddress() -> Bool {
        return false
    }
    
    func getNearbyStops() -> BusStops {
        var stops:BusStops?
        Variables.requestingNearestBusStops = true
        
        // for testing on computer. this should be removed soon
        self.latitude = 51.4893106
        self.longitude = -3.16884189
        
        let group = DispatchGroup()
        group.enter()
        BusStops.allBusStops(lat: self.latitude!, long: self.longitude!) { (busStops, error) in
            if let error = error {
                print(error)
                return
            }
            guard let busStops = busStops else {
                print("error getting all: result is nil")
                return
            }
            if busStops.stops.isEmpty {
                self.alert(message: "No nearby stops could be found. Please try with a different location.", title: "No bus stops")
                self.addressInputLabel.text = ""
            }
            else {
                stops = busStops
            }
            group.leave()
        }
        group.wait()
        return stops!
        
        // should give a notification before but this is for testing purposes
        //        let busStops:[BusStop] = [BusStop.init(atcocode: "5710AWA10617", mode: "bus", name: "Treharris Street", stop_name: "Treharris Street", smscode: "cdipaga", bearing: "SE", locality: "Roath", indicator: "o/s", longitude: -3.16913, latitude: 51.48983, distance: 61), BusStop.init(atcocode: "5710AWA10616", mode: "bus", name: "Northcote Lane", stop_name: "Northcote Lane", smscode: "cdimwmj", bearing: "NW", locality: "Roath", indicator: "o/s", longitude: -3.16972, latitude: 51.49001, distance: 99)]
        //        let defaultStops = BusStop.init(stops: busStops)
        //        return stops ?? defaultStops
    }
}

