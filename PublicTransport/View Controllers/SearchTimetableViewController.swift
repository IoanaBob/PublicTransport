//
//  SearchTimetableViewController.swift
//  PublicTransport
//
//  Created by Ioana on 4/3/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import UIKit

class SearchTimetableViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var busStopField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var busLineSearchSwitch: UISwitch!
    @IBOutlet weak var busLineField: UITextField!
    @IBOutlet weak var busLineLabel: UILabel!
    
    @IBOutlet weak var findButton: UIButton!
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let busStopPicker = UIPickerView()
    
    var busStops:[BusStation]?
    var nearbyStops:[[String]]?
    var latitude:Float?
    var longitude:Float?
    var timetable:Timetable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        busStopField?.inputView = busStopPicker
        
        busStopPicker.delegate = self
        busStopPicker.dataSource = self
        
        createDatePicker()
        createTimePicker()
        
        busStops = getNearbyStops().stops
        nearbyStops = getNearbyStops().stops.map { [$0.name, String(describing: $0.distance)] }
        
        self.hideWhenTappedAround()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(choseBusStop))
        toolbar.setItems([done], animated: false)
        
        busStopField.inputAccessoryView = toolbar
        busStopField.inputView = busStopPicker
    }

    @IBAction func buttonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "searchTimetable", sender: self.findButton)
    }
    
    @IBAction func switchIsChanged(_ sender: UISwitch) {
        if busLineSearchSwitch.isOn {
            busLineField.text = ""
            busLineField.isHidden = false
            busLineLabel.isHidden = false
        } else {
            busLineField.isHidden = true
            busLineLabel.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TimetableViewController
        let selectedBusStop = busStops![busStopPicker.selectedRow(inComponent: 0)]
        destination.atcocode = selectedBusStop.atcocode
        destination.dateField = dateField.text!
        destination.timeField = timeField.text!
        destination.timetable = self.timetable
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
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        busStopField.text = nearbyStops![row][0]
        busStopField.resignFirstResponder()
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
    
    private func createDatePicker() {
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(choseDate))
        toolbar.setItems([done], animated: false)
        
        dateField.inputAccessoryView = toolbar
        dateField.inputView = datePicker
        
        // format picker
        datePicker.datePickerMode = .date
    }
    
    @objc private func choseDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        //formatter.timeStyle = .none
        //formatter.dateStyle = .medium
        
        dateField.text =  formatter.string(from: (datePicker.date))
        
        self.view.endEditing(true)
    }
    
    
    private func createTimePicker() {
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(choseTime))
        toolbar.setItems([done], animated: false)
        
        timeField.inputAccessoryView = toolbar
        timeField.inputView = timePicker
        
        // format picker
        timePicker.datePickerMode = .time
    }
    
    @objc private func choseTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        //formatter.dateStyle = .none
        //formatter.timeStyle = .medium
        
        timeField.text =  formatter.string(from: (timePicker.date))
        
        self.view.endEditing(true)
    }
    
    @objc private func choseBusStop(){
        let selectedVal = busStopPicker.selectedRow(inComponent: 0)
        pickerView(busStopPicker, didSelectRow: selectedVal, inComponent: 0)
        self.view.endEditing(true)
    }
}
