//
//  User+CoreDataProperties.swift
//  LedGrid
//
//  Created by Ted Bennett on 16/10/2022.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: String
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var fullName: String?
    @NSManaged public var givenName: String?
    @NSManaged public var email: String?
    @NSManaged public var art: NSSet?
}
