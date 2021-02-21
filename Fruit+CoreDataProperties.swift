//
//  Fruit+CoreDataProperties.swift
//  Part20-coreData-
//
//  Created by 山本ののか on 2021/02/15.
//
//

import Foundation
import CoreData


extension Fruit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Fruit> {
        return NSFetchRequest<Fruit>(entityName: "Fruit")
    }

    @NSManaged public var isChecked: Bool
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var uuid: UUID

}

extension Fruit : Identifiable {

}
