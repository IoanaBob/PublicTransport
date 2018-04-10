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
    
    var timetable:Timetable?
    var atcocode: String?
    var dateField:String?
    var timeField:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timetableTableView.delegate = self
        timetableTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        HttpClientApi().getTimetable(atco: atcocode!, date: dateField!, time: timeField!)
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
