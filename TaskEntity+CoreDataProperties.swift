//
//  TaskEntity+CoreDataProperties.swift
//  
//
//  Created by Олександр on 22.12.2023.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var dedline: Date?
    @NSManaged public var id: String?
    @NSManaged public var isOn: Bool
    @NSManaged public var priority: NSNumber?
    @NSManaged public var title: String?

}
