//
//  SettingsEntity+CoreDataProperties.swift
//  
//
//  Created by Олександр on 29.01.2024.
//
//

import Foundation
import CoreData


extension SettingsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsEntity> {
        return NSFetchRequest<SettingsEntity>(entityName: "SettingsEntity")
    }

    @NSManaged public var lat: String?
    @NSManaged public var lon: String?
    @NSManaged public var minutes: Int16
    @NSManaged public var showFirst: Int16
    @NSManaged public var showWeath: Bool
    @NSManaged public var town: String?
    @NSManaged public var id: String?

}
