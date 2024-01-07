//
//  AllTasksViewController.swift
//  WeekPulse
//
//  Created by Олександр on 03.01.2024.
//

import UIKit
import CoreData

class AllTasksViewController: UIViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tasksTable: UITableView!
    
    var countSavedObjects: Int?
    let coreDataManager = CoreDataManager.shared
    lazy var fetchedResultController = coreDataManager.allFetchedResultController(entityName: "TaskEntity",
                                                                             contex: coreDataManager.viewContex,
                                                                             sortDescriptor: "dedline")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTable.delegate = self
        tasksTable.dataSource = self
        let nib = UINib(nibName: "TasksTableViewCell", bundle: nil)
        tasksTable.register(nib, forCellReuseIdentifier: "TasksCell")
        
        fetchedResultController.delegate = self
        
        navigationItem.title = "All tasks"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Error fetching data in viewWillAppear: \(error.localizedDescription)")
        }
        
        if let objects = fetchedResultController.fetchedObjects {
            countSavedObjects = objects.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionName = "There are no tasks yet"
        
        if let sectionInfo = fetchedResultController.sections, sectionInfo.count > 0 {
            sectionName = sectionInfo[section].name
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
        headerView.backgroundColor = UIColor.systemGray6
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = sectionName
        headerView.addSubview(label)
        
        if sectionName.contains("Sunday") || sectionName.contains("Saturday") {
            label.textColor = UIColor.red
        } else {
            label.textColor = UIColor.black
        }

        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let task = fetchedResultController.object(at: indexPath) as? TaskEntity
        
        guard let safeTask = task, safeTask.isOn, let dateForTaskVC = task?.dedline else { return }

        if let taskVC = storyboard.instantiateViewController(withIdentifier: "TaskVC") as? TaskViewController {
            taskVC.task = safeTask
            taskVC.dateFromVC = dateForTaskVC
            navigationController?.pushViewController(taskVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    
    @IBAction func toggleEditingMode(_ sender: UIBarButtonItem) {
        tasksTable.setEditing(!tasksTable.isEditing, animated: true)
        let title = tasksTable.isEditing ? "Done" : "Edit"
        editButton.title = title
    }

}


// MARK: - UITableViewDelegate-DataSource
extension AllTasksViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell") as! TasksTableViewCell
        let taskEntity = fetchedResultController.object(at: indexPath) as! TaskEntity
        cell.taskEntity = taskEntity
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = fetchedResultController.object(at: indexPath) as! TaskEntity
            coreDataManager.viewContex.delete(task)
            coreDataManager.saveContext()
        }
    }
    
}


// MARK: - NSFetchedResultsControllerDelegate
extension AllTasksViewController: NSFetchedResultsControllerDelegate {
 
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
            if let indexPath = indexPath {
                tasksTable.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
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
