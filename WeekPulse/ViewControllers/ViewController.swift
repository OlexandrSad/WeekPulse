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
    
    let dateFormatter = DateFormatter()
    let today = Date()
    let calendar = Calendar.current
    var dateComponent = DateComponents()
    
    let heightCell: CGFloat = 70
    let backButtonTitle = "Back"
    let nibNameForCell = "TaskTableViewCell"
    let taskCellId = "TaskCell"
    var titleForTaskVC = "WillBeMonthAndNumberHere"
    var dayForColorTitleTaskVC = "WillBeDayOfWeekHere"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setSegment()
    
        dateFormatter.dateFormat = "MMMM dd"
        navigationItem.title = dateFormatter.string(from: today)
        navigationItem.backButtonTitle = backButtonTitle
        
        dateFormatter.dateFormat = "E"
        dayForColorTitleTaskVC = dateFormatter.string(from: today)
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
        let nib = UINib(nibName: nibNameForCell, bundle: nil)
        tasksTable.register(nib, forCellReuseIdentifier: taskCellId)
    }
    
    
    private func setTitleForVC(addDayToCurrent: Int) {
        dateComponent.day = addDayToCurrent
        let newDate = calendar.date(byAdding: dateComponent, to: today)

        dateFormatter.dateFormat = "MMMM dd"
        if let date = newDate {
            let currentDate = dateFormatter.string(from: date)
            navigationItem.title = currentDate
            
            titleForTaskVC = currentDate
            
            dateFormatter.dateFormat = "E"
            dayForColorTitleTaskVC = dateFormatter.string(from: date)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TaskViewController {
            destinationVC.title = titleForTaskVC
            destinationVC.dayForColorTitleVC = dayForColorTitleTaskVC
        }
    }

}


// MARK: - LUNSegmentD-DS
extension ViewController: LUNSegmentedControlDelegate, LUNSegmentedControlDataSource {
   
    func numberOfStates(in segmentedControl: LUNSegmentedControl!) -> Int {
        return 7
    }
    
    
    func segmentedControl(_ segmentedControl: LUNSegmentedControl!, titleForStateAt index: Int) -> String! {
        dateComponent.day = index
        let newDate = calendar.date(byAdding: dateComponent, to: today)
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
        dateComponent.day = index
        guard let newDate = calendar.date(byAdding: dateComponent, to: today) else { return [.gray] }
        let weekday = calendar.component(.weekday, from: newDate)
        
        if weekday == 1 || weekday == 7 {
            return [.red]
        } else {
            return [.gray]
        }
    }
    
    
    func segmentedControl(_ segmentedControl: LUNSegmentedControl!, didChangeStateFromStateAt fromIndex: Int, toStateAt toIndex: Int) {
        setTitleForVC(addDayToCurrent: toIndex)
    }
    
}


// MARK: - UITableViewD-DS
extension ViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: taskCellId) as! TaskTableViewCell
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }
    
}
