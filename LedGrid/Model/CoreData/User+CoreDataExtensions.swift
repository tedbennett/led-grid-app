//
//  User+CoreDataExtensions.swift
//  LedGrid
//
//  Created by Ted Bennett on 18/10/2022.
//

import Foundation
import CoreData

// MARK: Generated accessors for art
extension User {

    @objc(addArtObject:)
    @NSManaged public func addToArt(_ value: PixelArt)

    @objc(removeArtObject:)
    @NSManaged public func removeFromArt(_ value: PixelArt)

    @objc(addArt:)
    @NSManaged public func addToArt(_ values: NSSet)

    @objc(removeArt:)
    @NSManaged public func removeFromArt(_ values: NSSet)
    
    public var artArray: [PixelArt] {
        return Array(art as? Set<PixelArt> ?? [])//.sorted(by: { $0.sentAt > $1.sentAt })
        
    }
}

extension User : Identifiable {

}
