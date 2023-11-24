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


