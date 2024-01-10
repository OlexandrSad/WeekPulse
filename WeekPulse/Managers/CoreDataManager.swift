//
//  CoreDataManager.swift
//  WeekPulse
//
//  Created by Олександр on 25.11.2023.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static var shared = CoreDataManager()
    private init(){}

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeekPulse")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var viewContex = persistentContainer.viewContext

    
    func saveContext () {
        let context = persistentContainer.viewContext
       
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func UpdateOrCreateTask(title: String, ptiority: Int, dedline: Date, dedlineStr: String, descript: String, taskEntity: TaskEntity?) {
        let notifiCentr = NotificationCentr()
        do {
            if let task = taskEntity, let id = task.id {
                let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id = %@", id)
                let tasksFromDB = try viewContex.fetch(request)
                
                assert(tasksFromDB.count == 1, "There are duplicates in DB!")
                
                guard let taskFromDB = tasksFromDB.first else {
                    print("Task with given ID not found.")
                    return
                }
                
                taskFromDB.title = title
                taskFromDB.priority = Int16(ptiority)
                taskFromDB.dedline = dedline
                taskFromDB.dedlineStr = dedlineStr
                taskFromDB.descript = descript
                notifiCentr.sendNotification(task: taskFromDB, minutes: 5)
                saveContext()
            } else {
                let taskEntity = TaskEntity(context: viewContex)
                taskEntity.title = title
                taskEntity.priority = Int16(ptiority)
                taskEntity.dedline = dedline
                taskEntity.dedlineStr = dedlineStr
                taskEntity.isOn = true
                taskEntity.descript = descript
                taskEntity.id = UUID().uuidString
                notifiCentr.sendNotification(task: taskEntity, minutes: 5)
                saveContext()
            }
        } catch let error {
            print("Error while updating/creating task: \(error.localizedDescription)")
        }
    }
    
    
    func fetchedResultController(entityName: String, contex: NSManagedObjectContext, sortDescriptor: String, date: Date) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)
        
        if let endOfDay = endOfDay {
            fetchRequest.predicate = NSPredicate(format: "dedline >= %@ AND dedline < %@", startOfDay as CVarArg, endOfDay as CVarArg)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "isOn", ascending: false),
                                        NSSortDescriptor(key: sortDescriptor, ascending: true)]
        let sectionNameKeyPath = "isOn"
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                 managedObjectContext: contex,
                                                                 sectionNameKeyPath: sectionNameKeyPath,
                                                                 cacheName: nil)
        return fetchedResultController
    }
    
    
    func allFetchedResultController(entityName: String, contex: NSManagedObjectContext, sortDescriptor: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "isOn = true")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortDescriptor, ascending: true)]
        let sectionNameKeyPath = "dedlineStr"
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                 managedObjectContext: contex,
                                                                 sectionNameKeyPath: sectionNameKeyPath,
                                                                 cacheName: nil)
        return fetchedResultController
    }
    
    
    func checkExpiredTask(entityName: String, contex: NSManagedObjectContext, today: Date, chosedDay: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd (EEEE)"
        let startOfToday = Calendar.current.startOfDay(for: today)
        let startOfChosedDay = Calendar.current.startOfDay(for: chosedDay)
      
        guard startOfToday == startOfChosedDay else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "dedline < %@", startOfToday as CVarArg)
        
        do {
            guard let tasks = try contex.fetch(fetchRequest) as? [TaskEntity], !tasks.isEmpty else { return }
            for task in tasks {
                if task.isOn {
                    task.dedline = startOfToday
                    task.dedlineStr = dateFormatter.string(from: startOfToday)
                } else {
                    contex.delete(task)
                }
            }
            
            saveContext()
        } catch {
            print("Error fetching in checkExpiredTask: \(error.localizedDescription)")
        }
    }
    
}
