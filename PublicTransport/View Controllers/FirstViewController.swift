//
//  FirstViewController.swift
//  PublicTransport
//
//  Created by Ioana Surdu-Bob on 05/02/2018.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var busStopTimesTableView: UITableView!
    
    var items: [String] = ["We", "Heart", "Swift"]
    let sections = ["Bus leaving times", "All Locations"]
    var busStopTimes:[Location] = [] //defaults.array(forKey: "busStopTimes") as? [Location] ?? []
    var allLocations:[Location] = [] //defaults.array(forKey: "allLocations") as? [Location] ?? []
    let helper = LocationsHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        busStopTimesTableView.delegate = self
        busStopTimesTableView.dataSource = self
        busStopTimesTableView.delaysContentTouches = false
        busStopTimesTableView.addSubview(refreshControl)
        
        self.busStopTimes = helper.loadObjectArray(forKey: "busStopTimes")
        self.allLocations = helper.loadObjectArray(forKey: "allLocations")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return busStopTimes.count
        case 1: return allLocations.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell:BusLeavingTimesCell = tableView.dequeueReusableCell(withIdentifier: "busLeavingTimesCell") as! BusLeavingTimesCell
            cell.busStation.text = busStopTimes[indexPath.row].nearestBusStation?.name ?? "Unknown"
            cell.time.text = Helper().formatDate(busStopTimes[indexPath.row].time)
            return cell
        default:
            let cell:BusStationCell = tableView.dequeueReusableCell(withIdentifier: "allLocationsCell") as! BusStationCell
            cell.busStation.text = allLocations[indexPath.row].nearestBusStation?.name ?? "Unknown"
            cell.time.text = Helper().formatDate(allLocations[indexPath.row].time)
            cell.speed.text = String(allLocations[indexPath.row].currentSpeed)
            cell.distance.text = String(describing: allLocations[indexPath.row].nearestBusStation?.distance ?? -1) 
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(FirstViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.purple
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.busStopTimes = helper.loadObjectArray(forKey: "busStopTimes")
        self.allLocations = helper.loadObjectArray(forKey: "allLocations")
        
        self.busStopTimesTableView.reloadData()
        refreshControl.endRefreshing()
    }    
}

class BusLeavingTimesCell: UITableViewCell {
    @IBOutlet weak var busStation: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class BusStationCell: UITableViewCell {
    
    @IBOutlet weak var busStation: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
