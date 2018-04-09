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
                self.alert(message: "Address could not be found. Please try again.", title: "Invalid address")
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
        destination.latitude = self.latitude!
        destination.longitude = self.longitude!
    }
    
    func isCorrectAddress() -> Bool {
        return false
    }
}

