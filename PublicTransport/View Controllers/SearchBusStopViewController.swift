//
//  SearchBusStopViewController.swift
//  PublicTransport
//
//  Created by Ioana on 4/3/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import UIKit

class SearchBusStopViewController: UIViewController {
    
    @IBOutlet weak var postcodeInput: UITextField!
    @IBOutlet weak var currentLocationSwitch: UISwitch!
    @IBOutlet weak var findButton: UIButton!
    
    var latitude:Float?
    var longitude:Float?
    var allLocations:[Location] = []
    var busStops:BusStops?
    let helper = LocationsHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        // hide keyboard if anyone clicks on the other side of the screen
        self.hideWhenTappedAround()

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
            let postcode = postcodeInput.text
            
            HttpClientApi().getPostcode(postcode: postcode!) { (postcodeInfo, error) in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self.postcodeInput.text = ""
                        self.alert(message: "Postcode could not be found. Please try again.", title: "Invalid postcode")
                    }
                    return
                }
                self.latitude = postcodeInfo!.result.latitude
                self.longitude = postcodeInfo!.result.longitude
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "searchBusStop", sender: self.findButton)
                }
            }
            
            //self.alert(message: "Postcode could not be found. Please try again.", title: "Invalid postcode")
            //postcodeInput.text = ""
        }
    }
    
    @IBAction func switchIsChanged(_ sender: UISwitch) {
        if currentLocationSwitch.isOn {
            postcodeInput.text = ""
            postcodeInput.isUserInteractionEnabled = false
        } else {
            postcodeInput.isUserInteractionEnabled = true
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
                self.postcodeInput.text = ""
            }
            else {
                stops = busStops
            }
            group.leave()
        }
        group.wait()
        // do something when there are no stops
        return stops ?? BusStops(stops: [])
    }
}

