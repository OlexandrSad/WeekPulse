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

}
