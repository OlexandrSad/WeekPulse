//
//  ViewController.swift
//  WeekPulse
//
//  Created by Олександр on 22.11.2023.
//

import UIKit
import LUNSegmentedControl

class ViewController: UIViewController {

    @IBOutlet weak var segment: LUNSegmentedControl!
    @IBOutlet weak var tasksTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setSegment()
    }
    
    private func setSegment() {
        segment.delegate = self
        segment.dataSource = self
        segment.backgroundColor = .quaternaryLabel
        segment.selectorViewColor = .separator
        segment.layer.cornerRadius = 10
        segment.layer.borderWidth = 2
        segment.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setTable() {
        tasksTable.delegate = self
        tasksTable.dataSource = self
        let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        tasksTable.register(nib, forCellReuseIdentifier: "TaskCell")
    }

}


extension ViewController: LUNSegmentedControlDelegate, LUNSegmentedControlDataSource {
    func numberOfStates(in segmentedControl: LUNSegmentedControl!) -> Int {
        return 7
    }
    
    func segmentedControl(_ segmentedControl: LUNSegmentedControl!, titleForStateAt index: Int) -> String! {
        let today = Date()
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.day = index
        let newDate = calendar.date(byAdding: dateComponent, to: today)
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        
        if let newDate = newDate, dateFormatter.string(from: newDate) == "Sat" || dateFormatter.string(from: newDate) == "Sun" {
            segmentedControl.textColor = .red
        } else {
            segmentedControl.textColor = .black
        }
        
        dateFormatter.dateFormat = "E-dd"
        
        if let newDate = newDate, index != 0 {
            return dateFormatter.string(from: newDate)
        }
    
        return "Today"
       }
    
    func segmentedControl(_ segmentedControl: LUNSegmentedControl!, gradientColorsForStateAt index: Int) -> [UIColor]! {
        let today = Date()
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.day = index
        let newDate = calendar.date(byAdding: dateComponent, to: today)
        let weekday = calendar.component(.weekday, from: newDate ?? today)
        
        if weekday == 1 || weekday == 7 {
            return [.red]
        } else {
            return [.gray]
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
