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
    let busStopTimes:[Location] = defaults.array(forKey: "busStopTimes") as? [Location] ?? []
    let allLocations:[Location] = defaults.array(forKey: "allLocations") as? [Location] ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        busStopTimesTableView.delegate = self
        busStopTimesTableView.dataSource = self
        busStopTimesTableView.addSubview(refreshControl)
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "busStopTime")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return busStopTimes.count
        }
        else if section == 1 {
            return allLocations.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell:BusStationCell = tableView.dequeueReusableCell(withIdentifier: "allLocations") as! BusStationCell
            cell.busStation.text = allLocations[indexPath.row].nearestBusStation?.name ?? "Unknown"
            cell.time.text = formatDate(allLocations[indexPath.row].time)
            cell.speed.text = String(allLocations[indexPath.row].currentSpeed)
            cell.distance.text = String(describing: allLocations[indexPath.row].nearestBusStation?.distance)
            return cell
        }
        let cell:BusLeavingTimesCell = tableView.dequeueReusableCell(withIdentifier: "busLeavingTimesCell") as! BusLeavingTimesCell
        cell.busStation.text = busStopTimes[indexPath.row].nearestBusStation?.name ?? "Unknown"
        cell.time.text = formatDate(busStopTimes[indexPath.row].time)
        return cell
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
        //items.append("item " + String(items.count + 1))
        
        //busStopTimes.append()
        self.busStopTimesTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    private func formatDate(_ date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

        return dateFormatter.string(from: date as Date)
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
