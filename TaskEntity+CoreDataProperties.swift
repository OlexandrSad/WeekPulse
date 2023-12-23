//
//  TaskEntity+CoreDataProperties.swift
//  
//
//  Created by Олександр on 23.12.2023.
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
    @NSManaged public var priority: Int16
    @NSManaged public var title: String?
    @NSManaged public var descript: String?

}
