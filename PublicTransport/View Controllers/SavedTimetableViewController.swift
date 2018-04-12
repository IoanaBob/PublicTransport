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
        
        savedTableView.addSubview(refreshControl)
        
        // custom color to navifation (upper side)
        self.navigationController?.navigationBar.tintColor = UIColor(rgb: 0x16a085)
        
        appendToTimetables()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        savedTimetables = []
        appendToTimetables()
        savedTableView.reloadData()
    }
    
    func appendToTimetables() {
        for (key, value) in defaults.dictionaryRepresentation() {
            if (key.hasPrefix("timetable")) {
                savedTimetables.append(value as! [String : String])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SavedCell = tableView.dequeueReusableCell(withIdentifier: "savedBusStopCell") as! SavedCell
        if (savedTimetables[indexPath.row]["bus_line"] == "") {
            cell.busStop.text = savedTimetables[indexPath.row]["name"]
        }
        else {
            cell.busStop.text = savedTimetables[indexPath.row]["name"]! + ", line " + savedTimetables[indexPath.row]["bus_line"]!
            cell.busStopLabel.text = "Stop and Line"
        }
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
        return 100.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TimetableViewController
        if let indexPath = sender as? NSIndexPath {
            destination.atcocode = savedTimetables[indexPath.row]["atcocode"]
            destination.dateField = savedTimetables[indexPath.row]["date"]
            destination.timeField = savedTimetables[indexPath.row]["time"]
            destination.stopName = savedTimetables[indexPath.row]["name"]
            destination.busLineNo = savedTimetables[indexPath.row]["bus_line"] ?? ""
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(FirstViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor(rgb: 0x16a085)

        return refreshControl
    }()

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        savedTimetables = []
        appendToTimetables()
        self.savedTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
}

class SavedCell: UITableViewCell {
    @IBOutlet weak var busStop: UILabel!
    @IBOutlet weak var busStopLabel: UILabel!
    @IBOutlet weak var weekday: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

