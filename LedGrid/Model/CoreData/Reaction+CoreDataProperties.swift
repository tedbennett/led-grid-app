//
//  Reaction+CoreDataProperties.swift
//  LedGrid
//
//  Created by Ted Bennett on 16/10/2022.
//
//

import Foundation
import CoreData


extension Reaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reaction> {
        return NSFetchRequest<Reaction>(entityName: "Reaction")
    }

    @NSManaged public var reaction: String
    @NSManaged public var sentAt: Date
    @NSManaged public var art: PixelArt?
    @NSManaged public var sender: String
    @NSManaged public var id: String

}

extension Reaction : Identifiable {

}
