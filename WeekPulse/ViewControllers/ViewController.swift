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
    
    struct Constants {
        static let heightCell: CGFloat = 70
        static let backButtonTitle = "Back"
        static let nibNameForCell = "TaskTableViewCell"
        static let taskCellId = "TaskCell"
    }
    
    let dateFormatter = DateFormatter()
    let today = Date()
    let calendar = Calendar.current
    var dateComponent = DateComponents()
    var dateForTaskVC = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setSegment()
        setTitleVC()
        
        navigationItem.backButtonTitle = Constants.backButtonTitle
    }
    
    
    private func setTable() {
        tasksTable.delegate = self
        tasksTable.dataSource = self
        let nib = UINib(nibName: Constants.nibNameForCell, bundle: nil)
        tasksTable.register(nib, forCellReuseIdentifier: Constants.taskCellId)
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
    
    
    private func textColorSegmented(index: Int) -> UIColor {
        dateComponent.day = index
        let newDate = calendar.date(byAdding: dateComponent, to: today)
        dateFormatter.dateFormat = "E"
        
        if let newDate = newDate, dateFormatter.string(from: newDate) == "Sat" || dateFormatter.string(from: newDate) == "Sun" {
            return .red
        } else {
            return .black
        }
    }
    
    
    private func setTitleVC(addDay: Int = 0) {
        dateComponent.day = addDay
        let newDate = calendar.date(byAdding: dateComponent, to: today)
        
        if let date = newDate {
            dateFormatter.dateFormat = "MMMM dd"
            let currentDate = dateFormatter.string(from: date)
            navigationItem.title = currentDate
        }
    }
    
    
    private func selectedDate(addDay: Int) {
        dateComponent.day = addDay
        let newDate = calendar.date(byAdding: dateComponent, to: today)
        
        if let date = newDate {
            dateForTaskVC = date
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TaskViewController {
            destinationVC.dateFromVC = dateForTaskVC
        }
    }

}


// MARK: - LUNSegmentDelegate-DataSource
extension ViewController: LUNSegmentedControlDelegate, LUNSegmentedControlDataSource {
   
    func numberOfStates(in segmentedControl: LUNSegmentedControl!) -> Int {
        return 7
    }
    
    
    func segmentedControl(_ segmentedControl: LUNSegmentedControl!, titleForStateAt index: Int) -> String! {
        segmentedControl.textColor = textColorSegmented(index: index)
        
        dateComponent.day = index
        let newDate = calendar.date(byAdding: dateComponent, to: today)
        
        guard let newDate = newDate, index != 0 else { return "Today"}
           
        dateFormatter.dateFormat = "E-dd"
            return dateFormatter.string(from: newDate)
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
        setTitleVC(addDay: toIndex)
        selectedDate(addDay: toIndex)
    }
    
}


// MARK: - UITableViewDelegate-DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.taskCellId) as! TaskTableViewCell
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.heightCell
    }
    
}
