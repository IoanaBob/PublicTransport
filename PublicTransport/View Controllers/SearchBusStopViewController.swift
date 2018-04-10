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
    var busStops:BusStations?
    let helper = LocationsHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        //destination.latitude = self.latitude!
        //destination.longitude = self.longitude!
    }
    
    func isCorrectAddress() -> Bool {
        return false
    }
    
    func getNearbyStops() -> BusStations {
        var stops:BusStations?
        Variables.requestingNearestBusStations = true
        
        // for testing on computer. this should be removed soon
        self.latitude = 51.4893106
        self.longitude = -3.16884189
        
        let group = DispatchGroup()
        group.enter()
        BusStations.allBusStations(lat: self.latitude!, long: self.longitude!) { (busStations, error) in
            if let error = error {
                print(error)
                return
            }
            guard let busStations = busStations else {
                print("error getting all: result is nil")
                return
            }
            if busStations.stops.isEmpty {
                self.alert(message: "No nearby stops could be found. Please try with a different location.", title: "No bus stops")
                self.addressInputLabel.text = ""
            }
            else {
                stops = busStations
            }
            group.leave()
        }
        Variables.requestingNearestBusStations = false
        group.wait()
        return stops!
    }
}

