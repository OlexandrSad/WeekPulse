//
//  TaskEntity+CoreDataProperties.swift
//  
//
//  Created by Олександр on 25.11.2023.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var dedline: String?
    @NSManaged public var isOn: NSNumber?
    @NSManaged public var priority: NSNumber?
    @NSManaged public var id: UUID?

}
