//
//  CoreDataManager.swift
//  WeekPulse
//
//  Created by Олександр on 25.11.2023.
//

import Foundation
import CoreData

final class CoreDataManager {
    
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
}


// MARK: - CRUD Task
extension CoreDataManager {
    
    func UpdateOrCreateTask(title: String, ptiority: Int, dedline: Date, dedlineStr: String, descript: String, taskEntity: TaskEntity?) -> TaskEntity? {
        var returnTask: TaskEntity?
        do {
            if let task = taskEntity, let id = task.id {
                let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id = %@", id)
                let tasksFromDB = try viewContex.fetch(request)
                
                assert(tasksFromDB.count == 1, "There are duplicate Tasks in the DB!")
                
                guard let taskFromDB = tasksFromDB.first else {
                    print("Task with given ID not found.")
                    return task
                }
                taskFromDB.title = title
                taskFromDB.priority = Int16(ptiority)
                taskFromDB.dedline = dedline
                taskFromDB.dedlineStr = dedlineStr
                taskFromDB.descript = descript
                returnTask = taskFromDB
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
                returnTask = taskEntity
                saveContext()
            }
        } catch let error {
            print("Error while updating/creating task: \(error.localizedDescription)")
        }
        return returnTask
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
    
    func getAllTasks(entityName: String, contex: NSManagedObjectContext) -> [TaskEntity] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            if let tasks = try contex.fetch(fetchRequest) as? [TaskEntity], !tasks.isEmpty {
                return tasks
            }
        } catch {
            print("Error fetching Tasks: \(error.localizedDescription)")
        }
        return []
    }
}


// MARK: - fetchedResultControllers
extension CoreDataManager {
    
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
}
    

// MARK: - CRUD Settings
extension CoreDataManager {
    
    func createSettings() {
        let fetchRequest: NSFetchRequest<SettingsEntity> = SettingsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", "Settings")
        do {
            let settings = try viewContex.fetch(fetchRequest)
            
            assert(settings.count <= 1, "There are duplicate Settings in the DB!")
            
            if settings.isEmpty {
                let newSettings = SettingsEntity(context: viewContex)
                newSettings.lat = "50.4501"
                newSettings.lon = "30.5234"
                newSettings.minutes = 5
                newSettings.showFirst = 0
                newSettings.showWeath = true
                newSettings.town = "Kyiv, UA"
                newSettings.id = "Settings"
                
                try viewContex.save()
            }
        } catch {
            print("Error fetching or creating SettingsEntity: \(error)")
        }
    }
    
    func getSettings() -> SettingsEntity? {
        var setting: SettingsEntity?
        let fetchRequest: NSFetchRequest<SettingsEntity> = SettingsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", "Settings")
        do {
            let settings = try viewContex.fetch(fetchRequest)
            if let entity = settings.first {
                setting = entity
            }
        } catch {
            print("Error fetching SettingsEntity: \(error)")
        }
        return setting
    }
    
    func saveSettings(minutes: Int, showWeath: Bool, town: String, lat: String, lon: String, shosFirst: Int) {
        let fetchRequest: NSFetchRequest<SettingsEntity> = SettingsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", "Settings")
        do {
            let settingsArray = try viewContex.fetch(fetchRequest)
            if let settings = settingsArray.first {
                settings.minutes = Int16(minutes)
                settings.showWeath = showWeath
                settings.town = town
                settings.lat = lat
                settings.lon = lon
                settings.showFirst = Int16(shosFirst)
            }
            saveContext()
        } catch {
            print("Error saving SettingsEntity: \(error)")
        }
    }
}
