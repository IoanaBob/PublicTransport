//
//  TimetableViewController.swift
//  PublicTransport
//
//  Created by Ioana on 4/6/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import UIKit

class TimetableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timetableTableView: UITableView!
    // button that saves to favorites has to be added programatically
    let favoritesButton = UIButton.init(type: .custom)
    
    let defaults = UserDefaults.standard
    var defaultsKey:String?
    
    var timetable:Timetable?
    var atcocode: String?
    var dateField:String?
    var timeField:String?
    var busLineNo:String?
    var stopName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timetableTableView.delegate = self
        timetableTableView.dataSource = self
        
        defaultsKey = "timetable-\(String(describing: timeField!))-\(getDayOfWeek(dateField!))-\(String(describing: atcocode!))"
        addFavoritesButton()
    }
    
    func addFavoritesButton() {
        // see what is the status from phone memory
        if (defaults.object(forKey: defaultsKey!) != nil) {
            favoritesButton.setImage(UIImage(named: "loved"), for: UIControlState.normal)
        }
        else {
            favoritesButton.setImage(UIImage(named: "not_loved"), for: UIControlState.normal)
        }
        
        //add function for button
        favoritesButton.addTarget(self, action: #selector(changedFavorite), for: UIControlEvents.touchUpInside)
        //set frame
        favoritesButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        let barButton = UIBarButtonItem(customView: favoritesButton)
        //assign button to navigation bar
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        HttpClientApi().getTimetable(atco: atcocode!, date: dateField!, time: timeField!, line: busLineNo ?? "")
        { (receivedTimetable, error) in
            if let error = error {
                self.alert(message: "Something went wrong. Please contact our team regarding this issue.", title: "Error")
                print(error)
                return
            }
            guard let receivedTimetable = receivedTimetable else {
                self.alert(message: "There are no busses leaving in an hour after your selected date and time from this bus stop. Please try for another time.", title: "No departures")
                print("error getting all: result is nil")
                return
            }
            self.timetable = receivedTimetable
            DispatchQueue.main.async(execute: {() -> Void in
                self.timetableTableView.reloadData()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timetable?.all.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TimetableCell = tableView.dequeueReusableCell(withIdentifier: "timetableCell") as! TimetableCell
        cell.lineName.text = timetable!.all[indexPath.row].line_name
        cell.aimedDeparture.text = timetable!.all[indexPath.row].aimed_departure_time
        cell.direction.text = timetable!.all[indexPath.row].direction
        cell.delay.text = String(describing: timetable!.all[indexPath.row].delay)
        
        return cell
    }
    
    @objc func changedFavorite() {
        if (defaults.object(forKey: defaultsKey!) != nil) {
            // user wants to remove from favorites
            defaults.removeObject(forKey: defaultsKey!)
            favoritesButton.setImage(UIImage(named: "not_loved"), for: UIControlState.normal)
        }
        else {
            // user wants to add to favorites
            let valueToSave = ["atcocode": atcocode, "date": dateField, "time": timeField, "weekday": getDayOfWeek(dateField!), "name": stopName]
            defaults.set(valueToSave, forKey: defaultsKey!)
            favoritesButton.setImage(UIImage(named: "loved"), for: UIControlState.normal)
        }
    }
    
    private func getDayOfWeek(_ date:String)->String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thrusday", "Friday", "Saturday"]
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let theDate = formatter.date(from: date)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: theDate)
        let weekDay = myComponents.weekday
        return days[weekDay! - 1]
    }
}

class TimetableCell: UITableViewCell {
    
    @IBOutlet weak var lineName: UILabel!
    @IBOutlet weak var aimedDeparture: UILabel!
    @IBOutlet weak var direction: UILabel!
    @IBOutlet weak var delay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
