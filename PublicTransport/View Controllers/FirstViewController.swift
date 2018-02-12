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
    var busStopTimes = defaults.array(forKey: "busStopTimes") ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        busStopTimesTableView.delegate = self
        busStopTimesTableView.dataSource = self
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "busStopTime")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BusLeavingTimesCell = tableView.dequeueReusableCell(withIdentifier: "busLeavingTimesCell") as! BusLeavingTimesCell
        cell.busStation.text = items[indexPath.row]
        cell.time.text = "@ midnight"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}

class BusLeavingTimesCell: UITableViewCell {
    @IBOutlet weak var busStation: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
