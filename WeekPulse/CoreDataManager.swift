//
//  CoreDataManager.swift
//  WeekPulse
//
//  Created by Олександр on 25.11.2023.
//

import Foundation
import CoreData

class CoreDataManager {

    lazy var persistentContainer: NSPersistentContainer = {
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
    
//    func createOrUpdateTask(task: TaskModel) -> TaskEntity {
//        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
//        request.predicate = NSPredicate(format: "id = %@", task.id.uuidString)
//        do {
//            let fetchTask = try viewContex.fetch(request)
//            if fetchTask.count > 0 {
//                assert(fetchTask.count == 1, "There are duplicates in DB!")
//                return fetchTask[0]
//            }
//        } catch let error {
//            print(error.localizedDescription)
//        }
//        
//    }

}
