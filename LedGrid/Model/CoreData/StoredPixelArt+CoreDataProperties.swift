//
//  PixelArt+CoreDataProperties.swift
//  LedGrid
//
//  Created by Ted on 11/08/2022.
//
//

import Foundation
import CoreData


extension StoredPixelArt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredPixelArt> {
        return NSFetchRequest<StoredPixelArt>(entityName: "StoredPixelArt")
    }

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var sentAt: Date
    @NSManaged public var sender: String
    @NSManaged public var receivers: [String]
    @NSManaged public var opened: Bool
    @NSManaged public var hidden: Bool
    @NSManaged public var hexGrids: [String]
    

}

extension StoredPixelArt : Identifiable {

}

