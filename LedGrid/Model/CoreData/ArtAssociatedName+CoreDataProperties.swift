//
//  ArtAssociatedName+CoreDataProperties.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//
//

import Foundation
import CoreData


extension ArtAssociatedName {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArtAssociatedName> {
        return NSFetchRequest<ArtAssociatedName>(entityName: "ArtAssociatedName")
    }

    @NSManaged public var name: String
    @NSManaged public var lastUpdated: Date
    @NSManaged public var imageData: Data?
    @NSManaged public var art: PixelArt?

}

extension ArtAssociatedName : Identifiable {

}
