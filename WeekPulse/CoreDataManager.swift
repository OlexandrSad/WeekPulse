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
    
    func UpdateOrCreateTask(title: String, ptiority: Int, dedline: Date, descript: String, taskEntity: TaskEntity?) {
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
                taskFromDB.descript = descript
                saveContext()
            } else {
                let taskEntity = TaskEntity(context: viewContex)
                taskEntity.title = title
                taskEntity.priority = Int16(ptiority)
                taskEntity.dedline = dedline
                taskEntity.isOn = true
                taskEntity.descript = descript
                taskEntity.id = UUID().uuidString
                saveContext()
            }
        } catch let error {
            print("Error while updating/creating task: \(error.localizedDescription)")
        }
    }
    
    
    func fetchedResultController(entityName: String, sortDescriptor: String, date: Date) -> NSFetchedResultsController<NSFetchRequestResult> {
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
                                                                 managedObjectContext: CoreDataManager.shared.viewContex,
                                                                 sectionNameKeyPath: sectionNameKeyPath,
                                                                 cacheName: nil)
        return fetchedResultController
    }
}
