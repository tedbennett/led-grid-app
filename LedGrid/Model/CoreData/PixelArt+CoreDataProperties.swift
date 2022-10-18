//
//  PixelArt+CoreDataProperties.swift
//  LedGrid
//
//  Created by Ted on 11/08/2022.
//
//

import Foundation
import CoreData


extension PixelArt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PixelArt> {
        return NSFetchRequest<PixelArt>(entityName: "PixelArt")
    }

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var sentAt: Date
    @NSManaged public var sender: String
    @NSManaged public var opened: Bool
    @NSManaged public var hidden: Bool
    @NSManaged public var art: SerializableArt
    @NSManaged public var users: NSSet?
    @NSManaged public var reactions: NSSet?
    
    
}

