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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timetableTableView.delegate = self
        timetableTableView.dataSource = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timetable?.all.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TimetableCell = tableView.dequeueReusableCell(withIdentifier: "timetableCell") as! TimetableCell
        cell.lineName.text = timetable!.all[indexPath.row].line_name
        cell.aimedDeparture.text = timetable!.all[indexPath.row].aimed_departure_time
        cell.direction.text = timetable!.all[indexPath.row].direction
        cell.delay.text = timetable!.all[indexPath.row].delay
        
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
