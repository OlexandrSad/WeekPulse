//
//  ViewController.swift
//  WeekPulse
//
//  Created by Олександр on 22.11.2023.
//

import UIKit
import LUNSegmentedControl
import CoreData

class ViewController: UIViewController {  
    @IBOutlet weak var segment: LUNSegmentedControl!
    @IBOutlet weak var tasksTable: UITableView!
    
    struct Constants {
        static let heightCell: CGFloat = 70
        static let backButtonTitle = "Back"
        static let nibNameForCell = "TaskTableViewCell"
        static let cellId = "TaskCell"
        static let sectionCurrent = "Current"
        static let sectionDone = "Done"
        static let sectionEmpty = "There are no tasks yet"
        static let segueToTaskVC = "ToTaskVC"
        static let entityName = "TaskEntity"
        static let sortDescriptor = "dedline"
    }
    
    var countSavedObjects: Int?
    
    let coreDataManager = CoreDataManager.shared
    let dateFormatter = DateFormatter()
    let today = Date()
    let calendar = Calendar.current
    var dateComponent = DateComponents()
    var dateForTaskVC = Date() 
    
    lazy var fetchedResultController = coreDataManager.fetchedResultController(entityName: Constants.entityName,
                                                                               contex: coreDataManager.viewContex,
                                                                               sortDescriptor: Constants.sortDescriptor,
                                                                               date: dateForTaskVC)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setSegment()
        setTitleVC()
        
        fetchedResultController.delegate = self
        coreDataManager.checkExpiredTask(entityName: Constants.entityName, contex: coreDataManager.viewContex, today: today, chosedDay: dateForTaskVC)
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Error fetching data in viewDidLoad: \(error.localizedDescription)")
        }
        
        if let objects = fetchedResultController.fetchedObjects {
            countSavedObjects = objects.count
        }
        
        navigationItem.backButtonTitle = Constants.backButtonTitle
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartAnimationForVisibleCells()
    }
    
    
    private func setTable() {
        tasksTable.delegate = self
        tasksTable.dataSource = self
        let nib = UINib(nibName: Constants.nibNameForCell, bundle: nil)
        tasksTable.register(nib, forCellReuseIdentifier: Constants.cellId)
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
    
    
    private func setDateToTaskVC(addDay: Int) {
        dateComponent.day = addDay
        let newDate = calendar.date(byAdding: dateComponent, to: today)
        
        if let date = newDate {
            dateForTaskVC = date
        }
    }
    
    
    private func performNewFetch(for dayOfWeek: Int) {
        dateComponent.day = dayOfWeek
        let newDate = calendar.date(byAdding: dateComponent, to: today)
        
        guard let choosedDate = newDate else { return }
        let startOfDay = Calendar.current.startOfDay(for: choosedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)
        
        if let endOfDay = endOfDay {
            fetchedResultController.fetchRequest.predicate = NSPredicate(format: "dedline >= %@ AND dedline < %@", startOfDay as CVarArg, endOfDay as CVarArg)
            do {
                try fetchedResultController.performFetch()
                
                if let objects = fetchedResultController.fetchedObjects {
                    countSavedObjects = objects.count
                }
                tasksTable.reloadData()
            } catch {
                print("Error fetching data in performNewFetch: \(error.localizedDescription)")
            }
        }
    }
    
    
    func restartAnimationForVisibleCells() {
        if let visibleCells = tasksTable.visibleCells as? [TaskTableViewCell] {
            for cell in visibleCells {
                
                if let task = cell.taskEntity {
                    cell.animator.makeAnimation(task: task, label: cell.dedlineLabel, view: cell.priorityView)
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = fetchedResultController.object(at: indexPath) as? TaskEntity
        
        if let safeTask = task, safeTask.isOn {
            performSegue(withIdentifier: Constants.segueToTaskVC, sender: safeTask)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueToTaskVC,
           var taskVC = segue.destination as? ToTaskVCProtocol {
            taskVC.dateFromVC = dateForTaskVC
            taskVC.task = sender as? TaskEntity
            taskVC.whoCreated = self.restorationIdentifier
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
        setDateToTaskVC(addDay: toIndex)
        performNewFetch(for: toIndex)
    }
    
}


// MARK: - UITableViewDelegate-DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sectionsCount = fetchedResultController.sections?.count, sectionsCount > 0 {
            return sectionsCount
        } else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionsInfo = fetchedResultController.sections, sectionsInfo.count > 0 {
            return sectionsInfo[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId) as! TaskTableViewCell
        let taskEntity = fetchedResultController.object(at: indexPath) as! TaskEntity
        cell.taskEntity = taskEntity
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionInfo = fetchedResultController.sections, !sectionInfo.isEmpty {
            return sectionInfo[section].name == "0" ? Constants.sectionDone : Constants.sectionCurrent
        } else {
            return Constants.sectionEmpty
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = fetchedResultController.object(at: indexPath) as! TaskEntity
            coreDataManager.viewContex.delete(task)
            NotificationCentr.shared.deleteNotification(for: task)
            coreDataManager.saveContext()
        }
    }
    
}


// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
 
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tasksTable.beginUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            if let countObjects = countSavedObjects, countObjects > 0 {
                tasksTable.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            } else {
                tasksTable.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
            }
        case .update:
            tasksTable.reloadData()
        case .move:
            tasksTable.reloadData()
            
        case .delete:
            tasksTable.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            
            if let objects =  fetchedResultController.fetchedObjects, objects.count == 0 {
                tasksTable.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            }
        default:
            break
        }
    }
    

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tasksTable.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tasksTable.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tasksTable.deleteRows(at: [indexPath], with: .automatic)
                tasksTable.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tasksTable.deleteRows(at: [indexPath], with: .automatic)
            }
        default: break
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        countSavedObjects = fetchedResultController.fetchedObjects?.count
        tasksTable.endUpdates()
    }
    
}
