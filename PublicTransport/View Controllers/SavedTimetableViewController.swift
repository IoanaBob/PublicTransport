//
//  SavedTimetableViewController.swift
//  PublicTransport
//
//  Created by Ioana Surdu-Bob on 11/04/2018.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import UIKit

class SavedTimetableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var savedTableView: UITableView!
    
    let defaults = UserDefaults.standard
    var savedTimetables:[[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedTableView.delegate = self
        savedTableView.dataSource = self
        savedTableView.delaysContentTouches = false
        //savedTableView.addSubview(refreshControl)
        
        for (key, value) in defaults.dictionaryRepresentation() {
            if (key.hasPrefix("timetable")) {
                savedTimetables.append(value as! [String : String])
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SavedCell = tableView.dequeueReusableCell(withIdentifier: "savedBusStopCell") as! SavedCell
        cell.busStop.text = savedTimetables[indexPath.row]["atcocode"]
        cell.time.text = savedTimetables[indexPath.row]["time"]
        cell.weekday.text = savedTimetables[indexPath.row]["weekday"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "selectSavedTimetable", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTimetables.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TimetableViewController
        if let indexPath = sender as? NSIndexPath {
            destination.atcocode = savedTimetables[indexPath.row]["atcocode"]
            destination.dateField = savedTimetables[indexPath.row]["date"]
            destination.timeField = savedTimetables[indexPath.row]["time"]
        }
    }
}
    
    //    lazy var refreshControl: UIRefreshControl = {
    //        let refreshControl = UIRefreshControl()
    //        refreshControl.addTarget(self, action:
    //            #selector(FirstViewController.handleRefresh(_:)),
    //                                 for: UIControlEvents.valueChanged)
    //        refreshControl.tintColor = UIColor.purple
    //
    //        return refreshControl
    //    }()
    //
    //    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    //        self.busStopTimes = helper.loadObjectArray(forKey: "busStopTimes")
    //        self.allLocations = helper.loadObjectArray(forKey: "allLocations")
    //
    //        self.busStopTimesTableView.reloadData()
    //        refreshControl.endRefreshing()
    //    }

class SavedCell: UITableViewCell {
    @IBOutlet weak var busStop: UILabel!
    @IBOutlet weak var weekday: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

