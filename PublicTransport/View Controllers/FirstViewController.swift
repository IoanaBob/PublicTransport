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
    @IBOutlet weak var PostButton: UITableViewCell!
    
    var items: [String] = ["We", "Heart", "Swift"]
    let sections = ["Bus leaving times", "All Locations", "Post location"]
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
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell:BusLeavingTimesCell = tableView.dequeueReusableCell(withIdentifier: "busLeavingTimesCell") as! BusLeavingTimesCell
            cell.busStop.text = busStopTimes[indexPath.row].nearestBusStop?.name ?? "Unknown"
            cell.time.text = Helper().formatDate(busStopTimes[indexPath.row].time)
            return cell
        case 2:
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "POST")!
            return cell
        default:
            let cell:BusStopCell = tableView.dequeueReusableCell(withIdentifier: "allLocationsCell") as! BusStopCell
            cell.busStop.text = allLocations[indexPath.row].nearestBusStop?.name ?? "Unknown"
            cell.time.text = Helper().formatDate(allLocations[indexPath.row].time)
            cell.speed.text = String(allLocations[indexPath.row].currentSpeed)
            cell.distance.text = String(describing: allLocations[indexPath.row].nearestBusStop?.distance ?? -1) 
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
    
    @IBAction func postLocationToDB(_ sender: Any) {
        let stop = allLocations.last!
        let params:[String:Any] = [
            "atcocode": stop.nearestBusStop!.atcocode,
            "mode": stop.nearestBusStop!.mode,
            "name": stop.nearestBusStop!.name,
            "stop_name": stop.nearestBusStop!.stop_name,
            "smscode": stop.nearestBusStop!.smscode,
            "bearing": stop.nearestBusStop!.bearing,
            "locality": stop.nearestBusStop!.locality,
            "indicator": stop.nearestBusStop!.indicator,
            "longitude": stop.nearestBusStop!.longitude,
            "latitude": stop.nearestBusStop!.latitude,
            "distance": stop.nearestBusStop!.distance,
        ]
        
        HttpClientApi.instance().postElement(url: "/bus_stop", params: params, success: { (data, response, error) in
            print("POST bus stop succesful!")
            
            let url = "/location/" + String(describing: data!.id)
            let locationParams:[String:Any] = [
                "note": stop.note.hashValue,
                "latitude": stop.lat,
                "longitude": stop.long,
                "time": Helper().formatDate(stop.time),
                "current_speed": stop.currentSpeed,
            ]
            
            HttpClientApi.instance().postElement(url: url, params: locationParams, success: { (data, response, error) in
                print("POST location succesful!")
            }, failure: { (data, response, error) in
                print("POST location failure")
                print(error as Any)
            })
        }, failure: { (data, response, error) in
            print("POST bus stop failure")
            print(error as Any)
        })
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
    @IBOutlet weak var busStop: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class BusStopCell: UITableViewCell {
    
    @IBOutlet weak var busStop: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
